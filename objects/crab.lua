Crab = class('Crab')
Crab:include(Gravity)
Crab:include(Blinking)

Crab.anim = {}
for stance, speed in pairs({stand=1, hit=1, run=0.1}) do
  Crab.anim[stance] = {}
  for _,direction in pairs({'left', 'right'}) do
    img = love.graphics.newImage('sprites/crab_'..stance..'_'..direction..'.png')
    img:setFilter("nearest", "nearest")
    Crab.anim[stance][direction] = newAnimation(img , 32*4, 32*4, speed, 0)
  end
end

Crab.instances = 0

Crab.blood_particle = love.graphics.newImage('sprites/blood_particle.png')
Crab.blood_particle:setFilter("nearest","nearest")

Crab.smoke_particle = love.graphics.newImage('sprites/smoke_particle.png')
Crab.smoke_particle:setFilter("nearest","nearest")

function Crab:initialize(x, y, z)
  self.x = x + 16
  self.y = y + 24
  self.z = 10

  self.body = Collider:addPolygon(0,16*4, 32*4,16*4, 32*4,32*4, 0,32*4)
  self.body.parent = self

  self.xspeed = 0
  self.max_xspeed = 0.5*4
  self.yspeed = 0
  self.friction = 10*4
  self.airfriction = 1*4
  self.acceleration = 5*4
  self.groundspeed = 0

  self.want_to_go = 'left'

  self.stance = 'run'
  self.direction = self.want_to_go
  self.animation = Crab.anim[self.stance][self.direction]

  self.onice = false
  self.invincible = false

  self.HP = 3

  Crab.instances = Crab.instances + 1

  self.blood = love.graphics.newParticleSystem(Crab.blood_particle, 99)
  self.blood:setEmissionRate          (99)
  self.blood:setLifetime              (0.15)
  self.blood:setParticleLife          (0.05, 0.15)
  self.blood:setDirection             (math.pi/2)
  self.blood:setSpread                (math.pi*2)
  self.blood:setSpeed                 (200*4)
  self.blood:setGravity               (300*4)
  self.blood:setRadialAcceleration    (0)
  self.blood:setTangentialAcceleration(100*4)
  self.blood:setSizeVariation         (0)
  self.blood:setRotation              (0)
  self.blood:setSpin                  (0)
  self.blood:setSpinVariation         (0)
  self.blood:stop()

  self.smoke = love.graphics.newParticleSystem(Crab.smoke_particle, 99)
  self.smoke:setEmissionRate          (99)
  self.smoke:setLifetime              (0.3)
  self.smoke:setParticleLife          (0.1, 0.3)
  self.smoke:setDirection             (math.pi/2)
  self.smoke:setSpread                (math.pi*2)
  self.smoke:setSpeed                 (75*4)
  self.smoke:setGravity               (-400*4)
  self.smoke:setRadialAcceleration    (0)
  self.smoke:setTangentialAcceleration(100*4)
  self.smoke:setSizeVariation         (2*4)
  self.smoke:setRotation              (0)
  self.smoke:setSpin                  (0)
  self.smoke:setSpinVariation         (0)
  self.smoke:stop()
  
  self.color = {255, 255, 255, 255} -- TODO debug the mixin

end

function solidAt(x, y)
  for k,v in pairs(Collider:shapesAt(x, y)) do
    if v.parent.class.name == 'Wall'
    or v.parent.class.name == 'Bridge'
    or v.parent.class.name == 'Slant'
    or v.parent.class.name == 'Ice'
    or v.parent.class.name == 'FlyingWall' then
      return true
    end
  end
  return false
end

