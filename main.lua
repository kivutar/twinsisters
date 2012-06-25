require 'class'
require 'camera'
require 'anal'
require 'TEsound'
atl = require 'AdvTiledLoader.Loader'
atl.path = 'maps/'
map = atl.load 'plage.tmx'
require 'player'
require 'watertop'

function love.load()
  love.physics.setMeter(64) 
  world = love.physics.newWorld(0, 9.81*64, true) 
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)

  love.graphics.setBackgroundColor(100, 100, 100)
  love.graphics.setMode(640, 480, false, true, 0)
  
  TEsound.play('bgm/costadelsol.mp3')

  objects = {}

  for x=0, map.width do
    for y=0, map.height do
      local tile
      if map.tl['Ground'].tileData(x,y) then
        tile = map.tl['Ground'].tileData(x,y)
      end
      local body = love.physics.newBody(world, x*16+8, y*16+8)
      if tile and tile.properties.type == 'square' then
        shape = love.physics.newRectangleShape(16, 16)
        love.physics.newFixture(body, shape)
      elseif tile and tile.properties.type == 'slant_nw' then
        shape = love.physics.newPolygonShape(-8,  8, 8,  8,  8, -8)
        fixture = love.physics.newFixture(body, shape)
        fixture:setFriction(0)
      elseif tile and tile.properties.type == 'slant_ne' then
        shape = love.physics.newPolygonShape(-8,  8, 8,  8, -8, -8)
        fixture = love.physics.newFixture(body, shape)
        fixture:setFriction(0)
      elseif tile and tile.properties.type == 'slant_sw' then
        shape = love.physics.newPolygonShape(-8, -8, 8,  8,  8, -8)
        fixture = love.physics.newFixture(body, shape)
        fixture:setFriction(0)
      elseif tile and tile.properties.type == 'slant_se' then
        shape = love.physics.newPolygonShape(-8,  8, 8, -8, -8, -8)
        fixture = love.physics.newFixture(body, shape)
        fixture:setFriction(0)
      end
    end
  end

   for x=0, map.width do
    for y=0, map.height do
      local tile
      if map.tl['Sea'].tileData(x,y) then
        tile = map.tl['Sea'].tileData(x,y)
      end
      if tile and tile.properties.type == 'watertop' then
        --objects['watertop_'..x..'_'..y] = Watertop:new(x, y)
      end
    end
  end 

  --for oo in pairs(map.ol['Collisions'].objects) do
  --  print(oo)
  --end

  objects.oce  = Player:new('oce' , 320, 240)
  objects.oce.left_btn = loadstring("return love.joystick.getAxis(1,1) == -1 or love.keyboard.isDown('left')")
  objects.oce.right_btn = loadstring("return love.joystick.getAxis(1,1) == 1 or love.keyboard.isDown('right')")
  objects.oce.jump_btn = loadstring("return love.joystick.isDown(1, 2) or love.keyboard.isDown('up')")

  objects.lolo = Player:new('lolo', 336, 240)
  objects.lolo.left_btn = loadstring("return love.joystick.getAxis(2,1) == -1 or love.keyboard.isDown('a')")
  objects.lolo.right_btn = loadstring("return love.joystick.getAxis(2,1) == 1 or love.keyboard.isDown('d')")
  objects.lolo.jump_btn = loadstring("return love.joystick.isDown(2, 2) or love.keyboard.isDown('w')")

  objects.watertop = Watertop:new(355, 240)
end

function love.update(dt)
  world:update(dt)

  if love.keyboard.isDown("escape") then love.event.push("quit")  end
  if love.keyboard.isDown("r") then 
    objects.lolo.body:setPosition(320, 240)
    objects.oce.body:setPosition(336, 240)
  end

  for _,o in pairs(objects) do o:update(dt) end

  camera:move(
    ((-camera.x + (objects.lolo.body:getX()- 8 + objects.oce.body:getX()- 8) / 2 ) / 10.0),
    ((-camera.y + (objects.lolo.body:getY()-12 + objects.oce.body:getY()-12) / 2 ) / 10.0)
  )
  camera:setScale(0.5, 0.5)
end

function love.draw()
  camera:set()
  map:autoDrawRange(-camera.x + love.graphics.getWidth() / 2, -camera.y + love.graphics.getHeight() / 2, 1, -100)
  map:draw()
  for _,o in pairs(objects) do o:draw() end
  camera:unset()
end

function beginContact(a, b, coll)
  nx, ny = coll:getNormal()
end

function endContact(a, b, coll)
  nx, ny = coll:getNormal()
end

function preSolve(a, b, coll)
    
end

function postSolve(a, b, coll)
    
end
