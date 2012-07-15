class "Door" {}

function Door:__init(w, x, y, z, map, tx, ty)
  self.w = w
  self.x = x
  self.y = y
  self.z = z
  self.map = map
  self.tx = tx
  self.ty = ty
end

function Door:update(dt)
end

function Door:draw()
end

function Door:onCollision()
end

function Door:onCollisionStop()
end