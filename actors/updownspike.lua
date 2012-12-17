UpDownSpike = class('UpDownSpike')

UpDownSpike.image = love.graphics.newImage('sprites/spike.png')
UpDownSpike.image:setFilter("nearest", "nearest")

function UpDownSpike:initialize(x, y, z)
  self.x = x + 32
  self.y = y + 32
  self.z = 10

  self.r = 0

  self.yspeed = 2.0
  self.direction = 'down'

  self.body = Collider:addCircle(self.x, self.y, 32)
  self.body.parent = self
end

function UpDownSpike:update(dt)
  if self.direction == 'up'  then self.y = self.y - self.yspeed end
  if self.direction == 'down' then self.y = self.y + self.yspeed end

  self.body:moveTo(self.x, self.y)
end

function UpDownSpike:draw()
  love.graphics.draw(UpDownSpike.image, self.x, self.y, self.r, 1, 1, 32, 32)
  self.r = self.r + 0.1
end

function UpDownSpike:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Collision with Wall, FlyingWall or Bridge
  if o.class.name == 'Wall' or o.class.name == 'FlyingWall' or o.class.name == 'Bridge' or o.class.name == 'Slant' or o.class.name == 'Spike' then
    if dy < 0 then
      self.direction = 'down'
    elseif dy > 0 then
      self.direction = 'up'
    end
    self.y = self.y - dy

  end
end
