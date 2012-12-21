WaterFallBubbles = class('WaterFallBubbles')

WaterFallBubbles.img_drop = love.graphics.newImage('sprites/drop.png')
WaterFallBubbles.img_drop:setFilter("nearest","nearest")

WaterFallBubbles.img_bubble = love.graphics.newImage('sprites/bubble.png')
WaterFallBubbles.img_bubble:setFilter("nearest","nearest")

function WaterFallBubbles:initialize(x, y, z)
  self.x = x + 32
  self.y = y + 32
  self.z = 11

  self.body = Collider:addCircle(self.x, self.y, 24)
  self.body.parent = self

  self.ps_drop = love.graphics.newParticleSystem(WaterFallBubbles.img_drop, 75)
  self.ps_drop:setEmissionRate          (50)
  self.ps_drop:setLifetime              (-1)
  self.ps_drop:setParticleLife          (1)
  self.ps_drop:setDirection             (0)
  self.ps_drop:setSpread                (50)
  self.ps_drop:setSpeed                 (-100*1)
  self.ps_drop:setSizes                 (1,2,3)
  self.ps_drop:setRotation              (0)
  self.ps_drop:setSpin                  (0)
  self.ps_drop:setSpinVariation         (0)
  self.ps_drop:setColors                (255,255,255,255, 255,255,255,0)
  self.ps_drop:setPosition(x+32, y+32+16)
  self.ps_drop:start()

  self.ps_bubble = love.graphics.newParticleSystem(WaterFallBubbles.img_bubble, 30)
  self.ps_bubble:setEmissionRate          (20)
  self.ps_bubble:setLifetime              (-1)
  self.ps_bubble:setParticleLife          (1.5)
  self.ps_bubble:setDirection             (math.pi*1/2)
  self.ps_bubble:setSpread                (1)
  self.ps_bubble:setSpeed                 (50*4,70*4)
  self.ps_bubble:setGravity               (-50*4,-70*4)
  self.ps_bubble:setRadialAcceleration    (0)
  self.ps_bubble:setTangentialAcceleration(0)
  self.ps_bubble:setSizeVariation         (0)
  self.ps_bubble:setRotation              (0)
  self.ps_bubble:setSpin                  (0)
  self.ps_bubble:setSpinVariation         (0)
  self.ps_bubble:setSizes                 (0.5,1)
  self.ps_bubble:setColors                (255,255,255,0, 255,255,255,255, 255,255,255,128)
  self.ps_bubble:setPosition(x, y+32+16)
  self.ps_bubble:start()
end

function WaterFallBubbles:update(dt)
  self.ps_drop:update(dt)
  self.ps_bubble:update(dt)
end

function WaterFallBubbles:draw()
  love.graphics.draw(self.ps_drop, 0, 0)
  love.graphics.draw(self.ps_bubble, 0, 0)
end

function WaterFallBubbles:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Collision with Player
  if o.class.name == 'Player' then
    if math.abs(o.yspeed) > 20*4 or math.abs(o.xspeed) > 0.5 then
      local t = TEsound.findTag('splash_'..o.name)
      if #t == 0 then TEsound.play('sounds/splash.wav', 'splash_'..o.name) end
      CRON.after(1.5, function()
        TEsound.stop('splash_'..o.name)
        TEsound.cleanup()
      end)
    end
  end

end