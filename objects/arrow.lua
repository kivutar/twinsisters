Arrow = class('Arrow')

Arrow.image = love.graphics.newImage('sprites/arrow.png')
Arrow.image:setFilter("nearest", "nearest")

function Arrow:initialize(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = Collider:addCircle(self.x, self.y, 32)
  self.body.parent = self
end

function Arrow:draw()
  love.graphics.draw(Arrow.image, self.x, self.y, 0, 1, 1, 32, 32)
end