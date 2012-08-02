Crab = class('Crab')

Crab.anim = {}
for stance, speed in pairs({stand=1, hit=1, run=0.1}) do
  Crab.anim[stance] = {}
  for _,direction in pairs({'left', 'right'}) do
    img = love.graphics.newImage('sprites/crab_'..stance..'_'..direction..'.png')
    img:setFilter("nearest", "nearest")
    Crab.anim[stance][direction] = newAnimation(img , 32, 32, speed, 0)
  end
end

Crab.instances = 0

function Crab:initialize(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = Collider:addPolygon(0,16, 32,16, 32,32, 0,32)
  self.body.parent = self

  self.gravity = 500

  self.xspeed = 0
  self.max_xspeed = 0.5
  self.yspeed = 0
  self.friction = 10
  self.airfriction = 1
  self.acceleration = 1
  self.groundspeed = 0

  self.want_to_go = 'left'

  self.stance = 'run'
  self.direction = self.want_to_go
  self.animation = Crab.anim[self.stance][self.direction]

  self.daft = false
  self.onice = false
  self.invincible = false
  self.color = {255, 255, 255, 255}

  Crab.instances = Crab.instances + 1
end

function Crab:update(dt)
  local iw = self.inwater and 0.5 or 1

  if self.onice then
    self.friction = 0
    self.max_xspeed = 1
  else
    self.friction = 10
    self.max_xspeed = 0.5
  end

  -- Moving on x axis
  -- Moving right
  if self.want_to_go == 'right' then
    if not (self.direction == 'left' and self.attacking) then
      self.direction = 'right'
      self.stance = 'run'
      if self.xspeed < 0 and not self.onice then self.xspeed = 0 end
      if math.abs(self.xspeed) <= self.max_xspeed * iw then self.xspeed = self.xspeed + self.acceleration * dt * iw end
    end
  -- Moving left
  elseif self.want_to_go == 'left' then
    if not (self.direction == 'right' and self.attacking) then
      self.direction = 'left'
      self.stance = 'run'
      if self.xspeed > 0 and not self.onice then self.xspeed = 0 end
      if math.abs(self.xspeed) <= self.max_xspeed * iw then self.xspeed = self.xspeed - self.acceleration * dt * iw end
    end
  -- Stop moving
  else
    f = 0
    if self.onground then f = self.friction else f = self.airfriction end
    if self.xspeed >=  f * dt then self.xspeed = self.xspeed - f * dt end
    if self.xspeed <= -f * dt then self.xspeed = self.xspeed + f * dt end
    self.stance = 'stand'
  end
  -- Apply minimum xspeed, to prevent bugs
  if math.abs(self.xspeed + self.groundspeed) > 0.2 then self.x = self.x + self.xspeed + self.groundspeed end

  -- AI
  if self.want_to_go and math.random(10000) == 10000 then
    if self.want_to_go == 'left' then
      self.want_to_go = 'right'
    else
      self.want_to_go = 'left'
    end
  end

  -- Falling
  self.yspeed = self.yspeed + self.gravity * dt
  self.y = self.y + self.yspeed * dt

  -- Blinking
  if self.invincible then
    if math.floor(love.timer.getTime() * 100) % 2 == 0 then self.color = {255, 255, 255, 255} else self.color = {0, 0, 0, 0} end
  else
    self.color = {255, 255, 255, 255}
  end

  self.body:moveTo(self.x, self.y)
  self.animation:update(dt / Crab.instances)
end

function Crab:draw()
  love.graphics.setColor(unpack(self.color))
  if self.invincible then self.stance = 'hit' end
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
  if o.class.name == 'Wall'
  or o.class.name == 'FlyingWall'
  or o.class.name == 'Bridge'
  or o.class.name == 'Arrow'
  or o.class.name == 'Slant' then
    if dx < 0 then
      self.want_to_go = 'right'
    elseif dx > 0 then
      self.want_to_go = 'left'
    end
    if dx ~= 0 and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
    if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end
    self.x, self.y = self.x - dx, self.y - dy

  -- Collision with Player
  --elseif o.class.name == 'Player' then
  --  self.xspeed = 0
  --  CRON.after(1, function() self.xspeed = 0.5 end)

  -- Collision with Sword
  elseif o.class.name == 'Sword' and not self.invincible then
    TEsound.play('sounds/hit.wav')
    self.want_to_go = nil
    self.xspeed = o.direction == 'right' and 1 or -1
    self.yspeed = -100
    self.invincible = true
    self.stance = 'hit'
    CRON.after(1, function()
      self.want_to_go = math.random(2) == 2 and 'left' or 'right'
      self.invincible = false
      self.stance = 'run'
    end)

  end
end
