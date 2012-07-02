require 'class'
require 'camera'
HC = require 'HardonCollider'
require 'anal'
require 'TEsound'
atl = require 'AdvTiledLoader.Loader'
atl.path = 'maps/'
map = atl.load 'test3.tmx'
map.drawObjects = false
require 'player'
require 'watertop'
require 'spike'

function setSolid(w)
  for _, s in pairs(worlds[w]) do
    Collider:setSolid(s)
  end
end

function setGhost(w)
  for _, s in pairs(worlds[w]) do
    Collider:setGhost(s)
  end
end

function addObject(o, w)
  if o.type == 'Wall' then
    s = Collider:addPolygon(unpack(o.polygon))
    dx, dy = s:center()
    s:moveTo(o.x+dx, o.y+dy)
    s.type = o.type
    if w then table.insert(worlds[w], s) end
  elseif o.type == 'Spyke' then
    objects[o.type..'_'..o.x..'_'..o.y] = Spike:new(w, o.x+8, o.y-8, 1)
    objects[o.type..'_'..o.x..'_'..o.y].body.type = o.type
    if w then table.insert(worlds[w], objects[o.type..'_'..o.x..'_'..o.y].body) end
  end
end

function love.load()

  Collider = HC(100, onCollision, onCollisionStop)

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

  worlds = {}
  worlds.oce = {}
  worlds.lolo = {}

  for _, o in pairs(map.ol['shared_objects'].objects) do
    addObject(o)
  end

  for _, w in pairs({'oce', 'lolo'}) do
    for _, o in pairs(map.ol[w..'_objects'].objects) do
      addObject(o, w)
    end
  end

  current_world = 'oce'
  switch_pressed = false
  setSolid('oce')
  setGhost('lolo')

  objects.oce = Player:new('oce', 'oce', current_world, 64, 420, 6)
  --objects.oce.left_btn = loadstring("return love.keyboard.isDown('left')")
  --objects.oce.right_btn = loadstring("return love.keyboard.isDown('right')")
  --objects.oce.jump_btn = loadstring("return love.keyboard.isDown(' ')")
  --objects.oce.switch_btn = loadstring("return love.keyboard.isDown('v')")

  --objects.lolo = Player:new('lolo', 'lolo', current_world, 336, 240, 6)
  --objects.lolo.left_btn = loadstring("return love.joystick.getAxis(2,1) == -1 or love.keyboard.isDown('a')")
  --objects.lolo.right_btn = loadstring("return love.joystick.getAxis(2,1) == 1 or love.keyboard.isDown('d')")
  --objects.lolo.jump_btn = loadstring("return love.joystick.isDown(2, 2) or love.keyboard.isDown('w')")

effect = love.graphics.newPixelEffect [[
        
        const float blurSize = 1.0/512.0; 
        

        vec4 effect(vec4 global_color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {

        vec4 sum = vec4(0.0);
        float fade = 0.0001;
 
       sum += (texture2D(texture, vec2(texture_coords.x - 4.0*blurSize, texture_coords.y)) * 0.05)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x - 3.0*blurSize, texture_coords.y)) * 0.09)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x - 2.0*blurSize, texture_coords.y)) * 0.12)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x - blurSize, texture_coords.y)) * 0.15)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x, texture_coords.y)) * 0.181)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + blurSize, texture_coords.y)) * 0.15)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + 2.0*blurSize, texture_coords.y)) * 0.12)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + 3.0*blurSize, texture_coords.y)) * 0.09)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + 4.0*blurSize, texture_coords.y)) * 0.05)-fade;
        sum.a = 1;
         
         return sum ;
        }
    ]]
end

function love.update(dt)

  if love.keyboard.isDown("escape") then love.event.push("quit")  end
  if love.keyboard.isDown("r") then 
    --objects.lolo.body:setPosition(320, 240)
    objects.oce.x, objects.oce.y = 64, 420
  end

  for _,o in pairs(objects) do
    if o.update then o:update(dt) end
  end

  --anim_watertop:update(dt)

  --camera:move(
  --  ((-camera.x + (objects.lolo.body:getX()- 8 + objects.oce.body:getX()- 8) / 2 ) / 10.0),
  --  ((-camera.y + (objects.lolo.body:getY()-12 + objects.oce.body:getY()-12) / 2 ) / 10.0)
  --)
  camera:move((-camera.x+objects.oce.x-8)/10, (-camera.y+objects.oce.y-12)/10)
  camera:setScale(1.0/3.0, 1.0/3.0)

  Collider:update(dt)
end

function love.draw()
  camera:set()
  map:autoDrawRange(-camera.x + love.graphics.getWidth() / 2, -camera.y + love.graphics.getHeight() / 2, 1, -100)
  map:_updateTileRange()

  for z,layer in pairs(map.drawList) do
    if type(layer) == "table" then
      layer.z = z
      if layer.name == 'oce_tiles' then layer.world = 'oce' end
      if layer.name == 'lolo_tiles' then layer.world = 'lolo' end
      objects[layer.name] = layer
    end
  end

  for i=-10,10,1 do
    for _,o in pairs(objects) do 
      print(o.world)
      if o.world == current_world or not o.world then
        love.graphics.setColor(255,255,255,255)
      else
        love.graphics.setColor(0,0,255,64)
      end
      if o.z == i then o:draw() end
    end
  end

  camera:unset()
  --love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function onCollision(dt, shape_a, shape_b, dx, dy)
  if shape_a == objects.oce.body then objects.oce:onCollision(dt, shape_b, dx, dy) end
  if shape_b == objects.oce.body then objects.oce:onCollision(dt, shape_a, dx, dy) end
end

function onCollisionStop(dt, shape_a, shape_b, dx, dy)
  if shape_a == objects.oce.body then objects.oce:onCollisionStop(dt, shape_b, dx, dy) end
  if shape_b == objects.oce.body then objects.oce:onCollisionStop(dt, shape_a, dx, dy) end
end