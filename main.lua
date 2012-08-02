function addObject(o, w)
  if o.type == 'Wall' then
    no = Wall:new(w, 0, 0, 10)
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  elseif o.type == 'Bridge' then
    no = Bridge:new(w, 0, 0, 10)
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  elseif o.type == 'Slant' then
    no = Slant:new(w, 0, 0, 10)
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  elseif o.type == 'Ice' then
    no = Ice:new(w, 0, 0, 10)
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  elseif o.type == 'Door' then
    no = Door:new(w, 0, 0, 10, o.properties.map, o.properties.tx, o.properties.ty)
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  elseif o.type == 'FlyingWall' then
    no = FlyingWall:new(w, o.x, o.y, 8)
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.x = o.x+dx
    no.y = o.y+dy
    no.body:moveTo(no.x, no.y)
  elseif o.type == 'Water' then
    no = Water:new(w, 0, 0, 1)
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  elseif o.type == 'Spike' then
    no = Spike:new(w, o.x+8, o.y+8, 8)
  elseif o.type == 'Generator' then
    no = Generator:new(w, o.x+8, o.y+8, 8)
  elseif o.type == 'UpDownSpike' then
    no = UpDownSpike:new(w, o.x+8, o.y+8, 8)
  elseif o.type == 'Arrow' then
    no = Arrow:new(w, o.x+8, o.y+8, 8)
  elseif o.type == 'Fish' then
    no = Fish:new(w, o.x+8, o.y+8, 1)
  elseif o.type == 'Crab' then
    no = Crab:new(w, o.x+16, o.y+24, 6)
  elseif o.type == 'Watertop' then
    no = Watertop:new(w, o.x+8, o.y+8, 1)
  elseif o.type == 'Mountains' then
    no = Mountains:new(w, o.x, o.y, 0)
  elseif o.type == 'Cave' then
    no = Cave:new(w, o.x, o.y, 0)
  end
  name = no.name or o.type..'_'..o.x..'_'..o.y
  objects[name] = no
end

-- Loop over tiled map object layers and instantiate game objects
function addObjects(mapol)
  for _, ol in pairs(mapol) do
    for _, o in pairs(ol.objects) do
      if ol and ol.properties then addObject(o, ol.properties.w) else addObject(o) end
    end
  end
end

function love.load()
  require 'libs/middleclass'
  require 'libs/utils'
  require 'libs/anal'
  require 'libs/TEsound'
  require 'libs/camera'
  CRON = require 'libs/cron'
  HC  = require 'libs/HardonCollider'
  ATL = require 'libs/AdvTiledLoader.Loader'

  require 'objects/player'
  require 'objects/water'
  require 'objects/watertop'
  require 'objects/spike'
  require 'objects/updownspike'
  require 'objects/arrow'
  require 'objects/fish'
  require 'objects/crab'
  require 'objects/wall'
  require 'objects/flyingwall'
  require 'objects/bridge'
  require 'objects/slant'
  require 'objects/ice'
  require 'objects/mountains'
  require 'objects/door'
  require 'objects/sword'
  require 'objects/cave'
  require 'objects/generator'

  ATL.path = 'maps/'
  map = ATL.load 'test5.tmx'
  map.drawObjects = false

  Collider = HC(30, onCollision, onCollisionStop)

  love.graphics.setBackgroundColor(map.properties.r or 0, map.properties.g or 0, map.properties.b or 0)

  camera:setScale(1 / (map.properties.zoom or 2))

  love.mouse.setVisible(false)
  
  --TEsound.play('bgm/game.mp3', 'bgm')

  gamestate = 'play'
  pausepressed = false
  imgfont = love.graphics.newImage("fonts/test.png")
  imgfont:setFilter("nearest", "nearest")
  font = love.graphics.newImageFont(imgfont,
  " abcdefghijklmnopqrstuvwxyz" ..
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
  "123456789.,!?-+/():;%&`'*#=[]\"")
  love.graphics.setFont(font)

  objects = {}
  addObjects(map.ol)

  current_world = 'oce'

  objects.oce = Player:new('lolo', 'lolo', current_world, 64, 200, 8)

  --objects.lolo = Player:new('lolo', 'lolo', current_world, 32, 300, 8)
  --objects.lolo.left_btn = loadstring("return love.joystick.getAxis(1,1) == -1")
  --objects.lolo.right_btn = loadstring("return love.joystick.getAxis(1,1) == 1")
  --objects.lolo.down_btn = loadstring("return love.joystick.getAxis(1,2) == 1")
  --objects.lolo.jump_btn = loadstring("return love.joystick.isDown(1,2)")
  --objects.lolo.switch_btn = loadstring("return love.joystick.isDown(1,4)")
