Singleton = class('Singleton')

function Singleton:initialize(x, y, z, properties)
  self.n = properties.name or 'lolo'
  if not actors.list[self.n] then
    actors.list[self.n] = Girl:new(x, y, z, properties)
  end
end