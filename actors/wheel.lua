Wheel = class('Wheel')

Wheel.image = love.graphics.newImage('sprites/wheel.png')
Wheel.image:setFilter("nearest", "nearest")

function Wheel:initialize(x, y, z)
  self.x = x
  self.y = y
  self.z = 31
  self.r = 0
end

function Wheel:update(dt)
  self.r = self.r - 0.5 * dt
end

function Wheel:draw()
  love.graphics.draw(Wheel.image, self.x, self.y, self.r, 1, 1, 768/2, 768/2)
end
