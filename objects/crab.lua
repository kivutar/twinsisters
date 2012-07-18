class "Crab" {}

Crab.img = {}
Crab.img.stand = {}
Crab.img.stand.left = love.graphics.newImage('sprites/crab_stand_left.png')
Crab.img.stand.left:setFilter("nearest", "nearest")
Crab.img.stand.right = love.graphics.newImage('sprites/crab_stand_right.png')
Crab.img.stand.right:setFilter("nearest", "nearest")

function Crab:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = Collider:addPolygon(0,16, 32,16, 32,32, 0,32)
  self.body.parent = self

  self.gravity = 500

  self.xspeed = 0.5
  self.yspeed = 0.0

  self.stance = 'stand'
  self.direction = 'left'
  self.animation = Crab.img[self.stance][self.direction]

  self.invincible = false
  self.color = {255, 255, 255, 255}

  self.cron = require 'libs/cron'
end

function Crab:update(dt)
  self.cron.update(dt)

  if self.direction == 'left'  then self.x = self.x - self.xspeed end
  if self.direction == 'right' then self.x = self.x + self.xspeed end

  self.yspeed = self.yspeed + self.gravity * dt
  self.y = self.y + self.yspeed * dt

  -- Blinking
  if self.invincible then
    if love.timer.getTime()*1000 % 2 == 0 then self.color = {255, 255, 255, 255} else self.color = {0, 0, 0, 0} end
  else
    self.color = {255, 255, 255, 255}
  end

  self.body:moveTo(self.x, self.y)
end

function Crab:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.draw(Crab.img[self.stance][self.direction], self.x, self.y, 0, 1, 1, 16, 24)
  love.graphics.setColor(255, 255, 255, 255)
end

function Crab:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belongs to another dimention
  if o.w ~= nil and o.w ~= self.w and self.w ~= nil then return end

  -- Collision with Wall, FlyingWall or Bridge
  if o.type == 'Wall' or o.type == 'FlyingWall' or o.type == 'Bridge' then
    if dx < 0 then
      self.direction = 'right'
    elseif dx > 0 then
      self.direction = 'left'
    end
    if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end
    self.x, self.y = self.x - dx, self.y - dy

  -- Collision with Player
  elseif o.type == 'Player' then
    self.xspeed = 0
    self.cron.after(1, function() self.xspeed = 0.5 end)

  -- Collision with Sword
  elseif o.type == 'Sword' and not self.invincible then
    TEsound.play('sounds/hit.wav')
    self.xspeed = 0
    self.yspeed = 200*dt
    self.invincible = true
    self.cron.after(2, function() self.xspeed = 0.5 end)
    self.cron.after(4, function() self.invincible = false end)

  end
end