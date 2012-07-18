class "FlyingWall" {}

FlyingWall.img = love.graphics.newImage('sprites/cloud.png')
FlyingWall.img:setFilter("nearest", "nearest")

function FlyingWall:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.xspeed = 1
end

function FlyingWall:update(dt)
  self.x = self.x + self.xspeed
  self.body:moveTo(self.x, self.y)
end

function FlyingWall:draw()
  love.graphics.draw(FlyingWall.img, self.x, self.y, 0, 1, 1, 64, 24)
end

function FlyingWall:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belong to another dimention
  if o.w ~= nil and o.w ~= self.w and self.w ~= nil then return end

  -- Collision with Wall or Bridge
  if o.type == 'Wall' or o.type == 'Bridge' then
    if dx < 0 then
      self.xspeed =  1
    elseif dx > 0 then
      self.xspeed = -1
    end
    self.x = self.x - dx

  -- Collision with Player
  elseif o.type == 'Player' then
  	o.groundspeed = self.xspeed

  end
end

function FlyingWall:onCollisionStop(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belong to another dimention
  if o.w ~= nil and o.w ~= self.w and self.w ~= nil then return end

  -- Collision stop with Player
  if o.type == 'Player' then
    o.groundspeed = 0
  end
end