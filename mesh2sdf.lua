function genSDF(filename)
  if not file_exists(filename) then
    return nil
  end
  
  local vertices = {}
  local tris = {}
  
  for i, line in ipairs(lines_from(filename)) do
    if string.starts(line, "v ") then
      local l = line:sub(3, #line)
      local pos = string.split(l, " ")
      pos[1] = tonumber(pos[1])
      pos[2] = tonumber(pos[2])
      pos[3] = tonumber(pos[3])
      print(pos[3])
      table.insert(vertices, pos)
    elseif string.starts(line, "f ") then
      --Add to tris table
      local l = line:sub(3, #line)
      local verts = string.split(l, " ")
      --Split verts into vertexid, uvid, normalid
    end
  end
end