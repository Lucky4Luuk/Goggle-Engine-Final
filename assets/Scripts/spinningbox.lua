local c = {}

local function FixedUpdate(self, dt)
  self.rot.x = (self.rot.x + dt * 30) % 360
  self.rot.y = (self.rot.y + dt * 30) % 360
end

c.FixedUpdate = FixedUpdate

return c
