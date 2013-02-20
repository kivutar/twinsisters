Bridge = class('Bridge')

function Bridge:initialize(x, y, z)
  self.x = x
  self.y = y
  self.z = z
end

function Bridge:draw()
  love.graphics.setColor(128, 128, 128, 255)
  self.body:draw('fill')
  love.graphics.setColor(255, 255, 255, 255)
end