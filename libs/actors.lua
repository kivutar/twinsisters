requiredir('mixins') -- Require mixins
requiredir('actors') -- Require game actors

actors = {}

actors.list = {}

-- Instanciate a game object
function actors.add(o)
  no = _G[o.type]:new(o.x, o.y, 0, o.properties)
  if o.polygon then
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  end
  no.name = no.name or o.type..'_'..o.x..'_'..o.y..'_'..love.timer.getTime()
  actors.list[no.name] = no
end

-- Loop over tiled map object layers and instanciate game objects
function actors.addFromTiled(mapol)
  for _, ol in pairs(mapol) do
    for _, o in pairs(ol.objects) do
      actors.add(o)
    end
  end
end