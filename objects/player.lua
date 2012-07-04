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

function Player:__init(id, skin, w, x, y, z)
  self.id = id
  self.skin = skin
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = Collider:addCircle(x, y, 8)
  self.body.parent = self

  self.gravity = 500

  self.xspeed = 0.0
  self.max_xspeed = 3.0
  self.yspeed = 0.0
  self.jumpspeed = 220
  self.friction = 0.1
  self.airfriction = 0.1
  self.acceleration = 0.1

  self.stance = 'stand'
  self.direction = 'left'
  self.animation = Player.anim[self.skin][self.stance][self.direction]

  self.onground = false
  self.onleft   = false
  self.onright  = false

  self.jump_pressed = false
  self.switch_pressed = false

  self.left_btn = loadstring("return love.joystick.getAxis(1,1) == -1 or love.keyboard.isDown('left')")
  self.right_btn = loadstring("return love.joystick.getAxis(1,1) == 1 or love.keyboard.isDown('right')")
  self.jump_btn = loadstring("return love.joystick.isDown(1,2) or love.keyboard.isDown(' ')")
  self.switch_btn = loadstring("return love.joystick.isDown(1,4) or love.keyboard.isDown('v')")
end

function Player:update(dt)
  
  -- Moving
  if self.right_btn() then
    self.direction = 'right'
    self.stance = 'run'
    if self.xspeed < 0 then self.xspeed = 0.0 end
    if math.abs(self.xspeed) <= self.max_xspeed and not self.onright then self.xspeed = self.xspeed + self.acceleration end
  elseif self.left_btn() then
    self.direction = 'left'
    self.stance = 'run'
    if self.xspeed > 0 then self.xspeed = 0.0 end
    if math.abs(self.xspeed) <= self.max_xspeed and not self.onleft then self.xspeed = self.xspeed - self.acceleration end
  else
    f = 0
    if self.onground then f = self.friction else f = self.airfriction end
    if self.xspeed >=  f then self.xspeed = self.xspeed - f end
    if self.xspeed <= -f then self.xspeed = self.xspeed + f end
    self.stance = 'stand'
  end
  self.x = self.x + self.xspeed

  -- Jumping
  if self.jump_btn() then
    if not self.jump_pressed and self.onground then
      self.y = self.y - 1
      self.yspeed = - self.jumpspeed - math.abs(self.xspeed*20)
      TEsound.play('sounds/jump.wav')
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
      self.onground = false
      self.onleft = false
      self.onright = false
    end
    self.switch_pressed = true
  else
    self.switch_pressed = false
  end

  -- Falling
  if not self.onground then
    self.y = self.y + self.yspeed * dt
    self.yspeed = self.yspeed + self.gravity * dt
  end

  self.body:moveTo(self.x, self.y)
  self.animation:update(dt)
end

function Player:draw()
  if not self.onground and self.yspeed > 0 then self.stance = 'fall' end
  if not self.onground and self.yspeed < 0 then self.stance = 'jump' end
  self.nextanim = Player.anim[self.skin][self.stance][self.direction]
  if self.animation ~= self.nextanim then self.animation = self.nextanim end
  self.animation:draw(self.x-16, self.y-24.5)
end

function Player:onCollision(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w then return end
  if other.type == 'Wall' then
    if dx < -1 then
      self.x = self.x - dx - 0.5
      self.onleft = true
      self.xspeed = 0
    elseif dx >  1 then
      self.x = self.x - dx + 0.5
      self.onright = true
      self.xspeed = 0
    end
    if dy < -1 then
      self.y = self.y - dy - 0.5
      self.yspeed = 0
    elseif dy > 1 then
      self.y = self.y - dy + 0.5
      self.onground = true
      self.yspeed = 0
    end
  elseif other.type == 'Spike' then
    TEsound.play('sounds/hit.wav')
    self.x, self.y = 64, 420
  end
end

function Player:onCollisionStop(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w then return end
  if other.type == 'Wall' then
    if dy >  0.01 then self.onground = false end
    if dx >  0.01 then self.onright = false end
    if dx < -0.01 then self.onleft = false end
  end
end
