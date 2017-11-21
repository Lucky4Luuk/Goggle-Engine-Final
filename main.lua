--LOVE 3D ENGINE

require("distance_functions")
require("renderer")
require("filesystem")

local debug = {FPS=true, CAMERA=false}

local width = 800
local height = 480
local min_width = 800
local min_height = 480
local iTime = 0
local iTimeDelta = 0
-- local canvas = nil
local cam_dir = {1,0,0}
local cam_pos = {3,1,0}
-- local shader = nil
local sensitivityX = 0.5
local sensitivityY = 0.5
local scale = {width / love.graphics.getWidth(), height / love.graphics.getHeight()}

local objects = {}
local lights = {{"Directional",{0,0,0},{-0.4,0.3,-0.6},{255,255,255}},{"Point",{-3,2,0},{3,0,0},{0,0,255}}}

local fog_density = 0.1
local view_distance = 20.0

function setSize(w, h)
	width = w
	height = h
	canvas = love.graphics.newCanvas(width,height)
	scale = {width / love.graphics.getWidth(), height / love.graphics.getHeight()}
	setCanvas(love.graphics.newCanvas(width,height))
end

function loadModel(name)
	local t = FS_loadModel(name)
	for i=1, #t do
		table.insert(objects, t[i])
	end
end

function love.load()
	--Create canvas for scaling
	setSize(width, height)
	setCanvas(love.graphics.newCanvas(width,height))

	--Load shader
	-- shader = love.graphics.newShader("shaders/fragment.glsl")
	setShader(love.graphics.newShader("shaders/fragment.glsl"))

	--Load testing data
	loadModel("floor.dmod")
	loadModel("test.dmod")

	--Send data to shader
	updateObjectsList(objects)
	send("fog_density",fog_density)
	send("view_distance",view_distance)

	--Reset mouse at start so the camera doesn't get offset before starting.
	love.mouse.setPosition(width/2, height/2)

	--Reset camera direction in case it rotated.
	cam_dir = {1,0,0}
	local dx = cam_dir[1]*math.cos(math.rad(45)) - cam_dir[3]*math.sin(math.rad(45))
	local dy = cam_dir[3]*math.cos(math.rad(45)) + cam_dir[1]*math.sin(math.rad(45))
	cam_dir[1] = dx
	cam_dir[3] = dy
	cam_pos = {3,1,-1.5}
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
	setCamera(cam_pos, cam_dir)
	updateObjectsList(objects)
	updateLightsList(lights)
end

function love.draw()
	--Set variables
	send("iTime",{iTime,iTimeDelta})
	send("iResolution",{love.graphics.getWidth(),love.graphics.getHeight()})
	-- send("cam_dir",cam_dir)
	-- send("cam_pos",cam_pos)

	--Draw Stuff
	love.graphics.setCanvas(canvas)
	render()
	love.graphics.setCanvas()
	love.graphics.draw(canvas)

	--FPS Counter
	love.graphics.setShader()
	love.graphics.setColor(255,255,255,255)
	local dy = 0
	if debug.FPS then
		love.graphics.print(string.format("FPS: %0.2f",love.timer.getFPS()), 0,dy)
		dy = dy + 20
	end
	if debug.CAMERA then
		love.graphics.print("CAM_POS: ("..tostring(cam_pos[1]).."; "..tostring(cam_pos[2]).."; "..tostring(cam_pos[3])..")",0,dy)
		dy = dy + 20
		love.graphics.print("CAM_DIR: ("..tostring(cam_dir[1]).."; "..tostring(cam_dir[2]).."; "..tostring(cam_dir[3])..")",0,dy)
		dy = dy + 20
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
			love.window.setMode(min_width,min_height, {vsync=false})
			width = min_width
			height = min_height
			love.window.setFullscreen(false)
			canvas = love.graphics.newCanvas(width,height)
		else
			fullscreen = true
			width = modes[#modes].width
			height = modes[#modes].height
			-- print(width,height)
			love.window.setMode(width,height, {vsync=false})
			-- love.window.setFullscreen(true)
		end
		setSize(width, height)
		updateObjectsList(objects)
	end
end

function love.resize(w, h)
	setSize(width, height)
	updateObjectsList(objects)
end
