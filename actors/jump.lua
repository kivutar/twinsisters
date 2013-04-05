Jump = class('Jump')

Jump.img = love.graphics.newImage('sprites/jump.png')
Jump.img:setFilter("nearest","nearest")

function Jump:initialize(x, y, z)
  self.x = x
  self.y = y
  self.z = z
  self.opacity = 255
end

function Jump:update(dt)
  self.opacity = self.opacity - 2000*dt
  if self.opacity < 0 then self.opacity = 0 self:destroy() end
end

function Jump:draw()
  love.graphics.setColor(255, 255, 255, self.opacity)
  love.graphics.draw(self.img, self.x, self.y)
  love.graphics.setColor(255, 255, 255, 255)
end

function Jump:destroy()
  actors.list[self.name] = nil
end