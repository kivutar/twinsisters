require 'libs/class'
require 'libs/anal'
require 'libs/TEsound'
require 'libs/camera'
HC  = require 'libs/HardonCollider'
ATL = require 'libs/AdvTiledLoader.Loader'

require 'objects/player'
require 'objects/water'
require 'objects/watertop'
require 'objects/spike'
require 'objects/arrow'
require 'objects/fish'
require 'objects/crab'
require 'objects/wall'
require 'objects/flyingwall'
require 'objects/bridge'

ATL.path = 'maps/'
map = ATL.load 'kivutaria.tmx'
map.drawObjects = false

function addObject(o, w)
  if o.type == 'Wall' then
    no = Wall:new(w, 0, 0, 1)
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  elseif o.type == 'Bridge' then
    no = Bridge:new(w, 0, 0, 1)
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
    no = Spike:new(w, o.x+8, o.y+8, 1)
  elseif o.type == 'Arrow' then
    no = Arrow:new(w, o.x+8, o.y+8, 8)
  elseif o.type == 'Fish' then
    no = Fish:new(w, o.x+8, o.y+8, 1)
  elseif o.type == 'Crab' then
    no = Crab:new(w, o.x+16, o.y+32, 6)
  elseif o.type == 'Watertop' then
    no = Watertop:new(w, o.x+8, o.y+8, 1)
  end
  no.body.type = o.type
  objects[o.type..'_'..o.x..'_'..o.y] = no
end

function love.load()

  Collider = HC(100, onCollision, onCollisionStop)

  love.graphics.setBackgroundColor(84, 200, 248)

  love.mouse.setVisible(false)
  
  TEsound.play('bgm/game.mp3')

  objects = {}

  for k1, ol in pairs(map.ol) do
    for k2, o in pairs(ol.objects) do
      addObject(o, ol.properties.w)
    end
  end

  current_world = 'lolo'
  switch_pressed = false

  objects.oce = Player:new('oce', 'oce', current_world, 64, 420, 8)

  objects.lolo = Player:new('lolo', 'lolo', current_world, 128, 420, 8)
  objects.lolo.left_btn = loadstring("return love.joystick.getAxis(1,1) == -1")
  objects.lolo.right_btn = loadstring("return love.joystick.getAxis(1,1) == 1")
  objects.lolo.down_btn = loadstring("return love.joystick.getAxis(1,2) == 1")
  objects.lolo.jump_btn = loadstring("return love.joystick.isDown(1,2)")
  objects.lolo.switch_btn = loadstring("return love.joystick.isDown(1,4)")
end

function love.update(dt)

  if love.keyboard.isDown("escape") then love.event.push("quit")  end
  if love.keyboard.isDown("r") then 
    objects.oce.x, objects.oce.y = 64, 400
    objects.oce.ondown = {}
    objects.oce.inwater = {}
    objects.lolo.x, objects.lolo.y = 32, 400
    objects.lolo.ondown = {}
    objects.lolo.inwater = {}
  end

  for _,o in pairs(objects) do
    if o.update then o:update(dt) end
  end

  --camera:move(
  --  ((-camera.x + (objects.lolo.x- 8 + objects.oce.x- 8) / 2 ) / 10.0),
  --  ((-camera.y + (objects.lolo.y-12 + objects.oce.y-12) / 2 ) / 10.0)
  --)
  camera:move((-camera.x+objects.oce.x-8)/10, (-camera.y+objects.oce.y-12)/10)
  camera:setScale(1/2, 1/2)

  Collider:update(dt)
end

function love.draw()
  camera:set()
  map:autoDrawRange(-camera.x + love.graphics.getWidth() / 2, -camera.y + love.graphics.getHeight() / 2, 0, -100)
  map:_updateTileRange()

  for z,layer in pairs(map.drawList) do
    if type(layer) == "table" then
      layer.z = z
      layer.w = layer.properties.w
      objects[layer.name] = layer
    end
  end

  bg = love.graphics.newImage('backgrounds/mountains.png')
  bg:setFilter("nearest","nearest")
  bg2 = love.graphics.newImage('backgrounds/mountains2.png')
  bg2:setFilter("nearest","nearest")
  for i=-10,10,1 do
    love.graphics.draw(bg2, i*128 + (camera.x/5), love.graphics.getHeight()/2 - 64, 0, 1, 1, 0, 0)
  end
  for i=-10,10,1 do
    love.graphics.draw(bg , i*128 + (camera.x/4), love.graphics.getHeight()/2 - 64, 0, 1, 1, 0, 0)
  end

  for i=-10,10,1 do
    for _,o in pairs(objects) do
      if o.z == i then
        if o.w == current_world or o.w == 'shared' or not o.w then
          love.graphics.setColor(255,255,255,255)
        else
          love.graphics.setColor(0,0,255,64)
        end
        o:draw()
      end
    end
  end

  camera:unset()
  --love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function onCollision(dt, shape_a, shape_b, dx, dy)
  for _,o in pairs(objects) do
    if shape_a == o.body then o:onCollision(dt, shape_b, -dx, -dy) end
    if shape_b == o.body then o:onCollision(dt, shape_a,  dx,  dy) end
  end
end

function onCollisionStop(dt, shape_a, shape_b, dx, dy)
  for _,o in pairs(objects) do
    if shape_a == o.body then o:onCollisionStop(dt, shape_b, -dx, -dy) end
    if shape_b == o.body then o:onCollisionStop(dt, shape_a,  dx,  dy) end
  end
end
