Pause = class('Pause')

function Pause:initialize()
  self.name = 'pause'
  self.persistant = true
  self.z = 0
  self.menu = Menu:new({

    { label = 'Return to game', callback = function ()
      gamestate = 'play'
      TEsound.resume('bgm')
    end },

    { label = 'Load a game state', callback = function ()
      print('Not implemented yet')
    end },

    { label = 'Quit without saving', callback = function ()
      actors.list.transition = CircleTransition:new(function () love.event.push("quit") end )
    end },

  })
end

function Pause:update(dt)
  if love.keyboard.isDown("escape") or love.joystick.isDown(1,10) or love.joystick.isDown(2,10) then
    if not self.pausepressed then
      if gamestate == 'play' then
        gamestate = 'pause'
        TEsound.pause('bgm')
        TEsound.play('sounds/pause.wav')
      elseif gamestate == 'pause' then
        gamestate = 'play'
        TEsound.resume('bgm')
      end
    end
    self.pausepressed = true
  else
    self.pausepressed = false
  end

  if gamestate == 'pause' then
    self.menu:update(dt)
  end
end

function Pause:draw_after()
  if gamestate == 'pause' then
    love.graphics.setColor(0, 0, 0, 255*3/4)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    self.menu:draw()
  end
end