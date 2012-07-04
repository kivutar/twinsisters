class "Watertop" {}

Watertop.instances = 0

Watertop.img = love.graphics.newImage('sprites/watertop.png')
Watertop.img:setFilter("nearest","nearest")
Watertop.anim = newAnimation(Watertop.img, 16, 16, 0.1, 0)

function Watertop:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = Collider:addCircle(self.x, self.y, 6)
  self.body.parent = self

  Watertop.instances = Watertop.instances + 1
end

function Watertop:update(dt)
  Watertop.anim:update(dt / Watertop.instances)
end

function Watertop:draw()
  Watertop.anim:draw(self.x-8, self.y-8)
end

function Watertop:onCollision(dt, other, dx, dy)
end
