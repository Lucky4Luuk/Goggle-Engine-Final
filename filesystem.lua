function FS_loadModel(filename)
  local t = {}
	local f = assert(io.open("assets/"..filename, "r"))
	for line in f:lines() do
		local object = loadstring("return "..line)()
    for i=1, #object[1] do
  		-- table.insert(objects,object)
      table.insert(t, object[1][i])
    end
	end
  return t
end
