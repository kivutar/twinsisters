require 'class'
require 'camera'
require 'anal'
require 'TEsound'
atl = require 'AdvTiledLoader.Loader'
atl.path = 'maps/'
map = atl.load 'test2.tmx'
map.drawObjects = false
require 'player'
require 'watertop'

function love.load()
  love.physics.setMeter(64) 
  world = love.physics.newWorld(0, 9.81*64, true) 
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)

  love.graphics.setBackgroundColor(84, 200, 248)
  
  TEsound.play('bgm/costadelsol.mp3')

  objects = {}

  --img_watertop = love.graphics.newImage('sprites/watertop.png')
  --img_watertop:setFilter("nearest","nearest")
  --anim_watertop = newAnimation(img_watertop, 16, 16, 0.1, 0)
  --for x=0, map.width do
  --  for y=0, map.height do
  --    local tile
  --    if map.tl['Sea'].tileData(x,y) then
  --      tile = map.tl['Sea'].tileData(x,y)
  --    end
  --    if tile and tile.properties.animation == 'watertop' then
  --      objects['watertop_'..x..'_'..y] = Watertop:new(x*16, y*16, 1)
  --    end
  --  end
  --end 

  for _,object in pairs(map.ol['Collisions'].objects) do
    body = love.physics.newBody(world, object.x, object.y)
    shape = love.physics.newChainShape(true, unpack(object.polyline))
    fixture = love.physics.newFixture(body, shape)
    fixture:setUserData('wall')
  end

  objects.oce  = Player:new('oce', 'oce', 64, 64, 1)
  --objects.oce.left_btn = loadstring("return love.joystick.getAxis(1,1) == -1 or love.keyboard.isDown('left')")
  --objects.oce.right_btn = loadstring("return love.joystick.getAxis(1,1) == 1 or love.keyboard.isDown('right')")
  objects.oce.jump_btn = loadstring("return love.joystick.isDown(1, 2) or love.keyboard.isDown(' ')")

  --objects.lolo = Player:new('lolo', 'lolo', 336, 240)
  --objects.lolo.left_btn = loadstring("return love.joystick.getAxis(2,1) == -1 or love.keyboard.isDown('a')")
  --objects.lolo.right_btn = loadstring("return love.joystick.getAxis(2,1) == 1 or love.keyboard.isDown('d')")
  --objects.lolo.jump_btn = loadstring("return love.joystick.isDown(2, 2) or love.keyboard.isDown('w')")
end

function love.update(dt)
  world:update(dt)

  if love.keyboard.isDown("escape") then love.event.push("quit")  end
  if love.keyboard.isDown("r") then 
    --objects.lolo.body:setPosition(320, 240)
    objects.oce.body:setPosition(64, 64)
  end

  for _,o in pairs(objects) do
    if o.update then o:update(dt) end
  end

  --anim_watertop:update(dt)

  --camera:move(
  --  ((-camera.x + (objects.lolo.body:getX()- 8 + objects.oce.body:getX()- 8) / 2 ) / 10.0),
  --  ((-camera.y + (objects.lolo.body:getY()-12 + objects.oce.body:getY()-12) / 2 ) / 10.0)
  --)
  camera:move((-camera.x+objects.oce.body:getX()-8)/10, (-camera.y+objects.oce.body:getY()-12)/10)
  camera:setScale(1.0/3.0, 1.0/3.0)
end

function love.draw()
  camera:set()
  map:autoDrawRange(-camera.x + love.graphics.getWidth() / 2, -camera.y + love.graphics.getHeight() / 2, 1, -100)
  map:_updateTileRange()
  for z,layer in pairs(map.drawList) do
    if type(layer) == "table" then
      layer.z = z
      objects[layer.name] = layer
    end
  end
  for i=-10,10,1 do
    for _,o in pairs(objects) do 
      if o.z == i then o:draw() end
    end
  end
  camera:unset()
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function beginContact(a, b, coll)
  objects.oce.nx, objects.oce.ny = coll:getNormal()
  --print(a:getUserData(), b:getUserData())
  if a:getUserData() == 'wall' then
    objects.oce.contacts = objects[b:getUserData()].contacts + 1
  end
  --print('begin', coll:getNormal())
end

function endContact(a, b, coll)
  --objects.oce.nx, objects.oce.ny = coll:getNormal()
  --print('end', coll:getNormal())
  if a:getUserData() == 'wall' and b:getUserData() == 'oce' then
    objects.oce.contacts = objects.oce.contacts - 1
  end
end

function preSolve(a, b, coll)
  --print('pre', coll:getNormal())
    
end

function postSolve(a, b, coll)
  --print('post', coll:getNormal())
end
