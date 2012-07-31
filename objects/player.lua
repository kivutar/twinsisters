Player = class('Player')

Player.anim = {}
for _,skin in pairs({'lolo'}) do
  Player.anim[skin] = {}
  for stance, speed in pairs({stand=1, sword=(0.5/8), run=0.2, jump=0.1, fall=0.1, swim=0.2, hit=1, surf=1}) do
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
  self.max_xspeed = 2
  self.yspeed = 0.0
  self.jumpspeed = 200
  self.friction = 10
  self.airfriction = 1
  self.acceleration = 5
  self.groundspeed = 0

  self.stance = 'stand'
  self.direction = 'left'
  self.animation = Player.anim[self.skin][self.stance][self.direction]

  self.doors = {}
  self.onground = false
  self.onbridge = false
  self.onice = false
  self.inwater = false
  self.daft = false
  self.invincible = false
  self.swimming = false
  self.attacking = false
  self.color = {255, 255, 255, 255}

  self.jump_pressed = false
  self.switch_pressed = false
  self.open_pressed = true
  self.sword_pressed = true

  self.left_btn   = loadstring("return love.keyboard.isDown('left')  or love.joystick.getAxis(1,1) == -1")
  self.right_btn  = loadstring("return love.keyboard.isDown('right') or love.joystick.getAxis(1,1) ==  1")
  self.down_btn   = loadstring("return love.keyboard.isDown('down')  or love.joystick.getAxis(1,2) ==  1")
  self.up_btn     = loadstring("return love.keyboard.isDown('up')    or love.joystick.getAxis(1,2) == -1")
  self.jump_btn   = loadstring("return love.keyboard.isDown(' ')     or love.joystick.isDown(1,2)")
  self.switch_btn = loadstring("return love.keyboard.isDown('v')     or love.joystick.isDown(1,4)")
  self.sword_btn   = loadstring("return love.keyboard.isDown('b')     or love.joystick.isDown(1,3)")
  self.run_btn    = loadstring("return love.keyboard.isDown('c')     or love.joystick.isDown(1,1)")
end

function Player:update(dt)
  self.onground = false
  self.onbridge = false
  self.inwater  = false
  self.onice = false
  for n in self.body:neighbors() do
    collides, dx, dy = self.body:collidesWith(n)
    if collides and dy < 0 then
      if n.parent.class.name == 'Wall'
      or n.parent.class.name == 'Bridge'
      or n.parent.class.name == 'Slant'
      or n.parent.class.name == 'Ice'
      or n.parent.class.name == 'FlyingWall' then
        self.onground = true
        self.swimming = false
      end
      if n.parent.class.name == 'Bridge' then
        self.onbridge = true
        self.swimming = false
      end
      if n.parent.class.name == 'Ice' then
        self.onice = true
        self.swimming = false
      end
    end
    if n.parent.class.name == 'Water' then
      self.inwater = true
    end

  end

  local iw = self.inwater and 0.5 or 1

  if self.onice then
    self.friction = -0.1
    self.max_xspeed = 4
  else
    self.friction = 10
    self.max_xspeed = 2
  end

  --if self.run_btn() then self.max_xspeed = 2 else self.max_xspeed = 1 end
  
  -- Moving on x axis
  -- Moving right
  if self.right_btn() and not self.daft then
    if not (self.direction == 'left' and self.attacking) then
      self.direction = 'right'
      self.stance = 'run'
      if self.xspeed < 0 and not self.onice then self.xspeed = 0 end
      if math.abs(self.xspeed) <= self.max_xspeed * iw then self.xspeed = self.xspeed + self.acceleration * dt * iw end
    end
  -- Moving left
  elseif self.left_btn() and not self.daft then
    if not (self.direction == 'right' and self.attacking) then
      self.direction = 'left'
      self.stance = 'run'
      if self.xspeed > 0 and not self.onice then self.xspeed = 0 end
      if math.abs(self.xspeed) <= self.max_xspeed * iw then self.xspeed = self.xspeed - self.acceleration * dt * iw end
    end
  -- Stop moving
  else
    f = 0
    if self.onground then f = self.friction else f = self.airfriction end
    if self.xspeed >=  f * dt then self.xspeed = self.xspeed - f * dt end
    if self.xspeed <= -f * dt then self.xspeed = self.xspeed + f * dt end
    self.stance = 'stand'
  end
  -- Apply friction if the character is attacking and on ground
  if self.attacking and self.onground then
    f = 0
    if self.onground then f = self.friction else f = self.airfriction end
    if self.xspeed >=  f * dt then self.xspeed = self.xspeed - f * dt * 2 end
    if self.xspeed <= -f * dt then self.xspeed = self.xspeed + f * dt * 2 end
  end
  -- Apply minimum xspeed, to prevent bugs
  if math.abs(self.xspeed + self.groundspeed) > 0.2 then self.x = self.x + self.xspeed + self.groundspeed end

  -- Jumping and swimming
  if self.jump_btn() then
    if not self.jump_pressed then
      -- Jump from bridge
      if self.onbridge and self.down_btn() then
        self.y = self.y + 20
        TEsound.play('sounds/jump.wav')
      -- Regular jump
      elseif self.onground and not self.down_btn() and not self.attacking then
        self.yspeed = - self.jumpspeed -- - math.abs(self.xspeed*30*iw)
        TEsound.play('sounds/jump.wav')
      -- Swimming
      elseif self.inwater then
        self.swimming = true
        self.yspeed = - self.jumpspeed * iw
      end
    end
    self.jump_pressed = true
  else
    self.jump_pressed = false
  end

  -- Attacking
  if self.sword_btn() then
    if not self.sword_pressed then
      if not self.attacking then
        self.attacking = true
        TEsound.play('sounds/sword2.wav')
        objects['sword_'..self.id] = Sword:new(self)
        objects['sword_'..self.id].type = 'Sword'
        CRON.after(0.25, function()
          self.attacking = false
          if objects['sword_'..self.id] then
            Collider:remove(objects['sword_'..self.id].body)
            objects['sword_'..self.id] = nil
          end
        end)
      end
    end
    self.sword_pressed = true
  else
    self.sword_pressed = false
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
    if math.floor(love.timer.getTime() * 100) % 2 == 0 then self.color = {255, 255, 255, 255} else self.color = {0, 0, 0, 0} end
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
  if not self.right_btn() and not self.left_btn() and self.xspeed ~= 0 and self.onice then self.stance = 'surf' end
  if self.inwater and not self.onground and self.swimming then self.stance = 'swim' end
  if self.attacking then self.stance = 'sword' end
  if self.daft then self.stance = 'hit' end
  -- Set the new animation do display, but prevent animation self overriding
  self.nextanim = Player.anim[self.skin][self.stance][self.direction]
  if self.animation ~= self.nextanim then
    self.animation = self.nextanim
    self.animation:seek(1)
  end
  -- Draw the animation
  self.animation:draw(self.x-32, self.y-23.5-32)
  love.graphics.setColor(255, 255, 255, 255)
