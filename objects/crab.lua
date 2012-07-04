class "Crab" {}

Crab.img = {}
Crab.img.stand = {}
Crab.img.stand.left = love.graphics.newImage('sprites/crab_stand_left.png')
Crab.img.stand.left:setFilter("nearest", "nearest")
Crab.img.stand.right = love.graphics.newImage('sprites/crab_stand_right.png')
Crab.img.stand.right:setFilter("nearest", "nearest")

function Crab:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = Collider:addCircle(x, y, 16)
  self.body.parent = self

  self.gravity = 500

  self.xspeed = 0.3
  self.yspeed = 0.0

  self.stance = 'stand'
  self.direction = 'left'
  self.animation = Crab.img[self.stance][self.direction]

  self.onground = false
  self.onleft   = false
  self.onright  = false
end

function Crab:update(dt)
  if self.direction == 'left'  then self.x = self.x - self.xspeed end
  if self.direction == 'right' then self.x = self.x + self.xspeed end

  self.body:moveTo(self.x, self.y)
end

function Crab:draw()
  love.graphics.draw(Crab.img[self.stance][self.direction], self.x, self.y, 0, 1, 1, 16, 16)
end

function Crab:onCollision(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w then return end
  if other.type == 'Wall' then
    if dx < -1 then
      self.x = self.x - dx - 0.5
      self.onleft = true
      self.direction = 'right'
    elseif dx >  1 then
      self.x = self.x - dx + 0.5
      self.onright = true
      self.direction = 'left'
    end
    if dy < -1 then
      self.y = self.y - dy - 0.5
      self.yspeed = 0
    elseif dy > 1 then
      self.y = self.y - dy + 0.5
      self.onground = true
      self.yspeed = 0
    end
  end
end

function Crab:onCollisionStop(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w then return end
  if other.type == 'Wall' then
    if dy >  0.01 then self.onground = false end
    if dx >  0.01 then self.onright = false end
    if dx < -0.01 then self.onleft = false end
  end
end