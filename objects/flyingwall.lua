class "FlyingWall" {}

FlyingWall.img = love.graphics.newImage('sprites/cloud.png')
FlyingWall.img:setFilter("nearest", "nearest")

function FlyingWall:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.xspeed = 0.5
end

function FlyingWall:update(dt)
  self.x = self.x + self.xspeed
  self.body:moveTo(self.x, self.y)
end

function FlyingWall:draw()
  love.graphics.draw(FlyingWall.img, self.x, self.y, 0, 1, 1, 64, 24)
end

function FlyingWall:onCollision(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w and self.w ~= nil then return end
  if other.type == 'Wall' or other.type == 'Bridge' then
    if dx < 0 then
      self.xspeed =  0.5
    elseif dx > 0 then
      self.xspeed = -0.5
    end
    self.x = self.x - dx
  elseif other.type == 'Player' then
  	other.parent.groundspeed = self.xspeed
  end
end

function FlyingWall:onCollisionStop(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w and self.w ~= nil then return end
  if other.type == 'Player' then
    other.parent.groundspeed = 0
  end
end