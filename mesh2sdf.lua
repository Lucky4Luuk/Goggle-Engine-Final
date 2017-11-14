function genSDF(filename)
  if not file_exists(filename) then
    print("File does not exist")
    return nil
  end

  local vertices = {}
  -- local tris = {}
  local imgdata = love.graphics.newCanvas(127,127):newImageData()

  local x = 0
  local y = 0

  local BBOX = {min = {x=10, y=10, z=10}, max = {x=-10, y=-10, z=-10}}
  local scale = 1.0

  for i, line in ipairs(lines_from(filename)) do
    if string.starts(line, "v ") then
      local l = line:sub(3, #line)
      local pos = string.split(l, " ")
      pos[1] = (tonumber(pos[1])+1)*scale*32
      pos[2] = (tonumber(pos[2])+1)*scale*32
      pos[3] = (tonumber(pos[3])+1)*scale*32
      pos[1] = pos[1]/255
      pos[2] = pos[2]/255
      pos[3] = pos[3]/255
      table.insert(vertices, pos)

      BBOX.min.x = math.min(pos[1], BBOX.min.x)
      BBOX.min.y = math.min(pos[2], BBOX.min.y)
      BBOX.min.z = math.min(pos[3], BBOX.min.z)

      BBOX.max.x = math.max(pos[1], BBOX.max.x)
      BBOX.max.y = math.max(pos[2], BBOX.max.y)
      BBOX.max.z = math.max(pos[3], BBOX.max.z)
    end
  end

  BBOX.min.x = BBOX.min.x
  BBOX.min.y = BBOX.min.y
  BBOX.min.z = BBOX.min.z
  BBOX.max.x = BBOX.max.x
  BBOX.max.y = BBOX.max.y
  BBOX.max.z = BBOX.max.z

  print("BBOX:")
  print_table({BBOX.min.x, BBOX.min.y, BBOX.min.z})
  print_table({BBOX.max.x, BBOX.max.y, BBOX.max.z})

  local tris = {}

  for i, line in ipairs(lines_from(filename)) do
    if string.starts(line, "f ") then
      --Add to tris table
      local l = line:sub(3, #line)
      local verts = string.split(l, " ")
      --Split verts into vertexid, uvid, normalid
      --For now, only the vertexposition is passed to the shader
      local data = {}

      for j=1,#verts do
        local d = string.split(verts[j], "/")
        local vertid = tonumber(d[1])
        -- table.insert(data, vertices[vertid])
        local pos = vertices[vertid]
        --Put them on the canvas
        imgdata:setPixel(x+(j-1), y, pos[1], pos[2], pos[3], 1)
        -- table.insert(data, pos)
      end

      x = x + 3
      if x > 125 then
        y = y + 1
        x = 0
      end

      -- table.insert(tris, data)
    end
  end

  local texSize = 128

  imgdata:encode("png", "imgdata.png")

  local vertices = {
        {
            -- top-left corner
            0, 0, -- position of the vertex
            0, 0, -- texture coordinate at the vertex position
            255, 255, 255, -- color of the vertex
        },
        {
            -- top-right corner
            texSize, 0,
            1, 0, -- texture coordinates are in the range of [0, 1]
            255, 255, 255
        },
        {
            -- bottom-right corner
            texSize, texSize*texSize,
            1, 1,
            255, 255, 255
        },
        {
            -- bottom-left corner
            0, texSize*texSize,
            0, 1,
            255, 255, 255
        },
    }

  -- the Mesh DrawMode "fan" works well for 4-vertex Meshes.
  local m = love.graphics.newMesh(vertices, "fan")

  local shader = love.graphics.newShader("shaders/mesh2sdf.glsl")
  shader:send("texSize",texSize)
  shader:send("mesh",love.graphics.newImage(imgdata))
  shader:send("meshres",{126,126})
  local canvas = love.graphics.newCanvas(texSize,texSize*texSize)
  love.graphics.setShader(shader)
  love.graphics.setCanvas(canvas)
  -- love.graphics.rectangle("fill",0,0,texSize,texSize*texSize)
  love.graphics.draw(m)
  love.graphics.setCanvas()
  love.graphics.setShader()
  canvas:newImageData():encode("png", "test.png")
  -- saveImage(canvas:newImageData():encode("png"), "test.png")

  local buffers = {}
  local img = love.graphics.newImage(canvas:newImageData())

  for i=1,texSize do
    local buf = love.graphics.newQuad(0, (i-1)*texSize, texSize, texSize, texSize, texSize*texSize)
    local c = love.graphics.newCanvas(texSize, texSize)
    love.graphics.setCanvas(c)
    love.graphics.draw(img, buf)
    love.graphics.setCanvas()
    table.insert(buffers, c:newImageData())
    c:newImageData():encode("png","buf_"..tostring(i)..".png")
  end

  return love.graphics.newVolumeImage(buffers)
end

function length(a)
  return math.sqrt(a[1]*a[1] + a[2]*a[2] + a[3]*a[3])
end

function floor_vec(a)
  return {math.floor(a[1]), math.floor(a[2]), math.floor(a[3])}
end

function getTriangleVoxels(tri)
  local v = {}

  local p1 = tri[1]
  local p2 = tri[2]
  local p3 = tri[3]

  local dir = {p2[1] - p1[1], p2[2] - p1[2], p2[3] - p1[3]}
  local l = length(dir)

  for i=0, l do
    local pos = {p1[1] + dir[1]*l, p1[2] + dir[2]*l, p1[3] + dir[3]*l}
    table.insert(v, floor_vec(pos))
  end

  dir = {p3[1] - p2[1], p3[2] - p2[2], p3[3] - p2[3]}
  l = length(dir)

  for i=0, l do
    local pos = {p2[1] + dir[1]*l, p2[2] + dir[2]*l, p2[3] + dir[3]*l}
    table.insert(v, floor_vec(pos))
  end

  dir = {p1[1] - p3[1], p1[2] - p3[2], p1[3] - p3[3]}
  l = length(dir)

  for i=0, l do
    local pos = {p3[1] + dir[1]*l, p3[2] + dir[2]*l, p3[3] + dir[3]*l}
    table.insert(v, floor_vec(pos))
  end

  return v
end

function genVoxelTexture(filename)
  if not file_exists(filename) then
    print("File does not exist")
    return nil
  end

  local vertices = {}

  local x = 0
  local y = 0

  local BBOX = {min = {x=10, y=10, z=10}, max = {x=-10, y=-10, z=-10}}
  local scale = 1.0

  for i, line in ipairs(lines_from(filename)) do
    if string.starts(line, "v ") then
      local l = line:sub(3, #line)
      local pos = string.split(l, " ")
      pos[1] = (tonumber(pos[1]))*scale*64 + 64
      pos[2] = (tonumber(pos[2]))*scale*64 + 64
      pos[3] = (tonumber(pos[3]))*scale*64 + 64
      pos[1] = pos[1]
      pos[2] = pos[2]
      pos[3] = pos[3]
      table.insert(vertices, pos)

      BBOX.min.x = math.min(pos[1], BBOX.min.x)
      BBOX.min.y = math.min(pos[2], BBOX.min.y)
      BBOX.min.z = math.min(pos[3], BBOX.min.z)

      BBOX.max.x = math.max(pos[1], BBOX.max.x)
      BBOX.max.y = math.max(pos[2], BBOX.max.y)
      BBOX.max.z = math.max(pos[3], BBOX.max.z)
    end
  end

  BBOX.min.x = BBOX.min.x
  BBOX.min.y = BBOX.min.y
  BBOX.min.z = BBOX.min.z
  BBOX.max.x = BBOX.max.x
  BBOX.max.y = BBOX.max.y
  BBOX.max.z = BBOX.max.z

  print("BBOX:")
  print_table({BBOX.min.x, BBOX.min.y, BBOX.min.z})
  print_table({BBOX.max.x, BBOX.max.y, BBOX.max.z})

  local tris = {}

  for i, line in ipairs(lines_from(filename)) do
    if string.starts(line, "f ") then
      --Add to tris table
      local l = line:sub(3, #line)
      local verts = string.split(l, " ")
      --Split verts into vertexid, uvid, normalid
      --For now, only the vertexposition is used
      local data = {}

      for j=1, #verts do
        local d = string.split(verts[j], "/")
        local vertid = tonumber(d[1])
        -- table.insert(data, vertices[vertid])
        local pos = vertices[vertid]

        table.insert(data, pos)
      end

      x = x + 3
      if x > 124 then
        y = y + 1
        x = 0
      end

      table.insert(tris, data)
    end
  end

  local voxels = {}

  for i=1, #tris do
    local v = getTriangleVoxels(tris[i]) -- Gets a list of points which represent the voxels
    for j=1, #v do
      table.insert(voxels, v[j])
    end
  end

  return voxels
end

function distance(a, b)
  return length({a[1]-b[1], a[2]-b[2], a[3]-b[3]})
end

function getClosestVoxel(pos, voxels)
  local closest = voxels[1]
  local d = distance(closest, pos)
  for i=1, #voxels do
    if distance(voxels[i], pos) < d then
      closest = voxels[i]
      d = distance(voxels[i], pos)
    end
  end

  return closest, d
end

function genSDF_CPU(filename)
  local voxels = genVoxelTexture(filename)

  local buffers = {}

  for y=1, 128 do
    local buf = love.graphics.newCanvas(128,128):newImageData()
    for x=1, 128 do
      for z=1, 128 do
        local v, d = getClosestVoxel({x-1, y, z-1}, voxels)
        buf:setPixel(x-1, z-1, d, d, d, 1)
      end
    end
    buf:encode("png", "buf_"..tostring(y)..".png")
    table.insert(buffers, buf)
  end

  return love.graphics.newVolumeImage(buffers)
end

function genSDF_VOXEL(filename)
  if not file_exists(filename) then
    print("File does not exist")
    return nil
  end

  local vertices = {}

  local x = 0
  local y = 0

  local BBOX = {min = {x=10, y=10, z=10}, max = {x=-10, y=-10, z=-10}}
  local scale = 1.0

  for i, line in ipairs(lines_from(filename)) do
    if string.starts(line, "v ") then
      local l = line:sub(3, #line)
      local pos = string.split(l, " ")
      pos[1] = (tonumber(pos[1]))*scale*64 + 64
      pos[2] = (tonumber(pos[2]))*scale*64 + 64
      pos[3] = (tonumber(pos[3]))*scale*64 + 64
      pos[1] = pos[1]
      pos[2] = pos[2]
      pos[3] = pos[3]
      table.insert(vertices, pos)

      BBOX.min.x = math.min(pos[1], BBOX.min.x)
      BBOX.min.y = math.min(pos[2], BBOX.min.y)
      BBOX.min.z = math.min(pos[3], BBOX.min.z)

      BBOX.max.x = math.max(pos[1], BBOX.max.x)
      BBOX.max.y = math.max(pos[2], BBOX.max.y)
      BBOX.max.z = math.max(pos[3], BBOX.max.z)
    end
  end

  BBOX.min.x = BBOX.min.x
  BBOX.min.y = BBOX.min.y
  BBOX.min.z = BBOX.min.z
  BBOX.max.x = BBOX.max.x
  BBOX.max.y = BBOX.max.y
  BBOX.max.z = BBOX.max.z

  print("BBOX:")
  print_table({BBOX.min.x, BBOX.min.y, BBOX.min.z})
  print_table({BBOX.max.x, BBOX.max.y, BBOX.max.z})

  local tris = {}

  for i, line in ipairs(lines_from(filename)) do
    if string.starts(line, "f ") then
      --Add to tris table
      local l = line:sub(3, #line)
      local verts = string.split(l, " ")
      --Split verts into vertexid, uvid, normalid
      --For now, only the vertexposition is used
      local data = {}

      for j=1, #verts do
        local d = string.split(verts[j], "/")
        local vertid = tonumber(d[1])
        -- table.insert(data, vertices[vertid])
        local pos = vertices[vertid]

        table.insert(data, pos)
      end

      x = x + 3
      if x > 124 then
        y = y + 1
        x = 0
      end

      table.insert(tris, data)
    end
  end

  local texSize = 32

  local shader = love.graphics.newShader("shaders/mesh2voxel.glsl")
  local canvas = love.graphics.newCanvas(texSize, texSize*texSize)

  shader:send("texSize", texSize)

  for i=1, #tris do
    local str = "tris["..tostring(i).."]."
    shader:send(str .. "one", tris[i][1])
    shader:send(str .. "two", tris[i][2])
    shader:send(str .. "three", tris[i][3])
  end

  love.graphics.setShader(shader)
  love.graphics.setCanvas(canvas)
  love.graphics.rectangle("fill",0,0,texSize,texSize*texSize)
  love.graphics.setCanvas()
  love.graphics.setShader()

  local imgdata = canvas:newImageData()
  imgdata:encode("png", "imgdata.png")

  local buffers = {}
  local img = love.graphics.newImage(imgdata)

  for i=1,texSize do
    local buf = love.graphics.newQuad(0, (i-1)*texSize, texSize, texSize, texSize, texSize*texSize)
    local c = love.graphics.newCanvas(texSize, texSize)
    love.graphics.setCanvas(c)
    love.graphics.draw(img, buf)
    love.graphics.setCanvas()
    table.insert(buffers, c:newImageData())
    c:newImageData():encode("png","buf_"..tostring(i)..".png")
  end

  return love.graphics.newVolumeImage(buffers)
end