end

function Player:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belongs to another dimention
  if o.w ~= nil and o.w ~= self.w then return end

  -- Collision with Wall or FlyingWall or Ice
  if o.class.name == 'Wall' or o.class.name == 'FlyingWall' or o.class.name == 'Ice' then
    if dx ~= 0 and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
    if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end
    self.x, self.y = self.x - dx, self.y - dy

  -- Collision with Slant
  elseif o.class.name == 'Slant' then
    if dy > 0 and self.yspeed > 0 then
      self.yspeed = 0
      self.y = self.y - dy
    end
    if dx ~= 0 then
      self.x = self.x - dx
      --if (dx < 1 or dx > 1) and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
    end

  -- Collision with Bridge
  elseif o.class.name == 'Bridge' then
    if dy > 0 and self.yspeed > 0 then
      self.yspeed = 0
      self.y = self.y - dy - math.abs(dx)
      self.x = self.x - dx
    end

  -- Collision with Door
  elseif o.class.name == 'Door' then
    self.doors[o] = true

  -- Collision with Arrow
  elseif o.class.name == 'Arrow' then
    self.x, self.y = self.x - dx, self.y - dy
    if dy > 0 and self.yspeed > 0 then
      TEsound.play('sounds/arrow.wav')
      self.yspeed = - 1.75 * self.jumpspeed
    end

  -- Collision with Crab
  elseif (o.class.name == 'Crab' or o.class.name == 'UpDownSpike' or o.class.name == 'Spike') and not self.invincible then
    TEsound.play('sounds/hit.wav')
    if dx < -0.1 then self.xspeed = 3 elseif dx > 0.1 then self.xspeed = -3 end
    self.yspeed = -50
    self.invincible = true
    self.daft = true
    CRON.after(0.5, function() self.daft = false end)
    CRON.after(2  , function() self.invincible = false end)

  end
end

function Player:onCollisionStop(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belongs to another dimention
  if o.w ~= nil and o.w ~= self.w then return end

  -- Collision stop with Door
  if o.class.name == 'Door' then
    self.doors[o] = nil
  end
end