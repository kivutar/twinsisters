class "Bridge" {}

function Bridge:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z
end

function Bridge:update(dt)
end

function Bridge:draw()
end

function Bridge:onCollision(dt, other, dx, dy)
end