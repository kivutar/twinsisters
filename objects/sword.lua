class "Sword" {}

--Sword.image = {}
--Sword.image.left = love.graphics.newImage('sprites/sword_left.png')
--Sword.image.left:setFilter("nearest", "nearest")
--Sword.image.right = love.graphics.newImage('sprites/sword_right.png')
--Sword.image.right:setFilter("nearest", "nearest")

function Sword:__init(player)
  self.player = player
  self.direction = self.player.direction
  self.w = self.player.w
  self.x = self.direction == 'left' and self.player.x - 15 or self.player.x + 15
  self.y = self.player.y
  self.z = self.player.z

  self.body = Collider:addCircle(self.x, self.y, 10)
  self.body.parent = self
end

function Sword:update(dt)
  self.direction = self.player.direction
  self.w = self.player.w
  self.x = self.direction == 'left' and self.player.x - 15 or self.player.x + 15
  self.y = self.player.y
  self.z = self.player.z
  self.body:moveTo(self.x, self.y)
end

function Sword:draw()
  --love.graphics.draw(Sword.image[self.direction], self.x, self.y, 0, 1, 1, 8, 8)
  self.body:draw()
end

function Sword:onCollision()
end

function Sword:onCollisionStop()
end