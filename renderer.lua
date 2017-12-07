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

function setRenderSize(w, h)
  width = w
  height = h
  return true
end

function updateAtlas(tex_atlas, bump_atlas)
  send("tex_atlas", tex_atlas)
  send("bump_atlas", bump_atlas)
end

function updateObjectsList(objects)
	local obj_amount = 0

	for i, o in ipairs(objects) do
		local alpha = o.alpha
		local t = 0
		--local c = {o[4][1]/255,o[4][2]/255,o[4][3]/255}
    local c = {o.color[1]/255, o.color[2]/255, o.color[3]/255}
		if o.t == "Plane" then
			t = 1
		elseif o.t == "Sphere" then
			t = 2
		elseif o.t == "uBox" then
			t = 3
		elseif o.t == "Box" then
			t = 4
		end
    if o.tex then
      send("objects["..tostring(obj_amount).."].isTextured", true)
      send("objects["..tostring(obj_amount).."].texsize", o.texsize)
      send("objects["..tostring(obj_amount).."].texrepeat", o.texrepeat)
      send("objects["..tostring(obj_amount).."].tex_offset", o.tex_offset)
    else
      send("objects["..tostring(obj_amount).."].isTextured", false)
    end
    if o.bumptex then
      send("objects["..tostring(obj_amount).."].hasBumpMap", true)
      send("objects["..tostring(obj_amount).."].bump_offset", o.bump_offset)
    else
      send("objects["..tostring(obj_amount).."].hasBumpMap", false)
    end
		send("objects["..tostring(obj_amount).."].Type",t)
		send("objects["..tostring(obj_amount).."].i",obj_amount)
		send("objects["..tostring(obj_amount).."].p",o.pos)
		send("objects["..tostring(obj_amount).."].b",o.size)
		send("objects["..tostring(obj_amount).."].color",c)
    send("objects["..tostring(obj_amount).."].ref",o.ref)
		obj_amount = obj_amount + 1
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
  --Set variables
	send("iTime",{iTime,iTimeDelta})
  send("cam_pos", cam_pos)
  send("cam_dir", cam_dir)
  send("screen_res", {width, height})
  love.graphics.setShader(shader)
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
  love.graphics.setShader()
end
