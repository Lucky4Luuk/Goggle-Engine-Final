--LOVE 3D ENGINE

require("distance_functions")
require("mesh2sdf")
require("utils")

local debug = false

local width = 800
local height = 480
local iTime = 0
local iTimeDelta = 0
local canvas = nil
local cam_dir = {1,0,0}
local cam_pos = {-3,1,-3}
local shader = nil
local sensitivityX = 0.5
local sensitivityY = 0.5

local objects = {}
local lights = {{"Directional",{0,0,0},{-0.4,0.3,-0.6},{255,255,255}},{"Point",{-3,2,0},{3,0,0},{0,0,255}}}
--local lights = {{"Point",{0,2,2},{3,0,0},{255,0,0}},{"Point",{0,2,-2},{3,0,0},{0,0,255}}}

local fog_density = 0.1
local view_distance = 20.0

function updateObjectsList()
	local obj_amount = 0

	for i, o in ipairs(objects) do
		shader:send("objects["..obj_amount.."].p", o.p)
		shader:send("objects["..obj_amount.."].mesh", o.mesh)
		shader:send("objects["..obj_amount.."].color", o.color)
		-- shader:send("objects["..obj_amount.."].id", o.id)
		obj_amount = obj_amount + 1
	end

	shader:send("object_amount",obj_amount)
end

function updateLightsList()
	local light_amount = 0

	for i,l in ipairs(lights) do
		local c = {l[4][1]/255,l[4][2]/255,l[4][3]/255}
		local t = 0
		if l[1] == "Directional" then
			t = 1
		elseif l[1] == "Point" then
			t = 2
		end
		shader:send("lights["..tostring(i-1).."].Type",t)
		shader:send("lights["..tostring(i-1).."].p",l[2])
		shader:send("lights["..tostring(i-1).."].d",l[3])
		shader:send("lights["..tostring(i-1).."].color",c)
		light_amount = light_amount + 1
	end
	shader:send("light_amount",light_amount)
end

function old_loadModel(filename)
	local f = assert(io.open("assets/"..filename, "r"))
	for line in f:lines() do
		local object = loadstring("return "..line)()
		table.insert(objects,object)
	end
end

function loadModel(filename)
	--Generate SDF from models
	local mesh = genSDF(filename)
	local o = {mesh=mesh, p={2,0,0}, color={1,1,1}}
	table.insert(objects, o)
end

function love.load()
	--Create canvas for scaling
	canvas = love.graphics.newCanvas(width,height)

	--Load shader
	shader = love.graphics.newShader("shaders/fragment.glsl")

	--Load testing data
	-- loadModel("floor.dmod")
	-- loadModel("test.dmod")
	-- loadModel("assets/tigre_sumatra_sketchfab.obj")
	loadModel("assets/tetrahedron.obj")

	--Send data to shader
	updateObjectsList()
	shader:send("fog_density",fog_density)
	shader:send("view_distance",view_distance)

	--Reset mouse at start so the camera doesn't get offset before starting.
	love.mouse.setPosition(width/2, height/2)

	--Reset camera direction in case it rotated.
	cam_dir = {1,0,0}
end

function rotateCamera()
	local mouseDeltaX = love.mouse.getX() - width/2
	local mouseDeltaY = love.mouse.getY() - height/2

	local qx = math.rad(mouseDeltaX*sensitivityX)
	local qy = -math.rad(mouseDeltaY*sensitivityY)

	local x = cam_dir[1]
	local z = cam_dir[3]

	--X-Axis Rotation
	cam_dir[2] = cam_dir[2] + qy

	--Y-Axis Rotation
	cam_dir[1] = x*math.cos(qx) - z*math.sin(qx)
	cam_dir[3] = z*math.cos(qx) + x*math.sin(qx)

	love.mouse.setPosition(width/2, height/2)
end

function moveCamera(dt)
	if love.keyboard.isDown("e") then
		cam_pos[2] = cam_pos[2] + 1*dt
	elseif love.keyboard.isDown("q") then
		cam_pos[2] = cam_pos[2] - 1*dt
	end
	if love.keyboard.isDown("w") then
		cam_pos[1] = cam_pos[1] + cam_dir[1]*dt
		cam_pos[2] = cam_pos[2] + cam_dir[2]*dt
		cam_pos[3] = cam_pos[3] + cam_dir[3]*dt
	elseif love.keyboard.isDown("s") then
		cam_pos[1] = cam_pos[1] - cam_dir[1]*dt
		cam_pos[2] = cam_pos[2] - cam_dir[2]*dt
		cam_pos[3] = cam_pos[3] - cam_dir[3]*dt
	end
	if love.keyboard.isDown("d") then
		cam_pos[1] = cam_pos[1] - cam_dir[3]*dt
		cam_pos[3] = cam_pos[3] + cam_dir[1]*dt
	elseif love.keyboard.isDown("a") then
		cam_pos[1] = cam_pos[1] + cam_dir[3]*dt
		cam_pos[3] = cam_pos[3] - cam_dir[1]*dt
	end
end

function love.update(dt)
	iTime = iTime + dt
	iTimeDelta = dt

	rotateCamera()
	moveCamera(dt)
	updateObjectsList()
	updateLightsList()
end

function love.draw()
	--Set variables
	--shader:send("iTime",{iTime,iTimeDelta})
	--shader:send("iResolution",{love.graphics.getWidth(),love.graphics.getHeight()})
	shader:send("cam_dir",cam_dir)
	shader:send("cam_pos",cam_pos)

	--Draw Stuff
	--love.graphics.setCanvas(canvas)
	love.graphics.setShader(shader)
	love.graphics.setColor(255,255,255,255)
	love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
	--love.graphics.setCanvas()
	--love.graphics.draw(canvas)

	--FPS Counter
	love.graphics.setShader()
	love.graphics.setColor(255,255,255,255)
	love.graphics.print(string.format("FPS: %0.2f",love.timer.getFPS()))
	if debug then
		love.graphics.print("CAM_POS: ("..tostring(cam_pos[1]).."; "..tostring(cam_pos[2]).."; "..tostring(cam_pos[3])..")",0,20)
		love.graphics.print("CAM_DIR: ("..tostring(cam_dir[1]).."; "..tostring(cam_dir[2]).."; "..tostring(cam_dir[3])..")",0,40)
	end
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	end
	if k == 'f11' then
		local modes = love.window.getFullscreenModes()
		table.sort(modes, function(a, b) return a.width*a.height < b.width*b.height end)   --Sort from smallest to largest
		if fullscreen == true then
			fullscreen = false
			love.window.setMode(800,480, {vsync=false})
			width = 800
			height = 480
			love.window.setFullscreen(false)
			canvas = love.graphics.newCanvas(width,height)
			updateObjectsList()
		else
			fullscreen = true
			width = modes[#modes].width
			height = modes[#modes].height
			print(width,height)
			love.window.setMode(width,height, {vsync=false})
			love.window.setFullscreen(true)
			canvas = love.graphics.newCanvas(width,height)
			updateObjectsList()
		end
	end
end
