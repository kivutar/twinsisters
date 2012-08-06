Blinking = {}

function Blinking:included()
  self.blinking = false
  self.color = {255, 255, 255, 255}
end

function Blinking:applyBlinking()
  if self.invincible or self.blinking then
    if math.floor(love.timer.getTime() * 100) % 2 == 0 then self.color = {255, 255, 255, 255} else self.color = {0, 0, 0, 0} end
  else
    self.color = {255, 255, 255, 255}
  end
end

function Blinking:blinkingPreDraw()
  love.graphics.setColor(unpack(self.color))
end

function Blinking:blinkingPostDraw()
  love.graphics.setColor(255, 255, 255, 255)
end
