Gap = class('Gap')

function Gap:initialize(x, y, z, properties)
  self.x = x
  self.y = y
  self.z = z
  self.target = properties.target or 'testdj'
  self.newx = properties.newx
  self.newy = properties.newy
  self.plusx = properties.plusx
  self.plusy = properties.plusy
end

function Gap:draw()
  love.graphics.setColor(255, 255, 0, 255)
  self.body:draw('fill')
  love.graphics.setColor(255, 255, 255, 255)
end