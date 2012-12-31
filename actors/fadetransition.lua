FadeTransition = class('FadeTransition')

function FadeTransition:initialize(callback)
  self.persistant = true
  self.name = 'transition'
  self.x = actors.list.lolo and actors.list.lolo.x or camera.x
  self.y = actors.list.lolo and actors.list.lolo.y or camera.y
  self.z = 15
  self.alpha = 255
  self.callback = callback
  gamestate = 'transition'
end

function FadeTransition:update(dt)

    if self.alpha == 0 then
      self.callback()
      self.x = actors.list.lolo and actors.list.lolo.x or camera.x
      self.y = actors.list.lolo and actors.list.lolo.y or camera.y
    end

    if self.alpha == - 255 then
      gamestate = 'play'
      self:destroy()
    end

    self.alpha = self.alpha - 5

end

function FadeTransition:draw()
  if gamestate == 'transition' then
    love.graphics.setColor(0, 0, 0, 255-math.abs(self.alpha))
    love.graphics.rectangle('fill', camera:ox(), camera:oy(), 1920, 1200)
  end
end

function FadeTransition:destroy()
  actors.list[self.name] = nil
end