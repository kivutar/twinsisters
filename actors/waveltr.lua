WaveLTR = class('WaveLTR')

WaveLTR.img = love.graphics.newImage('sprites/watertop.png')
WaveLTR.img:setFilter("nearest","nearest")
WaveLTR.anim = newAnimation(WaveLTR.img, 64, 64, 0.1, 0)
WaveLTR.anim.direction = -1

WaveLTR.img_drop = love.graphics.newImage('sprites/drop.png')
WaveLTR.img_bubble = love.graphics.newImage('sprites/bubble.png')

WaveLTR.instances = 0

function WaveLTR:initialize(x, y, z)
  self.x = x + 32
  self.y = y + 32
  self.z = 30

  self.body = Collider:addCircle(self.x, self.y, 24)
  self.body.parent = self

  self.ps_drop = love.graphics.newParticleSystem(WaveLTR.img_drop, 50)
  self.ps_drop:setEmissionRate          (50)
  self.ps_drop:setLifetime              (0.1)
  self.ps_drop:setParticleLife          (0.35)
  self.ps_drop:setDirection             (math.pi*1/2)
  self.ps_drop:setSpread                (0.5)
  self.ps_drop:setSpeed                 (-100*4,-100*4)
  self.ps_drop:setGravity               (600*4,600*4)
  self.ps_drop:setSizes                 (1,1.5)
  self.ps_drop:setPosition(self.x, self.y)
  self.ps_drop:stop()

  self.ps_bubble = love.graphics.newParticleSystem(WaveLTR.img_bubble, 10)
  self.ps_bubble:setEmissionRate          (20)
  self.ps_bubble:setLifetime              (0.1)
  self.ps_bubble:setParticleLife          (1.5)
  self.ps_bubble:setDirection             (math.pi*1/2)
  self.ps_bubble:setSpread                (0.2)
  self.ps_bubble:setSpeed                 (50*4,70*4)
  self.ps_bubble:setGravity               (-50*4,-70*4)
  self.ps_bubble:setSizes                 (0.5,1)
  self.ps_bubble:setColors                (255,255,255,255, 255,255,255,128)
  self.ps_bubble:setPosition(self.x, self.y)
  self.ps_bubble:stop()

  WaveLTR.instances = WaveLTR.instances + 1
end

function WaveLTR:update(dt)
  WaveLTR.anim:update(dt / WaveLTR.instances)
  self.ps_drop:update(dt)
  self.ps_bubble:update(dt)
end

function WaveLTR:draw()
  WaveLTR.anim:draw(self.x-32, self.y-32)
  love.graphics.draw(self.ps_drop, 0, 0)
  love.graphics.draw(self.ps_bubble, 0, 0)
end

function WaveLTR:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Collision with Player
  if o.class.name == 'Player' then
    if math.abs(o.yspeed) > 20*4 or math.abs(o.xspeed) > 0.5 then
      self.ps_drop:start()
      local t = TEsound.findTag('splash_'..o.name)
      if #t == 0 then TEsound.play(sfx.splash, 'splash_'..o.name) end
      CRON.after(1.5, function()
        TEsound.stop('splash_'..o.name)
        TEsound.cleanup()
      end)
    end
    if math.abs(o.yspeed) > 20 then
      self.ps_bubble:start()
    end
  end

end