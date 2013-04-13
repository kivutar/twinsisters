Menu = class('Menu')

function Menu:initialize(menu)
  self.menu = menu
  self.cursor = 1
end

function Menu:update(dt)
  if controls.p1.down and self.cursor < #self.menu then
    if not self.downpressed then
      self.cursor = self.cursor + 1
      self.callback = self.menu[self.cursor].callback
      TEsound.play(sfx.cursor)
    end
    self.downpressed = true
  else
    self.downpressed = false
  end

  if controls.p1.up and self.cursor > 1 then
    if not self.uppressed then
      self.cursor = self.cursor - 1
      self.callback = self.menu[self.cursor].callback
      TEsound.play(sfx.cursor)
    end
    self.uppressed = true
  else
    self.uppressed = false
  end

  if controls.p1.circle then
    TEsound.play(sfx.pause)
    self.menu[self.cursor].callback()
  end
end

function Menu:draw()
  for i=1,#self.menu,1 do
    if self.cursor == i then
      love.graphics.setColor(255, 255, 255, 255)
    else
      love.graphics.setColor(128, 128, 128, 255)
    end
    love.graphics.print(self.menu[i].label, camera:ox() + 16*9, camera:oy() + 16*11 + (i-1)*16)
  end
  love.graphics.setColor(255, 255, 255, 255)
end
