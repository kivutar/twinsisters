UpDownSpike = class('UpDownSpike')

UpDownSpike.image = love.graphics.newImage('sprites/spike.png')
UpDownSpike.image:setFilter("nearest", "nearest")

function UpDownSpike:initialize(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.r = 0

  self.yspeed = 0.5
  self.direction = 'down'

  self.body = Collider:addCircle(self.x, self.y, 6)
  self.body.parent = self
end

function UpDownSpike:update(dt)
  if self.direction == 'up'  then self.y = self.y - self.yspeed end
  if self.direction == 'down' then self.y = self.y + self.yspeed end

  self.body:moveTo(self.x, self.y)
end

function UpDownSpike:draw()
  love.graphics.draw(UpDownSpike.image, self.x, self.y, self.r, 1, 1, 8, 8)
  self.r = self.r + 0.1
end

function UpDownSpike:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belongs to another dimention
  if o.w ~= nil and o.w ~= self.w and self.w ~= nil then return end

  -- Collision with Wall, FlyingWall or Bridge
  if o.class.name == 'Wall' or o.class.name == 'FlyingWall' or o.class.name == 'Bridge' or o.class.name == 'Slant' then
    if dy < 0 then
      self.direction = 'down'
    elseif dy > 0 then
      self.direction = 'up'
    end
    self.y = self.y - dy

  end
end