end

function love.update(dt)
  dt = math.min(0.07, dt)

  if love.keyboard.isDown("escape") then love.event.push("quit") end
  --if love.keyboard.isDown("r") then 
  --  objects.oce.x, objects.oce.y = 64, 300
  --  objects.oce.ondown = {}
  --  objects.oce.inwater = {}
  --  --objects.lolo.x, objects.lolo.y = 32, 400
  --  --objects.lolo.ondown = {}
  --  --objects.lolo.inwater = {}
  --end
  if love.keyboard.isDown("p") or love.joystick.isDown(1,10) or love.joystick.isDown(2,10) then
    if not pausepressed then
      if     gamestate == 'play'  then
        gamestate = 'pause'
        TEsound.pause('bgm')
        TEsound.play('sounds/pause.wav')
      elseif gamestate == 'pause' then
        gamestate = 'play'
        TEsound.resume('bgm')
      end
    end
    pausepressed = true
  else
    pausepressed = false
  end

  if gamestate == 'play' then
    for _,o in pairs(objects) do
      if o.update then o:update(dt) end
    end

    camera:follow({objects.oce, objects.lolo}, 10)

    --local physics_dt = dt
    --while physics_dt > 0 do
    --  Collider:update(math.min(0.1, physics_dt))
    --  physics_dt = physics_dt - 0.1
    --end
    Collider:update(dt)
    CRON.update(dt)
  end
end

function love.draw()
  camera:set()
  map:autoDrawRange(-camera.x + love.graphics.getWidth() / 2, -camera.y + love.graphics.getHeight() / 2, 0, -100)
  map:_updateTileRange()

  for z,layer in pairs(map.drawList) do
    if type(layer) == "table" then
      layer.z = z
      layer.w = layer.properties and layer.properties.w or nil
      objects[layer.name] = layer
    end
  end

  for i=-10,10,1 do
    for _,o in pairs(objects) do
      if o.z == i then
        --if o.w == current_world or o.w == 'shared' or not o.w then
        --  love.graphics.setColor(255,255,255,255)
        --else
        --  love.graphics.setColor(0,0,255,64)
        --end
        if o.draw then o:draw() end
      end
    end
  end

  if gamestate == 'pause' then
    love.graphics.setColor(0, 0, 0, 255*3/4)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    if math.floor(love.timer.getTime()) % 2 == 0 then love.graphics.setColor(255, 255, 0, 255) else love.graphics.setColor(255, 255, 255, 255) end
    love.graphics.printf("Pause", camera.x - love.graphics.getWidth() / 2 * camera.scaleX, camera.y, love.graphics.getWidth() * camera.scaleX, 'center')
    love.graphics.setColor(255, 255, 255, 255)
  end

  camera:unset()
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function onCollision(dt, shape_a, shape_b, dx, dy)
  for _,o in pairs(objects) do
    if shape_a == o.body and o.onCollision then o:onCollision(dt, shape_b, -dx, -dy) end
    if shape_b == o.body and o.onCollision then o:onCollision(dt, shape_a,  dx,  dy) end
  end
end

function onCollisionStop(dt, shape_a, shape_b, dx, dy)
  for _,o in pairs(objects) do
    if shape_a == o.body and o.onCollisionStop then o:onCollisionStop(dt, shape_b, -dx, -dy) end
    if shape_b == o.body and o.onCollisionStop then o:onCollisionStop(dt, shape_a,  dx,  dy) end
  end
end
