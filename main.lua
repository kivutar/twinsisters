-- Require libraries
require 'libs/middleclass' -- POO
require 'libs/utils' -- Various utilities
require 'libs/anal' -- Sprite animations
require 'libs/TEsound' -- Play sounds
require 'libs/camera' -- Camera to follow game objects
require 'libs/menu' -- Menu to make choices
CRON = require 'libs/cron' -- Scheduler
HC  = require 'libs/HardonCollider' -- Collision detection
ATL = require 'libs/AdvTiledLoader.Loader' -- Tiled map loader
require 'libs/actors' -- Game Actors
requiredir('effects') -- Game Effects
requiredir('fonts') -- Fonts

function love.load()

  ATL.path = 'maps/'
  actors.switchMap('start')

  Collider = HC(30, onCollision, onCollisionStop)

  camera:setScale(1920/1440)

  love.mouse.setVisible(false)
  
  --TEsound.play('bgm/game.mp3', 'bgm')

  gamestate = 'play'

  love.graphics.setFont(school)

  --actors.list.lolo = Player:new(1100, 800)
  --actors.list.oce  = Player:new('oce',  'oce', 1100, 800, 10)
  --actors.list.oce.left_btn   = loadstring("return love.keyboard.isDown('q') or love.joystick.getAxis(2,1) == -1")
  --actors.list.oce.right_btn  = loadstring("return love.keyboard.isDown('d') or love.joystick.getAxis(2,1) ==  1")
  --actors.list.oce.down_btn   = loadstring("return love.keyboard.isDown('s') or love.joystick.getAxis(2,2) ==  1")
  --actors.list.oce.up_btn     = loadstring("return love.keyboard.isDown('z') or love.joystick.getAxis(2,2) == -1")
  --actors.list.oce.jump_btn   = loadstring("return love.keyboard.isDown(' ') or love.joystick.isDown(2,2)")
  --actors.list.oce.switch_btn = loadstring("return love.keyboard.isDown('v') or love.joystick.isDown(2,4)")
  --actors.list.oce.sword_btn  = loadstring("return love.keyboard.isDown('b') or love.joystick.isDown(2,3)")
  --actors.list.oce.fire_btn   = loadstring("return love.keyboard.isDown('c') or love.joystick.isDown(2,1)")

  --actors.list.player1lifebar = Player1LifeBar(actors.list.lolo)

  --effects = { distortion=Distortion(), chromashift=Chromashift(), blurh=BlurH(), blurv=BlurV(), posterization=Posterization() }

  --blendcanvas = love.graphics.newCanvas()
  --hallo = love.graphics.newImage('sprites/hallo.png')
end

function love.update(dt)
  dt = math.min(0.07, dt)

  if gamestate == 'play' then
    for _,a in pairs(actors.list) do
      if a.update then a:update(dt) end
    end
    --for _,e in pairs(effects) do
    --  if e.update then e:update(dt) end
    --end
    camera:follow({actors.list.lolo}, 10)
    Collider:update(dt)
    CRON.update(dt)
  elseif gamestate == 'pause' then
    actors.list.pause:update(dt)
  elseif gamestate == 'dialog' then
    camera:follow({actors.list.lolo}, 10)
    actors.list.dialog:update(dt)
  elseif gamestate == 'transition' then
    actors.list.transition:update(dt)
  end

end

function love.draw()

  for i=0,4,1 do
    for _,o in pairs(actors.list) do
      if o.z == i then
        if o.draw_before then o:draw_before() end
      end
    end
  end

  camera:set()

  for i=0,10,1 do
    for _,o in pairs(actors.list) do
      if o.z == i then
        if o.draw then o:draw() end
      end
    end
  end  

  love.graphics.draw(cache)

  for i=10,15,1 do
    for _,o in pairs(actors.list) do
      if o.z == i then
        if o.draw then o:draw() end
      end
    end
  end  

--  map:autoDrawRange(-camera:ox(), -camera:oy(), 1, 50)
--  map:_updateTileRange()
--
--  for z,layer in pairs(map.drawList) do
--    if type(layer) == "table" then
--      layer.z = z
--      layer.w = layer.properties and layer.properties.w or nil
--      actors.list[layer.name] = layer
--    end
--  end
--
--  for i=0,4,1 do
--    for _,o in pairs(actors.list) do
--      if o.z == i then
--        if o.draw then o:draw() end
--      end
--    end
--  end

      --  love.graphics.setCanvas(effects.distortion.canvas)
      --  effects.distortion.canvas:clear()
      --      for _,o in pairs(actors.list) do
      --        if o.z == 1 then
      --          if o.draw then o:draw() end
      --        end
      --      end
      --  love.graphics.setCanvas()
      --  pipe(effects.distortion.canvas, effects.distortion.pe, nil)
      --
      --  --love.graphics.setCanvas(effects.chromashift.canvas)
      --  --effects.chromashift.canvas:clear()
      --    for i=2,4,1 do
      --      for _,o in pairs(actors.list) do
      --        if o.z == i then
      --          if o.draw then o:draw() end
      --        end
      --      end
      --    end
      --  --love.graphics.setCanvas()
      --
      --  --pipe(effects.chromashift.canvas, effects.chromashift.pe, effects.distortion.canvas)
      --  --pipe(effects.distortion.canvas,  effects.distortion.pe,  nil)
      --  --pipe(effects.chromashift.canvas, nil, nil)
      --  --pipe(effects.chromashift.canvas, effects.blurh.pe, effects.blurh.canvas)
      --  --pipe(effects.blurh.canvas,       effects.blurv.pe, nil)
      --
      --  love.graphics.setCanvas(blendcanvas)
      --  blendcanvas:clear()
      --  love.graphics.setBlendMode("alpha")
      --  love.graphics.setColor(0, 0, 0)
      --  love.graphics.rectangle('fill', camera:ox(), camera:oy(), love.graphics.getWidth(), love.graphics.getHeight())
      --  love.graphics.setBlendMode("subtractive")
      --  for i=-4,4,1 do
      --    for _,o in pairs(actors.list) do
      --      if o.z == i then
      --        if o.drawhallo then o:drawhallo() end
      --      end
      --    end
      --  end
      --  love.graphics.setBlendMode("alpha")
      --  love.graphics.setCanvas()
      --  --love.graphics.draw(blendcanvas, camera:ox(), camera:oy())
      --  pipe(blendcanvas, effects.posterization.pe, nil)

  camera:unset()

  for i=0,4,1 do
    for _,o in pairs(actors.list) do
      if o.z == i then
        if o.draw_after then o:draw_after() end
      end
    end
  end

  love.graphics.setColor(128, 128, 128, 255)
  --love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 5, 5)
  love.graphics.setColor(255, 255, 255, 255)
end

function onCollision(dt, shape_a, shape_b, dx, dy)
  for _,o in pairs(actors.list) do
    if shape_a == o.body and o.onCollision then o:onCollision(dt, shape_b, -dx, -dy) end
    if shape_b == o.body and o.onCollision then o:onCollision(dt, shape_a,  dx,  dy) end
  end
end

function onCollisionStop(dt, shape_a, shape_b, dx, dy)
  for _,o in pairs(actors.list) do
    if shape_a == o.body and o.onCollisionStop then o:onCollisionStop(dt, shape_b, -dx, -dy) end
    if shape_b == o.body and o.onCollisionStop then o:onCollisionStop(dt, shape_a,  dx,  dy) end
  end
end
