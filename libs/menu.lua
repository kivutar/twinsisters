Menu = class('Menu')

function Menu:initialize(menu)
  self.z = 0
  self.menu = menu
  self.cursor = 1
end

function Menu:update(dt)
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

function Menu:draw()
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