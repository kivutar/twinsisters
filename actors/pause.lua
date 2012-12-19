Pause = class('Pause')

function Pause:initialize()
  self.persistant = true
  self.z = 0
  self.menu = {
    { label='Return to game', callback=function ()
      gamestate = 'play'
      TEsound.resume('bgm')
    end },
    { label='Load a game state', callback=function ()
      print('Not implemented yet')
    end },
    { label='Quit without saving', callback=function ()
      love.event.push("quit")
    end },
  }
  self.cursor = 1
end

function Pause:update(dt)
  if love.keyboard.isDown("p") or love.joystick.isDown(1,10) or love.joystick.isDown(2,10) then
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

    if love.keyboard.isDown('down') and self.cursor < #self.menu then
      if not self.downpressed then
        self.cursor = self.cursor + 1
        self.callback = self.menu[self.cursor].callback
        TEsound.play('sounds/cursor.wav')
      end
      self.downpressed = true
    else
      self.downpressed = false
    end

    if love.keyboard.isDown('up') and self.cursor > 1 then
      if not self.uppressed then
        self.cursor = self.cursor - 1
        self.callback = self.menu[self.cursor].callback
        TEsound.play('sounds/cursor.wav')
      end
      self.uppressed = true
    else
      self.uppressed = false
    end

    if love.keyboard.isDown('return') then
      TEsound.play('sounds/pause.wav')
      self.menu[self.cursor].callback()
    end

  end
end

function Pause:draw_after()
  if gamestate == 'pause' then
    love.graphics.setColor(0, 0, 0, 255*3/4)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255, 255)
    for i=1,#self.menu,1 do
      if self.cursor == i then
        love.graphics.setColor(255, 255, 0, 255)
      else
        love.graphics.setColor(255, 255, 255, 128)
      end
      love.graphics.print(self.menu[i].label, 64, 208 + (i-1)*64)
    end
    love.graphics.setColor(255, 255, 255, 255)
  end
end