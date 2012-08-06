Crab = class('Crab')
Crab:include(Gravity)
Crab:include(Blinking)

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

  self.xspeed = 0
  self.max_xspeed = 0.5
  self.yspeed = 0
  self.friction = 10
  self.airfriction = 1
  self.acceleration = 5
  self.groundspeed = 0

  self.want_to_go = 'left'

  self.stance = 'run'
  self.direction = self.want_to_go
  self.animation = Crab.anim[self.stance][self.direction]

  self.onice = false
  self.invincible = false

  self.HP = 3

  Crab.instances = Crab.instances + 1
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
  for n in self.body:neighbors() do
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

  if self.onground and not solidAt(self.x-16, self.y+10) and self.want_to_go == 'left'  then self.want_to_go = 'right' end
  if self.onground and not solidAt(self.x+16, self.y+10) and self.want_to_go == 'right' then self.want_to_go = 'left'  end

  -- Moving on x axis
  -- Moving right
  if self.want_to_go == 'right' then
    if not (self.direction == 'left' and self.attacking) then
      self.direction = 'right'
      self.stance = 'run'
      if self.xspeed < 0 then self.xspeed = 0 end
      if math.abs(self.xspeed) <= self.max_xspeed * self.iwf then self.xspeed = self.xspeed + self.acceleration * dt * self.iwf end
    end
  -- Moving left
  elseif self.want_to_go == 'left' then
    if not (self.direction == 'right' and self.attacking) then
      self.direction = 'left'
      self.stance = 'run'
      if self.xspeed > 0 then self.xspeed = 0 end
      if math.abs(self.xspeed) <= self.max_xspeed * self.iwf then self.xspeed = self.xspeed - self.acceleration * dt * self.iwf end
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
  if math.abs(self.xspeed + self.groundspeed) * self.iwf > 0.2 then self.x = self.x + (self.xspeed + self.groundspeed) * self.iwf end


  -- AI
  if self.want_to_go and math.random(10000) == 10000 then
    if self.want_to_go == 'left' then
      self.want_to_go = 'right'
    else
      self.want_to_go = 'left'
    end
  end

  self:applyGravity(dt)

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
  self:blinkingPreDraw()
  if self.invincible then self.stance = 'hit' end
  -- Set the new animation do display, but prevent animation self overriding
  self.nextanim = Crab.anim[self.stance][self.direction]
  if self.animation ~= self.nextanim then self.animation = self.nextanim end
  -- Draw the animation
  self.animation:draw(self.x-16, self.y-24)
  self:blinkingPostDraw()
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
  elseif o.class.name == 'Sword' and not self.invincible then
    self.HP = self.HP - 1
    if self.HP <= 0 then
      TEsound.play('sounds/die.wav')
      self.want_to_go = nil
      self.invincible = true
      self.stance = 'hit'
      CRON.after(1, function()
        addObject( { type='Heart', x=self.x, y=self.y, z=self.z }, self.w )
        objects[self.name] = nil
        Collider:remove(self.body)
        Crab.instances = Crab.instances - 1
      end)
    else
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
end
