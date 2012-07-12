class "Water" {}

function Water:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z
end

function Water:update(dt)
end

function Water:draw()
end

function Water:onCollision(dt, other, dx, dy)
end