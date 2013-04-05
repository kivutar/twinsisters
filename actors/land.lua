Land = class('Land')

Land.img = love.graphics.newImage('sprites/land.png')
Land.img:setFilter("nearest","nearest")

function Land:initialize(x, y, z)
  self.x = x
  self.y = y
  self.z = z
  self.opacity = 255

  self.animation = newAnimation(Land.img, 48, 16, 0.05, 0)
  self.animation:setMode('once')
end

function Land:update(dt)
  self.animation:update(dt)
  self.opacity = self.opacity - 400*dt
  if self.opacity < 0 then self.opacity = 0 self:destroy() end
end

function Land:draw()
  love.graphics.setColor(255, 255, 255, self.opacity)
  self.animation:draw(self.x, self.y)
  love.graphics.setColor(255, 255, 255, 255)
end

function Land:destroy()
  actors.list[self.name] = nil
end