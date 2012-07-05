class "Fish" {}

Fish.img = {}
Fish.img.swim = {}
Fish.img.swim.left = love.graphics.newImage('sprites/fish_swim_left.png')
Fish.img.swim.left:setFilter("nearest","nearest")
Fish.img.swim.right = love.graphics.newImage('sprites/fish_swim_right.png')
Fish.img.swim.right:setFilter("nearest","nearest")

function Fish:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = Collider:addCircle(self.x, self.y, 6)
  self.body.parent = self

  self.xspeed = 0.1

  self.direction = 'left'
  self.stance = 'swim'
end

function Fish:update(dt)
  if self.direction == 'left'  then self.x = self.x - self.xspeed end
  if self.direction == 'right' then self.x = self.x + self.xspeed end

  self.body:moveTo(self.x, self.y)
end

function Fish:draw()
  love.graphics.draw(Fish.img[self.stance][self.direction], self.x, self.y, 0, 1, 1, 8, 8)
end

function Fish:onCollision(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w then return end
  if other.type == 'Wall' then
    if dx < -1 then
      self.direction = 'right'
      self.x = self.x - dx
    elseif dx > 1 then
      self.direction = 'left'
      self.x = self.x - dx
    end
  end
end
