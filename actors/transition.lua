Transition = class('Transition')

Transition.canvas = love.graphics.newCanvas()

function Transition:initialize(callback)
  self.persistant = true
  self.name = 'transition'
  self.x = actors.list.lolo and actors.list.lolo.x or camera.x
  self.y = actors.list.lolo and actors.list.lolo.y or camera.y
  self.z = 15
  self.r = 1920 / 2
  self.callback = callback
  gamestate = 'transition'
end

function Transition:update(dt)

    if self.r == 0 then
      self.callback()
      self.x = actors.list.lolo and actors.list.lolo.x or camera.x
      self.y = actors.list.lolo and actors.list.lolo.y or camera.y
    end

    if self.r == - 1920 / 2 then
      gamestate = 'play'
      self:destroy()
    end

    self.r = self.r - 16
end

function Transition:draw()
  if gamestate == 'transition' then
    love.graphics.setCanvas(Transition.canvas)
    Transition.canvas:clear()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', camera:ox(), camera:oy(), 1920, 1200)
    love.graphics.setBlendMode("subtractive")
    love.graphics.circle('fill', self.x, self.y, math.abs(self.r))
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas()
    love.graphics.draw(Transition.canvas, camera:ox(), camera:oy(), 0, camera.scaleX, camera.scaleY)
  end
end

function Transition:destroy()
  actors.list[self.name] = nil
end