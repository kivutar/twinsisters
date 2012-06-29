class "Watertop" {}

function Watertop:__init(x, y, z)
	self.x = x
	self.y = y
    self.z = z
	--self.image = love.graphics.newImage('sprites/watertop.png')
	--self.image:setFilter("nearest","nearest")
	--self.animation = newAnimation(self.image, 16, 16, 0.1, 0)
    self.animation = anim_watertop
end

function Watertop:update(dt)
	--self.animation:update(dt)
end

function Watertop:draw()
  if math.abs(self.x-objects.oce.body:getX()) <= 250 then self.animation:draw(self.x, self.y) end
end