function Crab:update(dt)
  self.onground = false
  self.onbridge = false
  self.inwater  = false
  self.onice = false
  for _,n in pairs(self.body:neighbors()) do
    collides, dx, dy = self.body:collidesWith(n)
    if collides and dy < 0 then
      if n.parent.class.name == 'Wall'
      or n.parent.class.name == 'Bridge'
      or n.parent.class.name == 'Slant'
      or n.parent.class.name == 'Ice'
      or n.parent.class.name == 'FlyingWall' then
        self.onground = true
        self.swimming = false
      end
      if n.parent.class.name == 'Bridge' then
        self.onbridge = true
        self.swimming = false
      end
      if n.parent.class.name == 'Ice' then
        self.onice = true
        self.swimming = false
      end
    end
    if n.parent.class.name == 'Water' then
      self.inwater = true
    end
  end

  self.iwf = self.inwater and 0.5 or 1

  if self.onground and not solidAt(self.x-16*4, self.y+10*4) and self.want_to_go == 'left'  then self.want_to_go = 'right' end
  if self.onground and not solidAt(self.x+16*4, self.y+10*4) and self.want_to_go == 'right' then self.want_to_go = 'left'  end

  -- Moving on x axis
  -- Moving right
  if self.want_to_go == 'right' then
    if not (self.direction == 'left' and self.attacking) then
      self.direction = 'right'
      self.stance = 'run'
      if self.xspeed < 0 then self.xspeed = 0 end
      self.xspeed = self.xspeed + self.acceleration * dt * self.iwf
    end
  -- Moving left
  elseif self.want_to_go == 'left' then
    if not (self.direction == 'right' and self.attacking) then
      self.direction = 'left'
      self.stance = 'run'
      if self.xspeed > 0 then self.xspeed = 0 end
      self.xspeed = self.xspeed - self.acceleration * dt * self.iwf
    end
  -- Stop moving
  else
    f = 0
    if self.onground then f = self.friction else f = self.airfriction end
    if self.xspeed >=  f * dt then self.xspeed = self.xspeed - f * dt end
    if self.xspeed <= -f * dt then self.xspeed = self.xspeed + f * dt end
    self.stance = 'stand'
  end
  -- Apply maximum xspeed
  if math.abs(self.xspeed) > self.max_xspeed * self.iwf then self.xspeed = sign(self.xspeed) * self.max_xspeed * self.iwf end
  -- Apply minimum xspeed, to prevent bugs
  if math.abs(self.xspeed + self.groundspeed) * self.iwf > 0.2*4 then self.x = self.x + (self.xspeed + self.groundspeed) * self.iwf end


  -- AI
  if self.want_to_go and math.random(10000) == 10000 then
    if self.want_to_go == 'left' then
      self.want_to_go = 'right'
    else
      self.want_to_go = 'left'
    end
  end

  self:applyGravity(dt)

  local iwf = self.iwf or 1 -- In water factor
  local max_yspeed = self.max_yspeed or 200*4
  if self.yspeed > max_yspeed * iwf then self.yspeed = max_yspeed * iwf end
  self.y = self.y + self.yspeed * dt * iwf

  self:applyBlinking()

  self.blood:update(dt)
  self.blood:setPosition(self.x, self.y)

  self.smoke:update(dt)
  self.smoke:setPosition(self.x, self.y)

  self.body:moveTo(self.x, self.y)
  self.animation:update(dt / Crab.instances)
end

function Crab:draw()
  self:blinkingPreDraw()
  if self.invincible then self.stance = 'hit' end
  -- Set the new animation do display, but prevent animation self overriding
  self.nextanim = Crab.anim[self.stance][self.direction]
  if self.animation ~= self.nextanim then self.animation = self.nextanim end
  -- Draw the animation
  self.animation:draw(self.x-16*4, self.y-24*4)
  self:blinkingPostDraw()
  love.graphics.draw(self.blood, 0, 0)
  love.graphics.draw(self.smoke, 0, 0)
end

function Crab:drawhallo()
  --r = math.random(0, 5)
  --love.graphics.setColor(128, 128, 128, 128)
  --love.graphics.circle("fill", self.x, self.y, 200 + r)
  --love.graphics.setColor(255, 255, 255)
  --love.graphics.circle("fill", self.x, self.y, 150 + r)
  love.graphics.draw(hallo, self.x, self.y, 0, 1, 1, 256, 256)
end

function Crab:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Collision with Wall, FlyingWall or Bridge
  if o.class.name == 'Wall'
  or o.class.name == 'FlyingWall'
  or o.class.name == 'Bridge'
  or o.class.name == 'Arrow'
  or o.class.name == 'Ice'
  or o.class.name == 'Spike'
  or o.class.name == 'Slant' then
    if dx < 0 then
      self.want_to_go = 'right'
    elseif dx > 0 then
      self.want_to_go = 'left'
    end
    if dx ~= 0 and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
    if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end
    self.x, self.y = self.x - dx, self.y - dy

  -- Collision with Sword
  elseif (o.class.name == 'Sword' or o.class.name == 'FireBall') and not self.invincible then
    self.HP = self.HP - 1
    if self.HP <= 0 then
      TEsound.play('sounds/die.wav')
      self.want_to_go = nil
      self.xspeed = o.direction == 'right' and 5*4 or -5*4
      self.invincible = true
      self.stance = 'hit'
      self.smoke:start()
      CRON.after(1, function()
        gameobjects.addObject( { type='Heart', x=self.x, y=self.y, z=self.z } )
        gameobjects.list[self.name] = nil
        Collider:remove(self.body)
        Crab.instances = Crab.instances - 1
      end)
    else
      TEsound.play('sounds/hit.wav')
      self.want_to_go = nil
      self.xspeed = o.direction == 'right' and 5*4 or -5*4
      self.yspeed = -100*4
      self.invincible = true
      self.stance = 'hit'
      self.blood:start()
      CRON.after(1, function()
        self.want_to_go = math.random(2) == 2 and 'left' or 'right'
        self.invincible = false
        self.stance = 'run'
      end)
    end

  end
end

