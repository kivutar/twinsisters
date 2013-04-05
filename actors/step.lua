Step = class('Step')

Step.img_left = love.graphics.newImage('sprites/step_left.png')
Step.img_left:setFilter("nearest","nearest")

Step.img_right = love.graphics.newImage('sprites/step_right.png')
Step.img_right:setFilter("nearest","nearest")

function Step:initialize(x, y, z, direction)
  self.x = x
  self.y = y
  self.z = z
  self.direction = direction
  if self.direction == 'right' then self.offset = 0 else self.offset = -32 end
  self.opacity = 255

  self.animation = newAnimation(Step['img_'..self.direction], 48, 16, 0.125, 0)
  self.animation:setMode('once')
end

function Step:update(dt)
  self.animation:update(dt)
  self.opacity = self.opacity - 300*dt
  if self.opacity < 0 then self.opacity = 0 self:destroy() end
end

function Step:draw()
  love.graphics.setColor(255, 255, 255, self.opacity)
  self.animation:draw(self.x + self.offset, self.y)
  love.graphics.setColor(255, 255, 255, 255)
end

function Step:destroy()
  actors.list[self.name] = nil
end