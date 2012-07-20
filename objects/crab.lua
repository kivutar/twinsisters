Crab = class('Crab')

Crab.anim = {}
for stance, speed in pairs({stand=1, hit=1, run=0.2}) do
  Crab.anim[stance] = {}
  for _,direction in pairs({'left', 'right'}) do
    img = love.graphics.newImage('sprites/crab_'..stance..'_'..direction..'.png')
    img:setFilter("nearest", "nearest")
    Crab.anim[stance][direction] = newAnimation(img , 32, 32, speed, 0)
  end
end

function Crab:initialize(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = Collider:addPolygon(0,16, 32,16, 32,32, 0,32)
  self.body.parent = self

  self.gravity = 500

  self.xspeed = 0.5
  self.yspeed = 0.0

  self.stance = 'run'
  self.direction = 'left'
  self.animation = Crab.anim[self.stance][self.direction]

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
  self.animation:update(dt)
end

function Crab:draw()
  love.graphics.setColor(unpack(self.color))
  -- Set the new animation do display, but prevent animation self overriding
  self.nextanim = Crab.anim[self.stance][self.direction]
  if self.animation ~= self.nextanim then self.animation = self.nextanim end
  -- Draw the animation
  self.animation:draw(self.x-16, self.y-24)
  love.graphics.setColor(255, 255, 255, 255)
end

function Crab:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belongs to another dimention
  if o.w ~= nil and o.w ~= self.w and self.w ~= nil then return end

  -- Collision with Wall, FlyingWall or Bridge
  if o.class.name == 'Wall' or o.class.name == 'FlyingWall' or o.class.name == 'Bridge' then
    if dx < 0 then
      self.direction = 'right'
    elseif dx > 0 then
      self.direction = 'left'
    end
    if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end
    self.x, self.y = self.x - dx, self.y - dy

  -- Collision with Player
  elseif o.class.name == 'Player' then
    self.xspeed = 0
    self.cron.after(1, function() self.xspeed = 0.5 end)

  -- Collision with Sword
  elseif o.class.name == 'Sword' and not self.invincible then
    TEsound.play('sounds/hit.wav')
    self.xspeed = 0
    self.yspeed = 200*dt
    self.invincible = true
    self.stance = 'hit'
    self.cron.after(3, function()
      self.xspeed = 0.5
      self.invincible = false
      self.stance = 'run'
    end)

  end
end
