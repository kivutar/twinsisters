class "Watertop" {}

function Watertop:__init(x, y)
	self.x = x
	self.y = y
	self.image = love.graphics.newImage('sprites/watertop.png')
	self.animation = newAnimation(self.image, 32, 32, 1.0, 2)
end

function Watertop:update(dt)
	--self.animation.update(dt)
end

function Watertop:draw()
  self.animation:draw(self.x, self.y)
end