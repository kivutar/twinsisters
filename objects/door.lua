Door = class('Door')

function Door:initialize(w, x, y, z, properties)
  self.w = w
  self.x = x
  self.y = y
  self.z = z
  self.map = properties.map
  self.tx = properties.tx
  self.ty = properties.ty
  self.locked = properties.locked
end
