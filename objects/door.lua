Door = class('Door')

function Door:initialize(w, x, y, z, map, tx, ty, locked)
  self.w = w
  self.x = x
  self.y = y
  self.z = z
  self.map = map
  self.tx = tx
  self.ty = ty
  self.locked = locked
end