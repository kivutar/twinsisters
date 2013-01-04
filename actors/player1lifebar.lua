Player1LifeBar = class('Player1LifeBar')

Player1LifeBar.background = love.graphics.newImage('sprites/player1lifebar.png')
--Player1LifeBar.background:setFilter("nearest", "nearest")

Player1LifeBar.heart = {}
for i=0, 4 do
  Player1LifeBar.heart[i] = love.graphics.newImage('sprites/heart_'..i..'.png')
  --Player1LifeBar.heart[i]:setFilter("nearest", "nearest")
end

function Player1LifeBar:initialize()
  self.character = actors.list.lolo
  self.persistant = true
  self.z = 32
end

function Player1LifeBar:draw()
  love.graphics.draw(Player1LifeBar.background, camera:ox(), camera:oy())
  love.graphics.draw(self.character.portrait, camera:ox(), camera:oy())

  local hp = self.character.HP

  for i=1,self.character.maxHP,4 do

    hp2 = (hp >= 4) and 4 or hp
    hp2 = (hp >= 0) and hp2 or 0

    hp = hp - 4

    love.graphics.draw(Player1LifeBar.heart[hp2], camera:ox() + (i/4)*16*4 + 38*4, camera:oy() + 18*4, 0, 1, 1, 0, 0)

  end
end