Watertop = class('Watertop')

Watertop.img = love.graphics.newImage('sprites/watertop.png')
Watertop.img:setFilter("nearest","nearest")
Watertop.anim = newAnimation(Watertop.img, 64, 64, 0.1, 0)

Watertop.img_drop = love.graphics.newImage('sprites/drop.png')
Watertop.img_drop:setFilter("nearest","nearest")

Watertop.img_bubble = love.graphics.newImage('sprites/bubble.png')
Watertop.img_bubble:setFilter("nearest","nearest")

Watertop.instances = 0

function Watertop:initialize(x, y, z)
  self.x = x + 32
  self.y = y + 32
  self.z = 1

  self.body = Collider:addCircle(self.x, self.y, 24)
  self.body.parent = self

  self.ps_drop = love.graphics.newParticleSystem(Watertop.img_drop, 50)
  self.ps_drop:setEmissionRate          (50)
  self.ps_drop:setLifetime              (0.1)
  self.ps_drop:setParticleLife          (0.35)
  self.ps_drop:setDirection             (math.pi*1/2)
  self.ps_drop:setSpread                (0.5)
  self.ps_drop:setSpeed                 (-100*4,-100*4)
  self.ps_drop:setGravity               (600*4,600*4)
  self.ps_drop:setRadialAcceleration    (0)
  self.ps_drop:setTangentialAcceleration(0)
  self.ps_drop:setSizeVariation         (0)
  self.ps_drop:setRotation              (0)
  self.ps_drop:setSpin                  (0)
  self.ps_drop:setSpinVariation         (0)
  self.ps_drop:setPosition(x, y)
  self.ps_drop:stop()

  self.ps_bubble = love.graphics.newParticleSystem(Watertop.img_bubble, 10)
  self.ps_bubble:setEmissionRate          (20)
  self.ps_bubble:setLifetime              (0.1)
  self.ps_bubble:setParticleLife          (1.5)
  self.ps_bubble:setDirection             (math.pi*1/2)
  self.ps_bubble:setSpread                (0.2)
  self.ps_bubble:setSpeed                 (50*4,70*4)
  self.ps_bubble:setGravity               (-50*4,-70*4)
  self.ps_bubble:setRadialAcceleration    (0)
  self.ps_bubble:setTangentialAcceleration(0)
  self.ps_bubble:setSizeVariation         (0)
  self.ps_bubble:setRotation              (0)
  self.ps_bubble:setSpin                  (0)
  self.ps_bubble:setSpinVariation         (0)
  self.ps_bubble:setPosition(x, y)
  self.ps_bubble:stop()

  Watertop.instances = Watertop.instances + 1
end

function Watertop:update(dt)
  Watertop.anim:update(dt / Watertop.instances)
  self.ps_drop:update(dt)
  self.ps_bubble:update(dt)
end

function Watertop:draw()
  Watertop.anim:draw(self.x-32, self.y-32)
  love.graphics.draw(self.ps_drop, 0, 0)
  love.graphics.draw(self.ps_bubble, 0, 0)
end

function Watertop:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Collision with Player
  if o.class.name == 'Player' then
    if math.abs(o.yspeed) > 20 or math.abs(o.xspeed) > 0.5 then
      self.ps_drop:start()
    end
    if math.abs(o.yspeed) > 20 then
      self.ps_bubble:start()
    end
  end

end
