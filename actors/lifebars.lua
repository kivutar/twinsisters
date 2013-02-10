LifeBars = class('LifeBars')

LifeBars.player1lifebar = love.graphics.newImage('sprites/player1lifebar.png')
LifeBars.player2lifebar = love.graphics.newImage('sprites/player2lifebar.png')

LifeBars.heart = {}
for i=0, 4 do
  LifeBars.heart[i] = love.graphics.newImage('sprites/heart_'..i..'.png')
end

function LifeBars:initialize()
  self.character1 = actors.list.lolo
  self.character2 = actors.list.oce
  self.persistant = true
  self.z = 32
end

function LifeBars:draw()
  love.graphics.draw(LifeBars.player1lifebar, camera:ox(), camera:oy())
  love.graphics.draw(self.character1.portrait, camera:ox(), camera:oy())

  local hp = self.character1.HP

  for i=1,self.character1.maxHP,4 do

    hp2 = (hp >= 4) and 4 or hp
    hp2 = (hp >= 0) and hp2 or 0

    hp = hp - 4

    love.graphics.draw(LifeBars.heart[hp2], camera:ox() + (i/4)*16*4 + 38*4, camera:oy() + 18*4, 0, 1, 1, 0, 0)

  end

  if self.character2 then
    love.graphics.draw(LifeBars.player2lifebar, camera:ox() + 1440 - LifeBars.player2lifebar:getWidth(), camera:oy())
    love.graphics.draw(self.character2.portrait, camera:ox() + 1440 - self.character2.portrait:getWidth(), camera:oy())
  end
end