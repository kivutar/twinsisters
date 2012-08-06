AcidDrop = class('AcidDrop')
AcidDrop:include(Gravity)

AcidDrop.image = love.graphics.newImage('sprites/acid_drop.png')
AcidDrop.image:setFilter("nearest", "nearest")

AcidDrop.image_particle = love.graphics.newImage('sprites/acid_particle.png')
AcidDrop.image_particle:setFilter("nearest", "nearest")

AcidDrop.instances = 0

function AcidDrop:initialize(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.yspeed = 0
  self.max_yspeed = 75

  self.body = Collider:addCircle(self.x, self.y, 6)
  self.body.parent = self

  self.ps = love.graphics.newParticleSystem(AcidDrop.image_particle, 4)
  self.ps:setEmissionRate          (10)
  self.ps:setLifetime              (0.1)
  self.ps:setParticleLife          (1.5)
  self.ps:setDirection             (math.pi*1/2)
  self.ps:setSpread                (0.4)
  self.ps:setSpeed                 (-50,-70)
  self.ps:setGravity               (150)
  self.ps:setRadialAcceleration    (0)
  self.ps:setTangentialAcceleration(0)
  self.ps:setSizeVariation         (0)
  self.ps:setRotation              (0)
  self.ps:setSpin                  (0)
  self.ps:setSpinVariation         (0)
  self.ps:setPosition(x, y)
  self.ps:stop()

  AcidDrop.instances = AcidDrop.instances + 1
end

function AcidDrop:update(dt)
  self:applyGravity(dt)
  self.ps:update(dt)
  self.ps:setPosition(self.x, self.y)
  self.body:moveTo(self.x, self.y)
end

function AcidDrop:draw()
  love.graphics.draw(AcidDrop.image, self.x, self.y, 0, 1, 1, 8, 8)
  love.graphics.draw(self.ps, 0, 0)
end

function AcidDrop:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belongs to another dimention
  if o.w ~= nil and o.w ~= self.w and self.w ~= nil then return end

  -- Collision with most objects
  if o.class.name == 'Wall'
  or o.class.name == 'FlyingWall'
  or o.class.name == 'Player'
  or o.class.name == 'Bridge'
  or o.class.name == 'Arrow'
  or o.class.name == 'Ice'
  or o.class.name == 'Spike'
  or o.class.name == 'Sword'
  or o.class.name == 'Slant' then
  	self.yspeed = 0
  	self.y = self.y - dy
  	self.ps:start()
  	self:destroy()

  end
end

function AcidDrop:destroy()
  objects[self.name] = nil
  Collider:remove(self.body)
  AcidDrop.instances = AcidDrop.instances - 1
end