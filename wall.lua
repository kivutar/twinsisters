class "Wall" {}

function Wall:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z
end

function Wall:update(dt)
end

function Wall:draw()
end

function Wall:onCollision(dt, other, dx, dy)
end