Door = class('Door')

function Door:initialize(x, y, z, properties)
  self.x = x
  self.y = y
  self.z = z
  self.map = properties.map
  self.tx = properties.tx
  self.ty = properties.ty
  self.locked = properties.locked
end
