WaterFallBubbles = class('WaterFallBubbles')

WaterFallBubbles.img_drop = love.graphics.newImage('sprites/drop.png')
WaterFallBubbles.img_bubble = love.graphics.newImage('sprites/bubble.png')

function WaterFallBubbles:initialize(x, y, z)
  self.x = x + 32
  self.y = y + 32
  self.z = 30

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