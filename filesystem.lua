function FS_loadModel(filename)
  local t = {}
	local f = assert(io.open("assets/"..filename, "r"))
	for line in f:lines() do
		local object = loadstring("return "..line)()
		-- table.insert(objects,object)
    table.insert(t, object)
	end
  return t
end
