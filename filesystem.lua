function FS_loadModel(filename)
  local t = {}
	local f = assert(io.open("assets/"..filename, "r"))
	for line in f:lines() do
		local object = loadstring("return "..line)()
    for i=1, #object[1] do
      if object[1][i].tex then
        local texloc = object[1][i].tex
        object[1][i].tex = love.graphics.newImage("assets/"..texloc)
        object[1][i].texname = texloc
        object[1][i].texsize = {object[1][i].tex:getWidth(), object[1][i].tex:getHeight()}
      end
      if object[1][i].bumptex then
        local bumptexloc = object[1][i].bumptex
        object[1][i].bumptex = love.graphics.newImage("assets/"..bumptexloc)
        object[1][i].bumptexname = bumptexloc
      end
  		-- table.insert(objects,object)
      table.insert(t, object[1][i])
    end
	end
  return t
end

function generateTextureAtlas(objects)
  local max_size = 8192

  local textures_used = {}
  local bumps_used = {}

  local tex_atlas = {love.graphics.newCanvas(max_size, max_size)}
  local bump_atlas = {love.graphics.newCanvas(max_size, max_size)}

  local x = 0
  local y = 0

  local cur_layer_height = 0

  local cur_atlas = 1

  --Create texture atlas
  for i=1, #objects do
    local dobreak = false
    if objects[i].tex then
      local tex_found = false
      for j=1, #textures_used do
        if objects[i].texname == textures_used[j].name then
          tex_found = true
          objects[i].tex_offset = {textures_used[j].pos.x, textures_used[j].pos.y, textures_used[j].layer}
        end
      end

      if tex_found == false then
        local size = objects[i].texsize

        local texdata = {name=objects[i].texname}

        if y + size[2] > max_size then
          cur_atlas = cur_atlas + 1
          x = 0
          y = 0
          cur_layer_height = 0
        end

        texdata.layer = cur_atlas

        if x + size[1] < max_size then
          cur_layer_height = math.max(cur_layer_height, size[2])

          objects[i].tex_offset = {x, y, cur_atlas}
          texdata.pos = {x=x, y=y}

          love.graphics.setCanvas(tex_atlas[cur_atlas])
          love.graphics.draw(objects[i].tex, x, y)
          love.graphics.setCanvas()
          x = x + size[1]
        else
          x = 0
          y = y + cur_layer_height
          if y + size[2] > max_size then
            cur_atlas = cur_atlas + 1
            if cur_atlas > 16 then
              dobreak = true
              break
            end
          end
          if dobreak then
            break
          end
          cur_layer_height = math.max(0, size[2])

          objects[i].tex_offset = {x, y, cur_atlas}
          texdata.pos = {x=x, y=y}

          love.graphics.setCanvas(tex_atlas[cur_atlas])
          love.graphics.draw(objects[i].tex, x, y)
          love.graphics.setCanvas()
          x = x + size[1]
        end
        table.insert(textures_used, texdata)
      end
    end
    if dobreak then
      break
    end
  end

  x = 0
  y = 0
  size_left = max_size
  height_left = max_size
  cur_atlas = 1
  cur_layer_height = 0

  --Create bump atlas
  for i=1, #objects do
    local dobreak = false
    if objects[i].bumptex then
      local tex_found = false
      for j=1, #bumps_used do
        if objects[i].bumptexname == bumps_used[j].name then
          tex_found = true
          objects[i].bump_offset = {bumps_used[j].pos.x, bumps_used[j].pos.y, bumps_used[j].layer}
        end
      end

      if tex_found == false then
        local size = objects[i].texsize

        local bumpdata = {name=objects[i].bumptexname}

        if y + size[2] > max_size then
          cur_atlas = cur_atlas + 1
          x = 0
          y = 0
          cur_layer_height = 0
        end

        bumpdata.layer = cur_atlas

        if x + size[1] < max_size then
          cur_layer_height = math.max(cur_layer_height, size[2])

          objects[i].bump_offset = {x, y, cur_atlas}
          bumpdata.pos = {x=x, y=y}

          love.graphics.setCanvas(bump_atlas[cur_atlas])
          love.graphics.draw(objects[i].bumptex, x, y)
          love.graphics.setCanvas()
          x = x + size[1]
        else
          x = 0
          y = y + cur_layer_height
          if y + size[2] > max_size then
            cur_atlas = cur_atlas + 1
            if cur_atlas > 16 then
              dobreak = true
              break
            end
          end
          if dobreak then
            break
          end
          cur_layer_height = math.max(0, size[2])

          objects[i].bump_offset = {x, y, cur_atlas}
          bumpdata.pos = {x=x, y=y}

          love.graphics.setCanvas(bump_atlas[cur_atlas])
          love.graphics.draw(objects[i].bumptex, x, y)
          love.graphics.setCanvas()
          x = x + size[1]
        end
        table.insert(bumps_used, bumpdata)
      end
    end
    if dobreak then
      break
    end
  end

  print("Creating texture atlas data")

  local tex_atlas_data = {}
  local bump_atlas_data = {}

  for i=1, #tex_atlas do
    table.insert(tex_atlas_data, tex_atlas[i]:newImageData())
  end
  for i=1, #bump_atlas do
    table.insert(bump_atlas_data, bump_atlas[i]:newImageData())
  end

  print("Done!")

  return tex_atlas_data, bump_atlas_data
end
