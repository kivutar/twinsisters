class "Spike" {}

Spike.image = love.graphics.newImage('sprites/spike.png')
Spike.image:setFilter("nearest", "nearest")

function Spike:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = Collider:addCircle(self.x, self.y, 6)
  self.body.parent = self
end

function Spike:draw()
  love.graphics.draw(Spike.image, self.x, self.y, 0, 1, 1, 8, 8)
end