Zombie = class('Zombie')

Zombie.anim = {}
for _,skin in pairs({'zombie'}) do
  Zombie.anim[skin] = {}
  for stance, speed in pairs({run=0.8}) do
    Zombie.anim[skin][stance] = {}
    for _,direction in pairs({'left'}) do
      img = love.graphics.newImage('sprites/'..skin..'_'..stance..'_'..direction..'.png')
      img:setFilter("nearest", "nearest")
      Zombie.anim[skin][stance][direction] = newAnimation(img , 64, 64, speed, 0)
    end
  end
end

function Zombie:initialize(x, y, z)
  self.x = x + 32
  self.y = y + 16
  self.z = 30
  self.animation = Zombie.anim.zombie.run.left

  self.body = Collider:addPolygon(0,-4*4, 0,12*4, 4*4,16*4, 12*4,16*4, 16*4,12*4, 16*4,-4*4 ,12*4,-8*4, 4*4,-8*4)
  self.body.parent = self
end

function Zombie:update(dt)
	self.animation.timer = self.animation.timer + dt * self.animation.speed
	if self.animation.timer > self.animation.delays[self.animation.position] then
		self.x = self.x - 32
	end
	self.animation.timer = self.animation.timer - dt * self.animation.speed

  self.body:moveTo(self.x, self.y)
  self.animation:update(dt)
end

function Zombie:draw()
  self.animation:draw(self.x-16*4, self.y-16*4-16, 0, 2, 2)
  self.body:draw()
end