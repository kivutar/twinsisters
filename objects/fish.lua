Fish = class('Fish')

Fish.img = {}
Fish.img.swim = {}
Fish.img.swim.left = love.graphics.newImage('sprites/fish_swim_left.png')
Fish.img.swim.left:setFilter("nearest","nearest")
Fish.img.swim.right = love.graphics.newImage('sprites/fish_swim_right.png')
Fish.img.swim.right:setFilter("nearest","nearest")

function Fish:initialize(x, y, z)
  self.x = x + 32
  self.y = y + 32
  self.z = 10

  self.body = Collider:addCircle(self.x, self.y, 24)
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
  love.graphics.draw(Fish.img[self.stance][self.direction], self.x, self.y, 0, 1, 1, 32, 32)
end

function Fish:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Collision with Wall
  if o.class.name == 'Wall' then
    if dx < -1 then
      self.direction = 'right'
    elseif dx > 1 then
      self.direction = 'left'
    end
    self.x = self.x - dx

  end
end
