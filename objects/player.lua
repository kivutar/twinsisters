class "Player" {}

Player.anim = {}
for _,skin in pairs({'lolo', 'oce'}) do
  Player.anim[skin] = {}
  for stance, speed in pairs({stand=1.0, run=0.2, jump=0.1, fall=0.1}) do
    Player.anim[skin][stance] = {}
    for _,direction in pairs({'left', 'right'}) do
      img = love.graphics.newImage('sprites/'..skin..'_'..stance..'_'..direction..'.png')
      img:setFilter("nearest", "nearest")
      Player.anim[skin][stance][direction] = newAnimation(img , 32, 32, speed, 0)
    end
  end
end

local function sign(x)
  return x < 0 and -1 or (x > 0 and 1 or 0)
end

Player.ondown = {}
function Player:onDown()
  for _,_ in pairs(Player.ondown) do
    return true
  end
  return false
end

Player.inwater = {}
function Player:inWater()
  for _,_ in pairs(Player.inwater) do
    return true
  end
  return false
end

function Player:__init(id, skin, w, x, y, z)
  self.id = id
  self.skin = skin
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.type = "Player"

  self.body = Collider:addPolygon(0,0, 0,12, 4,16, 12,16, 16,12, 16,0)
  self.body.parent = self
  self.body.type = "Player"

  self.gravity = 500

  self.xspeed = 0.0
  self.max_xspeed = 3.0
  self.yspeed = 0.0
  self.jumpspeed = 220
  self.friction = 5
  self.airfriction = 5
  self.acceleration = 5

  self.stance = 'stand'
  self.direction = 'left'
  self.animation = Player.anim[self.skin][self.stance][self.direction]

  self.invincible = false

  self.jump_pressed = false
  self.switch_pressed = false

  self.left_btn = loadstring("return love.joystick.getAxis(1,1) == -1 or love.keyboard.isDown('left')")
  self.right_btn = loadstring("return love.joystick.getAxis(1,1) == 1 or love.keyboard.isDown('right')")
  self.jump_btn = loadstring("return love.joystick.isDown(1,2) or love.keyboard.isDown(' ')")
  self.switch_btn = loadstring("return love.joystick.isDown(1,4) or love.keyboard.isDown('v')")

  self.cron = require 'libs/cron'
end

function Player:update(dt)
  self.cron.update(dt)

  local iw = 1
  if self:inWater() then
    iw = 0.75
  end
  
  -- Moving
  if self.right_btn() and not self.invincible then
    self.direction = 'right'
    self.stance = 'run'
    if self.xspeed < 0 then self.xspeed = 0 end
    if math.abs(self.xspeed) <= self.max_xspeed * iw then self.xspeed = self.xspeed + self.acceleration * dt * iw end
  elseif self.left_btn() and not self.invincible then
    self.direction = 'left'
    self.stance = 'run'
    if self.xspeed > 0 then self.xspeed = 0 end
    if math.abs(self.xspeed) <= self.max_xspeed * iw then self.xspeed = self.xspeed - self.acceleration * dt * iw end
  else
    f = 0
    if self:onDown() then f = self.friction else f = self.airfriction end
    if self.xspeed >=  f * dt then self.xspeed = self.xspeed - f * dt end
    if self.xspeed <= -f * dt then self.xspeed = self.xspeed + f * dt end
    self.stance = 'stand'
  end
  if math.abs(self.xspeed) > 0.1 then self.x = self.x + self.xspeed end

  -- Jumping
  if self.jump_btn() then
    if not self.jump_pressed and self:onDown() then
      self.yspeed = - self.jumpspeed * iw - math.abs(self.xspeed*30*iw)
      TEsound.play('sounds/jump.wav')
    elseif not self.jump_pressed and self.inWater() then
      self.yspeed = - self.jumpspeed * iw
    end
    self.jump_pressed = true
  else
    self.jump_pressed = false
  end

  -- Switching
  if self.switch_btn() then
    if not self.switch_pressed then
      TEsound.play('sounds/switch.wav')
      if current_world == 'lolo' then current_world = 'oce' else current_world = 'lolo' end
      self.skin = current_world
      self.w = current_world
    end
    self.switch_pressed = true
  else
    self.switch_pressed = false
  end

  self.yspeed = self.yspeed + self.gravity * dt * iw
  self.y = self.y + self.yspeed * dt * iw

  self.body:moveTo(self.x, self.y)
  self.animation:update(dt)
end

function Player:draw()
  if not self:onDown() and self.yspeed > 0 then self.stance = 'fall' end
  if not self:onDown() and self.yspeed < 0 then self.stance = 'jump' end
  self.nextanim = Player.anim[self.skin][self.stance][self.direction]
  if self.animation ~= self.nextanim then self.animation = self.nextanim end
  self.animation:draw(self.x-16, self.y-23.5)
end

function Player:onCollision(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w then return end
  if other.type == 'Wall' then
    if dx ~= 0 and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
    if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end
    if dy > 0 then self.ondown[other] = true end
    self.x, self.y = self.x - dx, self.y - dy
  elseif other.type == 'Bridge' then
    if dy > 0 and self.yspeed > 0 then
      self.yspeed = 0
      self.ondown[other] = true
      self.y = self.y - dy
    end
  elseif other.type == 'Spike' then
    TEsound.play('sounds/hit.wav')
    self.x, self.y = 64, 420
  elseif other.type == 'Crab' and not self.invincible then
    TEsound.play('sounds/hit.wav')
    if dx < -0.1 then self.xspeed = 3 elseif dx > 0.1 then self.xspeed = -3 end
    self.invincible = true
    self.cron.after(2, function() self.invincible = false end)
  elseif other.type == 'Water' then
    self.inwater[other] = true
  end
end

function Player:onCollisionStop(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w then return end
  if other.type == 'Wall' or other.type == 'Bridge' then
    if dy > 0 then self.ondown[other] = nil end
  elseif other.type == 'Water' then
    self.inwater[other] = nil
  end
end