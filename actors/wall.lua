Wall = class('Wall')

function Wall:initialize(x, y, z)
  self.x = x
  self.y = y
  self.z = z
end

function Wall:draw()
  love.graphics.setColor(255, 255, 255, 128)
  --self.body:draw('fill')
  love.graphics.setColor(255, 255, 255, 255)
end