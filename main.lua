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
require 'objects/fish'
require 'objects/crab'
require 'objects/wall'

ATL.path = 'maps/'
map = ATL.load 'test4.tmx'
map.drawObjects = false

function addObject(o, w)
  if o.type == 'Wall' then
    no = Wall:new(w, 0, 0, 1)
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  elseif o.type == 'Water' then
    no = Water:new(w, 0, 0, 1)
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  elseif o.type == 'Spike' then
    no = Spike:new(w, o.x+8, o.y+8, 1)
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
  
  TEsound.play('bgm/costadelsol.mp3')

  objects = {}

  for k1, ol in pairs(map.ol) do
    for k2, o in pairs(ol.objects) do
      addObject(o, ol.properties.w)
    end
  end

  current_world = 'lolo'
  switch_pressed = false

  objects.oce = Player:new('lolo', 'lolo', current_world, 64, 64, 1)
  --objects.oce.left_btn = loadstring("return love.keyboard.isDown('left')")
  --objects.oce.right_btn = loadstring("return love.keyboard.isDown('right')")
  --objects.oce.jump_btn = loadstring("return love.keyboard.isDown('up')")
  --objects.oce.switch_btn = loadstring("return love.keyboard.isDown('down')")

  --objects.lolo = Player:new('lolo', 'lolo', current_world, 336, 240, 6)
  --objects.lolo.left_btn = loadstring("return love.joystick.getAxis(2,1) == -1 or love.keyboard.isDown('a')")
  --objects.lolo.right_btn = loadstring("return love.joystick.getAxis(2,1) == 1 or love.keyboard.isDown('d')")
  --objects.lolo.jump_btn = loadstring("return love.joystick.isDown(2, 2) or love.keyboard.isDown('w')")
end

function love.update(dt)

  if love.keyboard.isDown("escape") then love.event.push("quit")  end
  if love.keyboard.isDown("r") then 
    --objects.lolo.body:setPosition(320, 240)
    objects.oce.x, objects.oce.y = 64, 420
    objects.oce.onground = false
    objects.oce.onleft = false
    objects.oce.onright = false
  end

  for _,o in pairs(objects) do
    if o.update then o:update(dt) end
  end

  --camera:move(
  --  ((-camera.x + (objects.lolo.body:getX()- 8 + objects.oce.body:getX()- 8) / 2 ) / 10.0),
  --  ((-camera.y + (objects.lolo.body:getY()-12 + objects.oce.body:getY()-12) / 2 ) / 10.0)
  --)
  camera:move((-camera.x+objects.oce.x-8)/10, (-camera.y+objects.oce.y-12)/10)
  camera:setScale(1.0/2.0, 1.0/2.0)

  Collider:update(dt)
end

function love.draw()
  camera:set()
  map:autoDrawRange(-camera.x + love.graphics.getWidth() / 2, -camera.y + love.graphics.getHeight() / 2, 1, -100)
  map:_updateTileRange()

  for z,layer in pairs(map.drawList) do
    if type(layer) == "table" then
      layer.z = z
      layer.w = layer.properties.w
      objects[layer.name] = layer
    end
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
  if shape_a == objects.oce.body then objects.oce:onCollisionStop(dt, shape_b, -dx, -dy) end
  if shape_b == objects.oce.body then objects.oce:onCollisionStop(dt, shape_a,  dx,  dy) end
end
