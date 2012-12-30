Transition = class('Transition')

Transition.canvas = love.graphics.newCanvas()

function Transition:initialize(x, y, z, callback)
  self.x = x or 0
  self.y = y or 0
  self.z = z or 15
  self.r = love.graphics.getWidth() / 2
  self.callback = callback
  gamestate = 'transition'
end

function Transition:update(dt)
  self.r = self.r - 3000 * dt
  if self.r <= 0 then
    self.r = 0
    self:draw()
    self.callback()
  end
end

function Transition:draw()
  if gamestate == 'transition' then 
    love.graphics.setCanvas(Transition.canvas)
    Transition.canvas:clear()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', camera:ox(), camera:oy(), love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setBlendMode("subtractive")
    love.graphics.circle('fill', self.x, self.y, self.r)
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas()
    love.graphics.draw(Transition.canvas, camera:ox(), camera:oy())
  end
end