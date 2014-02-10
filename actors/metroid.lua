Metroid = class('Metroid')

Metroid.img = love.graphics.newImage('sprites/metroid.png')
Metroid.img:setFilter('nearest', 'nearest')

function Metroid:initialize(x, y, z)
  self.x = x + 8
  self.y = y + 8
  self.z = 30

  self.r = 0

  self.speed = 1

  self.body = Collider:addPolygon(0,16, 16,16, 16,0, 0,0)
  self.body.parent = self
end

function solidAt(x, y)
  for k,v in pairs(Collider:shapesAt(x, y)) do
    if v.parent.class.name == 'Wall'
    or v.parent.class.name == 'Bridge'
    or v.parent.class.name == 'Slant'
    or v.parent.class.name == 'Ice'
    or v.parent.class.name == 'FlyingWall' then
      return true
    end
  end
  return false
end

function Metroid:update(dt)
  self.r = self.r + 0.08*self.speed

  if solidAt(self.x-8, self.y+9) then
    self.x = self.x + self.speed

  elseif solidAt(self.x-9, self.y-7) or solidAt(self.x-9, self.y+9) then
    self.y = self.y + self.speed

  elseif solidAt(self.x-9, self.y-9) or solidAt(self.x+7, self.y-9) then
    self.x = self.x - self.speed

  elseif solidAt(self.x+9, self.y+8) or solidAt(self.x+9, self.y-8) then
    self.y = self.y - self.speed

  elseif solidAt(self.x+8, self.y+9) then
    self.x = self.x + self.speed

  end
  self.body:moveTo(self.x, self.y)
end

function Metroid:draw()
  love.graphics.draw(Metroid.img, self.x, self.y, self.r, 1, 1, 10, 10)
end
