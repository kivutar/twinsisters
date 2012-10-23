requiredir('mixins') -- Require mixins
requiredir('objects') -- Require game objects

gameobjects = {}

gameobjects.list = {}

-- Instanciate a game object
function gameobjects.addObject(o)
  no = _G[o.type]:new(o.x, o.y, 0, o.properties)
  if o.polygon then
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  end
  no.name = no.name or o.type..'_'..o.x..'_'..o.y..'_'..love.timer.getTime()
  gameobjects.list[no.name] = no
end

-- Loop over tiled map object layers and instanciate game objects
function gameobjects.addObjectsFromTiled(mapol)
  for _, ol in pairs(mapol) do
    for _, o in pairs(ol.objects) do
      gameobjects.addObject(o)
    end
  end
end
