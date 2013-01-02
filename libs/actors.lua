requiredir('mixins') -- Require mixins
requiredir('actors') -- Require game actors

actors = {}

actors.list = {}

-- Instanciate a game object
function actors.add(o)
  a = _G[o.type]:new(o.x, o.y, 0, o.properties)
  if o.polygon then
    a.body = Collider:addPolygon(unpack(o.polygon))
    a.body.parent = a
    dx, dy = a.body:center()
    a.body:moveTo(o.x+dx, o.y+dy)
  end
  a.name = a.name or o.type..'_'..o.x..'_'..o.y..'_'..love.timer.getTime()
  actors.list[a.name] = a
end

-- Loop over tiled map object layers and instanciate game objects
function actors.addFromTiled(mapol)
  for _, ol in pairs(mapol) do
    for _, o in pairs(ol.objects) do
      actors.add(o)
    end
  end
end

function actors.removeAll()
  for name, a in pairs(actors.list) do
    if not a.persistant then
      if a.body then Collider:remove(a.body) end
      actors.list[name] = nil
    end
  end
end

function actors.switchMap(mapname)
  map = ATL.load(mapname..'.tmx')
  map.drawObjects = false

  cache = love.graphics.newImage('maps/'..mapname..'.png')
  cache:setFilter("linear", "linear")

  love.graphics.setBackgroundColor(map.properties.r or 0, map.properties.g or 0, map.properties.b or 0)

  actors.removeAll()
  actors.addFromTiled(map.ol)

  camera:follow({actors.list.lolo}, 1)
end