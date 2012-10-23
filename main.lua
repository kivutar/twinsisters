-- Require libraries
require 'libs/middleclass' -- POO
require 'libs/utils' -- Various utilities
require 'libs/anal' -- Sprite animations
require 'libs/TEsound' -- Play sounds
require 'libs/camera' -- Camera to follow game objects
CRON = require 'libs/cron' -- Scheduler
HC  = require 'libs/HardonCollider' -- Collision detection
ATL = require 'libs/AdvTiledLoader.Loader' -- Tiled map loader

-- Require mixins
require 'mixins/gravity'
require 'mixins/blinking'

-- Require game objects
for _,v in pairs(love.filesystem.enumerate('objects')) do
  require('objects/'..string.gsub(v, '.lua', ''))
end

-- Instanciate a game object
function addObject(o, w)
  no = _G[o.type]:new(w, o.x, o.y, 0, o.properties)
  if o.polygon then
    no.body = Collider:addPolygon(unpack(o.polygon))
    no.body.parent = no
    dx, dy = no.body:center()
    no.body:moveTo(o.x+dx, o.y+dy)
  end
  no.name = no.name or o.type..'_'..o.x..'_'..o.y..'_'..love.timer.getTime()
  objects[no.name] = no
end

-- Loop over tiled map object layers and instanciate game objects
function addObjectsFromTiled(mapol)
  for _, ol in pairs(mapol) do
    for _, o in pairs(ol.objects) do
      if ol and ol.properties then addObject(o, ol.properties.w) else addObject(o) end
    end
  end
end

function love.load()

  ATL.path = 'maps/'
  map = ATL.load 'doom1.tmx'
  map.drawObjects = false

  Collider = HC(30, onCollision, onCollisionStop)

  love.graphics.setBackgroundColor(map.properties.r or 0, map.properties.g or 0, map.properties.b or 0)

  camera:setScale(1)--(map.properties.zoom or 2))

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

  imgfont2 = love.graphics.newImage("fonts/test2.png")
  imgfont2:setFilter("nearest", "nearest")
  font2 = love.graphics.newImageFont(imgfont2,
  " abcdefghijklmnopqrstuvwxyz" ..
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
  "123456789.,!?-+/():;%&`'*#=[]\"")

  love.graphics.setFont(font)

  objects = {}
  addObjectsFromTiled(map.ol)

  current_world = 'oce'

  objects.lolo = Player:new('lolo', 'lolo', current_world, 64, 200, 10)
  --objects.oce  = Player:new('oce',  'oce',  current_world, 64, 200, 10)
  --objects.oce.left_btn   = loadstring("return love.keyboard.isDown('q')  or love.joystick.getAxis(2,1) == -1")
  --objects.oce.right_btn  = loadstring("return love.keyboard.isDown('d') or love.joystick.getAxis(2,1) ==  1")
  --objects.oce.down_btn   = loadstring("return love.keyboard.isDown('s')  or love.joystick.getAxis(2,2) ==  1")
  --objects.oce.up_btn     = loadstring("return love.keyboard.isDown('z')    or love.joystick.getAxis(2,2) == -1")
  --objects.oce.jump_btn   = loadstring("return love.keyboard.isDown(' ')     or love.joystick.isDown(2,2)")
  --objects.oce.switch_btn = loadstring("return love.keyboard.isDown('v')     or love.joystick.isDown(2,4)")
  --objects.oce.sword_btn  = loadstring("return love.keyboard.isDown('b')     or love.joystick.isDown(2,3)")
  --objects.oce.fire_btn   = loadstring("return love.keyboard.isDown('c')     or love.joystick.isDown(2,1)")

  ui = love.graphics.newImage('sprites/ui.png')
  ui:setFilter("nearest", "nearest")

  heart = {}
  for i=0, 4 do
    heart[i] = love.graphics.newImage('sprites/heart_'..i..'.png')
    heart[i]:setFilter("nearest", "nearest")
  end
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
      if gamestate == 'play' then
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

    camera:follow({objects.lolo}, 10)

    --local physics_dt = dt
    --while physics_dt > 0 do
    --  Collider:update(math.min(0.1, physics_dt))
    --  physics_dt = physics_dt - 0.1
    --end
    Collider:update(dt)
    CRON.update(dt)
  elseif gamestate == 'dialog' then
    objects.dialog:update(dt)
  end
end

function love.draw()
  camera:set()
  map:autoDrawRange(-camera.x + love.graphics.getWidth() / 2, -camera.y + love.graphics.getHeight() / 2, 1, 50)
  map:_updateTileRange()

  for z,layer in pairs(map.drawList) do
    if type(layer) == "table" then
      layer.z = z
      layer.w = layer.properties and layer.properties.w or nil
      objects[layer.name] = layer
    end
  end

  for i=-15,15,1 do
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

  local uix = camera.x - love.graphics.getWidth()  / 2 * camera.scaleX
  local uiy = camera.y - love.graphics.getHeight() / 2 * camera.scaleY

  if gamestate == 'pause' then
    love.graphics.setColor(0, 0, 0, 255*3/4)
    love.graphics.rectangle('fill', uix, uiy, love.graphics.getWidth(), love.graphics.getHeight())
    if math.floor(love.timer.getTime()) % 2 == 0 then love.graphics.setColor(255, 255, 0, 255) else love.graphics.setColor(255, 255, 255, 255) end
    love.graphics.printf("Pause", uix, camera.y, love.graphics.getWidth() * camera.scaleX, 'center')
    love.graphics.setColor(255, 255, 255, 255)
  end

  love.graphics.draw(ui, uix, uiy, 0, 1, 1, 0, 0)

  local hp = objects.lolo.HP

  for i=1,objects.lolo.maxHP,4 do

    hp2 = (hp >= 4) and 4 or hp
    hp2 = (hp >= 0) and hp2 or 0

    hp = hp - 4

    love.graphics.draw(heart[hp2], (i/4)*16*4 + 36*4 + (uix), 16*4 + (uiy), 0, 1, 1, 0, 0)

  end

  camera:unset()
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 5, 5)
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
