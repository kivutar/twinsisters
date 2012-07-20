Player = class('Player')

Player.anim = {}
for _,skin in pairs({'oce'}) do
  Player.anim[skin] = {}
  for stance, speed in pairs({stand=1, slap=1, run=0.2, jump=0.1, fall=0.1}) do
    Player.anim[skin][stance] = {}
    for _,direction in pairs({'left', 'right'}) do
      img = love.graphics.newImage('sprites/'..skin..'_'..stance..'_'..direction..'.png')
      img:setFilter("nearest", "nearest")
      Player.anim[skin][stance][direction] = newAnimation(img , 64, 64, speed, 0)
    end
  end
end

function Player:initialize(id, skin, w, x, y, z)
  self.id = id
  self.skin = skin
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.persistant = true

  self.type = "Player"

  self.body = Collider:addPolygon(0,0, 0,12, 4,16, 12,16, 16,12, 16,0)
  self.body.parent = self

  self.gravity = 500

  self.xspeed = 0.0
  self.max_xspeed = 2.0
  self.yspeed = 0.0
  self.jumpspeed = 200
  self.friction = 10
  self.airfriction = 10
  self.acceleration = 10
  self.groundspeed = 0

  self.inwater = {}
  self.ondown = {}
  self.doors = {}

  self.stance = 'stand'
  self.direction = 'left'
  self.animation = Player.anim[self.skin][self.stance][self.direction]

  self.daft = false
  self.invincible = false
  self.attacking = false
  self.color = {255, 255, 255, 255}

  self.jump_pressed = false
  self.switch_pressed = false
  self.open_pressed = true
  self.slap_pressed = true

  self.left_btn   = loadstring("return love.keyboard.isDown('left')  or love.joystick.getAxis(1,1) == -1")
  self.right_btn  = loadstring("return love.keyboard.isDown('right') or love.joystick.getAxis(1,1) ==  1")
  self.down_btn   = loadstring("return love.keyboard.isDown('down')  or love.joystick.getAxis(1,2) ==  1")
  self.up_btn     = loadstring("return love.keyboard.isDown('up')    or love.joystick.getAxis(1,2) == -1")
  self.jump_btn   = loadstring("return love.keyboard.isDown(' ')     or love.joystick.isDown(1,2)")
  self.switch_btn = loadstring("return love.keyboard.isDown('v')     or love.joystick.isDown(1,4)")
  self.slap_btn   = loadstring("return love.keyboard.isDown('b')     or love.joystick.isDown(1,3)")

  self.cron = require 'libs/cron'
end

function Player:update(dt)
  self.cron.update(dt)

  local iw = count(self.inwater) and 0.75 or 1
  
  -- Moving on x axis
  -- Moving right
  if self.right_btn() and not self.daft then
    if not (self.direction == 'left' and self.attacking) then
      self.direction = 'right'
      self.stance = 'run'
      if self.xspeed < 0 then self.xspeed = 0 end
      if math.abs(self.xspeed) <= self.max_xspeed * iw then self.xspeed = self.xspeed + self.acceleration * dt * iw end
    end
  -- Moving left
  elseif self.left_btn() and not self.daft then
    if not (self.direction == 'right' and self.attacking) then
      self.direction = 'left'
      self.stance = 'run'
      if self.xspeed > 0 then self.xspeed = 0 end
      if math.abs(self.xspeed) <= self.max_xspeed * iw then self.xspeed = self.xspeed - self.acceleration * dt * iw end
    end
  -- Stop moving
  else
    f = 0
    if count(self.ondown) then f = self.friction else f = self.airfriction end
    if self.xspeed >=  f * dt then self.xspeed = self.xspeed - f * dt end
    if self.xspeed <= -f * dt then self.xspeed = self.xspeed + f * dt end
    self.stance = 'stand'
  end
  -- Apply friction if the character is attacking and on ground
  if self.attacking and count(self.ondown) then
    f = 0
    if count(self.ondown) then f = self.friction else f = self.airfriction end
    if self.xspeed >=  f * dt then self.xspeed = self.xspeed - f * dt * 2 end
    if self.xspeed <= -f * dt then self.xspeed = self.xspeed + f * dt * 2 end
  end
  -- Apply minimum xspeed, to prevent bugs
  if math.abs(self.xspeed + self.groundspeed) > 0.2 then self.x = self.x + self.xspeed + self.groundspeed end

  -- Jumping and swimming
  if self.jump_btn() then
    if not self.jump_pressed then
      -- Jump from bridge
      if count(self.ondown) and self.down_btn() then
        self.y = self.y + 20
        Player.ondown = {}
        TEsound.play('sounds/jump.wav')
      -- Regular jump
      elseif count(self.ondown) and not self.down_btn() and not self.attacking then
        self.yspeed = - self.jumpspeed * iw -- - math.abs(self.xspeed*30*iw)
        TEsound.play('sounds/jump.wav')
      -- Swimming
      elseif count(self.inwater) then
        self.yspeed = - self.jumpspeed * iw
      end
    end
    self.jump_pressed = true
  else
    self.jump_pressed = false
  end

  -- Attacking
  if self.slap_btn() then
    if not self.slap_pressed then
      self.attacking = true
      TEsound.play('sounds/sword.wav')
      objects['sword_'..self.id] = Sword:new(self)
      objects['sword_'..self.id].type = 'Sword'
      self.cron.after(0.5, function()
        self.attacking = false
        if objects['sword_'..self.id] then
          Collider:remove(objects['sword_'..self.id].body)
          objects['sword_'..self.id] = nil
        end
      end)
    end
    self.slap_pressed = true
  else
    self.slap_pressed = false
  end

  -- Switching
  --if self.switch_btn() then
  --  if not self.switch_pressed then
  --    TEsound.play('sounds/switch.wav')
  --    if current_world == 'lolo' then current_world = 'oce' else current_world = 'lolo' end
  --    self.skin = current_world
  --    self.w = current_world
  --  end
  --  self.switch_pressed = true
  --else
  --  self.switch_pressed = false
  --end

  -- Openning doors
  if self.up_btn() and count(self.doors) then
    if not self.open_pressed then
      for door,_ in pairs(self.doors) do
        TEsound.play('sounds/door.wav')
        map = ATL.load(door.map..'.tmx')
        map.drawObjects = false
        love.graphics.setBackgroundColor(map.properties.r, map.properties.g, map.properties.b)
        for k,o in pairs(objects) do
          if not o.persistant then
            if o.body then Collider:remove(o.body) end
            objects[k] = nil
          end
        end
        self.x = door.tx*16
        self.y = door.ty*16+8
        self.inwater = {}
        self.ondown = {}
        addObjects(map.ol)
        camera:setScale(1/map.properties.zoom, 1/map.properties.zoom)
        camera:move(-camera.x+objects.oce.x, -camera.y+objects.oce.y)
      end
    end
      self.open_pressed = true
    else
      self.open_pressed = false
  end

  -- Falling
  self.yspeed = self.yspeed + self.gravity * dt * iw
  self.y = self.y + self.yspeed * dt * iw

  -- Blinking
  if self.invincible then
    if love.timer.getTime()*1000 % 2 == 0 then self.color = {255, 255, 255, 255} else self.color = {0, 0, 0, 0} end
  else
    self.color = {255, 255, 255, 255}
  end

  self.body:moveTo(self.x, self.y)
  self.animation:update(dt)
