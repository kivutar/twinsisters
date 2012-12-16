Gravity = {}

GRAVITY = 500*4

function Gravity:applyGravity(dt)
  local weight = self.weight or 1
  local iwf = self.iwf or 1 -- In water factor
  local max_yspeed = self.max_yspeed or 200*4

  self.yspeed = self.yspeed + GRAVITY * weight * dt * iwf
end
