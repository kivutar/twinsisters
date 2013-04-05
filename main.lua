-- Require libraries
require 'libs/middleclass/middleclass' -- POO
require 'libs/utils' -- Various utilities
require 'libs/anal' -- Sprite animations
require 'libs/controls' -- Inputs
require 'libs/TEsound' -- Play sounds
require 'libs/camera' -- Camera to follow game objects
require 'libs/menu' -- Menu to make choices
CRON = require 'libs/cron/cron' -- Scheduler
HC  = require 'libs/HardonCollider' -- Collision detection
ATL = require 'libs/Advanced-Tiled-Loader.Loader' -- Tiled map loader
require 'libs/actors' -- Game Actors
require 'libs/sfx' -- Game sound effects
--require 'libs/bgm' -- Background musics
requiredir('effects') -- Game pixel effects
requiredir('fonts') -- Fonts

function love.load()

  Collider = HC(30, onCollision, onCollisionStop)

  ATL.path = 'maps/'
  actors.switchMap('pagode')

  --screen_width = love.graphics.getWidth()
  --screen_height = love.graphics.getHeight()
  --love.graphics.setMode(screen_width, screen_height, true)
  camera:setScale(1/3)
  love.mouse.setVisible(false)
  
  --TEsound.play(bgm.verger, 'bgm')

  gamestate = 'play'

  love.graphics.setFont(school)

  --effects = { distortion=Distortion(), chromashift=Chromashift(), blurh=BlurH(), blurv=BlurV(), posterization=Posterization() }

  --blendcanvas = love.graphics.newCanvas()
  --hallo = love.graphics.newImage('sprites/hallo.png')
end

function love.update(dt)
  controls:update()

  dt = math.min(0.07, dt)

  if gamestate == 'play' then
    for _,a in pairs(actors.list) do
      if a.update then a:update(dt) end
    end
    --for _,e in pairs(effects) do
    --  if e.update then e:update(dt) end
    --end
    camera:follow({actors.list.lolo}, 1)
    Collider:update(dt)
    CRON.update(dt)
  elseif gamestate == 'pause' then
    actors.list.pause:update(dt)
  elseif gamestate == 'dialog' then
    camera:follow({actors.list.lolo}, 1)
    actors.list.dialog:update(dt)
  elseif gamestate == 'transition' then
    actors.list.transition:update(dt)
  end

end

function love.draw()

  camera:set()

  map:autoDrawRange(-camera:ox(), -camera:oy(), 1/camera.scaleX, 50)
  map:_updateTileRange()

  for z = 1, #map.layerOrder do
    layer = map.layerOrder[z]
    layer.z = z
    actors.list[layer.name] = layer
  end

  for i=0,32,1 do
    for _,o in pairs(actors.list) do
      if o.z == i then
        if o.draw then o:draw() end
      end
    end
  end

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

  love.graphics.setColor(0, 255, 0, 255)
  --love.graphics.print(tostring(love.timer.getFPS()), 5, 5)
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