end

function Player:draw()
  love.graphics.setColor(unpack(self.color))
  -- Choose the character stance to display
  if self.yspeed > 0 then self.stance = 'fall' end
  if self.yspeed < 0 then self.stance = 'jump' end
  if self.attacking then self.stance = 'slap' end
  -- Set the new animation do display, but prevent animation self overriding
  self.nextanim = Player.anim[self.skin][self.stance][self.direction]
  if self.animation ~= self.nextanim then self.animation = self.nextanim end
  -- Draw the animation
  self.animation:draw(self.x-16-16, self.y-23.5-32)
  love.graphics.setColor(255, 255, 255, 255)
end

function Player:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belongs to another dimention
  if o.w ~= nil and o.w ~= self.w then return end

  -- Collision with Wall or FlyingWall
  if o.class.name == 'Wall' or o.class.name == 'FlyingWall' then
    if dx ~= 0 and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
    if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end
    if dy > 0 then self.ondown[o] = true end
    self.x, self.y = self.x - dx, self.y - dy

  -- Collision with Bridge
  elseif o.class.name == 'Bridge' then
    if dy > 0 and self.yspeed > 0 then
      self.yspeed = 0
      self.ondown[o] = true
      self.y = self.y - dy
    end

  -- Collision with Door
  elseif o.class.name == 'Door' then
    self.doors[o] = true

  -- Collision with Spike
  elseif o.class.name == 'Spike' then
    TEsound.play('sounds/hit.wav')
    self.x, self.y = 64, 420

  -- Collision with Arrow
  elseif o.class.name == 'Arrow' then
    self.x, self.y = self.x - dx, self.y - dy
    if dy > 0 and self.yspeed > 0 then
      TEsound.play('sounds/arrow.wav')
      self.yspeed = - 1.75 * self.jumpspeed
    end

  -- Collision with Crab
  elseif o.class.name == 'Crab' and not self.invincible then
    TEsound.play('sounds/hit.wav')
    if dx < -0.1 then self.xspeed = 3 elseif dx > 0.1 then self.xspeed = -3 end
    self.invincible = true
    self.daft = true
    self.cron.after(2, function() self.daft = false end)
    self.cron.after(4, function() self.invincible = false end)

  -- Collision with Water
  elseif o.class.name == 'Water' then
    self.inwater[o] = true

  end
end

function Player:onCollisionStop(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belongs to another dimention
  if o.w ~= nil and o.w ~= self.w then return end

  -- Collision stop with Wall, FlyingWall, Bridge
  if o.class.name == 'Wall' or o.class.name == 'FlyingWall' or o.class.name == 'Bridge' then
    if dy > 0 then self.ondown[o] = nil end

  -- Collision stop with Water
  elseif o.class.name == 'Water' then
    self.inwater[o] = nil

  -- Collision stop with Door
  elseif o.class.name == 'Door' then
    self.doors[o] = nil
  end
end