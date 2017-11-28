local width = 800
local height = 480
local iTime = 0
local iTimeDelta = 0
local canvas = nil
local cam_dir = {1,0,0}
local cam_pos = {3,1,0}
local shader = nil
local sensitivityX = 0.5
local sensitivityY = 0.5

function setCamera(pos, dir)
  cam_pos = pos
  cam_dir = dir
end

function updateObjectsList(objects)
	local obj_amount = 0

	for i,ob in ipairs(objects) do
		local models = ob[2]
		for j,o in ipairs(models) do
			local alpha = o[5]
			local t = 0
			local c = {o[4][1]/255,o[4][2]/255,o[4][3]/255}
			if o[1] == "Plane" then
				t = 1
			elseif o[1] == "Sphere" then
				t = 2
			elseif o[1] == "uBox" then
				t = 3
			elseif o[1] == "Box" then
				t = 4
			end
			send("objects["..tostring(i-1+j-1).."].Type",t)
			send("objects["..tostring(i-1+j-1).."].i",i-1+j-1)
			send("objects["..tostring(i-1+j-1).."].p",o[2])
			send("objects["..tostring(i-1+j-1).."].b",o[3])
			send("objects["..tostring(i-1+j-1).."].color",c)
			obj_amount = obj_amount + 1
		end
	end

	send("object_amount",obj_amount)
end

function updateLightsList(lights)
	local light_amount = 0

	for i,l in ipairs(lights) do
		local c = {l[4][1]/255,l[4][2]/255,l[4][3]/255}
		local t = 0
		if l[1] == "Directional" then
			t = 1
		elseif l[1] == "Point" then
			t = 2
		end
		send("lights["..tostring(i-1).."].Type",t)
		send("lights["..tostring(i-1).."].p",l[2])
		send("lights["..tostring(i-1).."].d",l[3])
		send("lights["..tostring(i-1).."].color",c)
		light_amount = light_amount + 1
	end
	send("light_amount",light_amount)
end

function setCanvas(c)
  canvas = c
  return true
end

function setShader(s)
  shader = s
  return true
end

function send(name, value)
  if shader:hasUniform(name) then
    shader:send(name, value)
  end
end

function render()
  send("cam_pos", cam_pos)
  send("cam_dir", cam_dir)
  love.graphics.setShader(shader)
	love.graphics.setColor(255,255,255,255)
	love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
  love.graphics.setShader()
end
