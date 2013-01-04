WaterFall = class('WaterFall')

WaterFall.img_drop = love.graphics.newImage('sprites/drop.png')
--WaterFall.img_drop:setFilter("nearest","nearest")

function WaterFall:initialize(x, y, z)
  self.x = x + 32
  self.y = y + 32
  self.z = 30

  self.ps_drop = love.graphics.newParticleSystem(WaterFall.img_drop, 75)
  self.ps_drop:setEmissionRate          (50)
  self.ps_drop:setLifetime              (-1)
  self.ps_drop:setParticleLife          (1.15)
  self.ps_drop:setDirection             (math.pi*1/2)
  self.ps_drop:setSpread                (0.1)
  self.ps_drop:setSpeed                 (-100*4)
  self.ps_drop:setGravity               (600*3)
  self.ps_drop:setSizes                 (2)
  self.ps_drop:setColors                (255,255,255,128)
  self.ps_drop:setPosition(self.x, self.y+16)
  self.ps_drop:start()
end

function WaterFall:update(dt)
  self.ps_drop:update(dt)
end

function WaterFall:draw()
  love.graphics.draw(self.ps_drop, 0, 0)
end