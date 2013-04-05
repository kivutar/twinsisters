SnowBackground = class('SnowBackground')

SnowBackground.sky = love.graphics.newImage('backgrounds/snowsky.png')

SnowBackground.flake = love.graphics.newImage('sprites/flake.png')

function SnowBackground:initialize(x, y, z)
  self.z = 0

  self.ps_flake1 = love.graphics.newParticleSystem(SnowBackground.flake, 2000)
  self.ps_flake1:setEmissionRate          (40)
  self.ps_flake1:setLifetime              (-1)
  self.ps_flake1:setParticleLife          (15)
  self.ps_flake1:setDirection             (math.pi*2)
  self.ps_flake1:setSpread                (50)
  self.ps_flake1:setSpeed                 (100)
  self.ps_flake1:setGravity               (10)
  self.ps_flake1:setRadialAcceleration    (10)
  self.ps_flake1:setSizes                 (1)
  self.ps_flake1:setSpin                  (3)
  self.ps_flake1:start()
  
  self.ps_flake2 = love.graphics.newParticleSystem(SnowBackground.flake, 400)
  self.ps_flake2:setEmissionRate          (8)
  self.ps_flake2:setLifetime              (-1)
  self.ps_flake2:setParticleLife          (15)
  self.ps_flake2:setDirection             (math.pi*2)
  self.ps_flake2:setSpread                (50)
  self.ps_flake2:setSpeed                 (100)
  self.ps_flake2:setGravity               (30)
  self.ps_flake2:setRadialAcceleration    (10)
  self.ps_flake2:setSizes                 (2)
  self.ps_flake2:setSpin                  (3)
  self.ps_flake2:start()
  
  self.ps_flake3 = love.graphics.newParticleSystem(SnowBackground.flake, 200)
  self.ps_flake3:setEmissionRate          (4)
  self.ps_flake3:setLifetime              (-1)
  self.ps_flake3:setParticleLife          (15)
  self.ps_flake3:setDirection             (math.pi*2)
  self.ps_flake3:setSpread                (50)
  self.ps_flake3:setSpeed                 (100)
  self.ps_flake3:setGravity               (50)
  self.ps_flake3:setRadialAcceleration    (10)
  self.ps_flake3:setSizes                 (3)
  self.ps_flake3:setSpin                  (3)
  self.ps_flake3:start()
end

function SnowBackground:update(dt)
--  self.ps_flake1:update(dt)
--  self.ps_flake2:update(dt)
--  self.ps_flake3:update(dt)
end

function SnowBackground:draw()
  love.graphics.draw(SnowBackground.sky, camera:ox(), camera:oy())
  love.graphics.draw(self.ps_flake1, 1920/2 +camera:ox()/100, camera:oy()-1080)
  love.graphics.draw(self.ps_flake2, 1920/2 +camera:ox()/ 66, camera:oy()-1080)
  love.graphics.draw(self.ps_flake3, 1920/2 +camera:ox()/ 33, camera:oy()-1080)
end
  