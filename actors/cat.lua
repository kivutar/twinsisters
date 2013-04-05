Cat = class('Cat')
Cat:include(Gravity)
Cat:include(Blinking)

Cat.anim = {}
for _,skin in pairs({'cat'}) do
  Cat.anim[skin] = {}
  for stance, speed in pairs({stand=0.2, walk=1, jump=1, fall=1, surf=1, antisurf=1}) do
    Cat.anim[skin][stance] = {}
    for _,direction in pairs({'left', 'right'}) do
      img = love.graphics.newImage('sprites/'..skin..'_'..stance..'_'..direction..'.png')
      img:setFilter('nearest', 'nearest')
      Cat.anim[skin][stance][direction] = newAnimation(img , 16, 16, speed, 0)
    end
  end
end

function Cat:initialize(x, y, z, properties)
  self.name = properties.name or 'lolo'
  self.skin = properties.skin or 'cat'
  self.x = x
  self.y = y
  self.z = 30

  self.persistant = true

  self.type = "Cat"

  self.body = Collider:addPolygon(-8,-8, -8,8, 8,8, 8,-8)
  self.body.parent = self
  self.feet = Collider:addPolygon(-7,0, 7,0, 7,1, -7,1)
  self.feet.parent = self

  self.xspeed = 0
  self.max_xspeed = 100
  self.yspeed = 0
  self.jumpspeed = 200
  self.friction = 750
  self.airfriction = 75
  self.acceleration = 20
  self.airacceleration = 1000
  self.groundspeed = 0
  self.iwf = 1

  self.stance = 'stand'
  self.direction = 'left'
  self.animation = Cat.anim[self.skin][self.stance][self.direction]

  self.ondoor = false
  self.onground = false
  self.onbridge = false
  self.onice = false
  self.inwater = false
  self.daft = false
  self.invincible = false
  self.swimming = false
  self.attacking = false

  self.jump_pressed = true
  self.switch_pressed = true
  self.open_pressed = true
  self.sword_pressed = true
  self.fire_pressed = true

  self.maxHP = 6*4
  self.HP = self.maxHP

  if self.name == 'lolo' then self.controls = controls.p1 else self.controls = controls.p2 end
end

function Cat:applyFriction(dt)
  local f = 0
  if self.onground then f = self.friction else f = self.airfriction end
  if self.xspeed > 0 then
    self.xspeed = self.xspeed - f * dt
    if self.xspeed < 0 then self.xspeed = 0 end
  elseif self.xspeed < 0 then
    self.xspeed = self.xspeed + f * dt
    if self.xspeed > 0 then self.xspeed = 0 end
  end
end

function Cat:update(dt)
  if self.name == 'lolo' then self.controls = controls.p1 else self.controls = controls.p2 end

  self.ondoor = false
  self.onground = false
  self.onbridge = false
  self.inwater  = false
  self.onice = false
  for _,n in pairs(self.body:neighbors()) do
    collides, dx, dy = self.body:collidesWith(n)
    if n.parent.class.name == 'Water' then
      self.inwater = true
    end
    if n.parent.class.name == 'Door' then
      self.ondoor = n.parent
    end
  end

  for _,n in pairs(Collider:shapesInRange(self.x-38,self.y-50, self.x+38,self.y+50)) do

    collides, dx, dy = n:collidesWith(self.body)

    if n:collidesWith(self.feet) then
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
      end
      if n.parent.class.name == 'Ice' then
        self.onice = true
      end
    end

  end

  self.iwf = self.inwater and 0.5 or 1

  if self.onice then
    self.friction = 0
    self.max_xspeed = 200
  else
    self.friction = 400
    self.max_xspeed = 50
  end
  if not self.onground then self.max_xspeed = 100 end

  -- Moving on x axis
  -- Moving right
  if self.controls.right and not self.daft then
    --if not (self.direction == 'left' and self.attacking) then
      self.direction = 'right'
      self.stance = 'walk'
      local a = 0
      if self.onground then a = self.acceleration else a = self.airacceleration end
      self.xspeed = self.xspeed + a * dt * self.iwf
    --end
  -- Moving left
  elseif self.controls.left and not self.daft then
    --if not (self.direction == 'right' and self.attacking) then
      self.direction = 'left'
      self.stance = 'walk'
      local a = 0
      if self.onground then a = self.acceleration else a = self.airacceleration end
      self.xspeed = self.xspeed - a * dt * self.iwf
    --end
  -- Stop moving
  else
    self:applyFriction(dt)
    self.stance = 'stand'
  end
  -- Apply friction if the character is attacking and on ground
  if self.attacking and self.onground then self:applyFriction(dt) end
  -- Apply maximum xspeed
  if math.abs(self.xspeed) > self.max_xspeed * self.iwf then self.xspeed = sign(self.xspeed) * self.max_xspeed * self.iwf end
  self.x = self.x + (self.xspeed + self.groundspeed) * dt * self.iwf

  Cat.anim[self.skin]['walk'][self.direction]:setSpeed(math.abs(self.xspeed))

  -- Jumping and swimming
  if self.controls.cross and not self.daft then
    if not self.jump_pressed then
      -- Jump from bridge
      if self.onbridge and self.controls.down then
        self.y = self.y + 32
        TEsound.play(sfx.jump)
      -- Regular jump
      elseif self.onground and not self.controls.down and not self.attacking then
        self.yspeed = - self.jumpspeed -- - math.abs(self.xspeed*0.25*self.iwf)
        TEsound.play(sfx.jump)
      -- Swimming
      elseif self.inwater then
        self.swimming = true
        self.yspeed = - self.jumpspeed * self.iwf
      end
    end
    self.jump_pressed = true
  else
    self.jump_pressed = false
  end

  -- Attacking
  if self.controls.circle and not self.daft then
    if not self.sword_pressed then
      if not self.attacking then
        self.attacking = true
        TEsound.play(sfx.sword2)
        local name = 'sword_'..self.name
        actors.list[name] = Sword:new(self)
        actors.list[name].type = 'Sword'
        actors.list[name].name = name
        CRON.after(0.25, function()
          self.attacking = false
          actors.list[name]:destroy()
        end)
      end
    end
    self.sword_pressed = true
  else
    self.sword_pressed = false
  end

  -- Fire
  --if self.fire_btn() and not self.daft then
  --  if not self.fire_pressed then
  --    if not self.attacking then
  --      self.attacking = true
  --      TEsound.play('sounds/shoot.wav')
  --      local name = 'Bullet_'..self.name..'_'..love.timer.getTime()
  --      actors.list[name] = Bullet:new(self)
  --      actors.list[name].type = 'Bullet'
  --      actors.list[name].name = name
  --      CRON.after(0.25, function() self.attacking = false end)
  --    end
  --  end
  --  self.fire_pressed = true
  --else
  --  self.fire_pressed = false
  --end

  -- Openning doors
  if self.controls.up and self.ondoor and self.onground and not self.daft then
    if not self.open_pressed then
      if self.ondoor.locked then
        actors.list.dialog = DialogBox:new("This door is locked!\nLet's see if we can find a key...", 30, function ()
          actors.list.dialog = DialogBox:new("Or maybe I should wait for something else to happen.", 30, DialogBox.destroy)
        end)
      else
        TEsound.play(sfx.door)
        map = ATL.load(self.ondoor.map..'.tmx')
        map.drawObjects = false
        love.graphics.setBackgroundColor(map.properties.r or 0, map.properties.g or 0, map.properties.b or 0)
        for k,o in pairs(actors.list) do
          if not o.persistant then
            if o.body then Collider:remove(o.body) end
            actors.list[k] = nil
          end
        end
        self.x = self.ondoor.tx*16*4
        self.y = self.ondoor.ty*16*4+8*4
        actors.addFromTiled(map.ol)
        camera:setScale(1)
        camera:follow({self}, 1)
      end
    end
      self.open_pressed = true
    else
      self.open_pressed = false
  end

  if not self.onground then self:applyGravity(dt) end

  self.y = self.y + self.yspeed * dt

  self:applyBlinking()

  self.body:moveTo(self.x, self.y)
  self.feet:moveTo(self.x, self.y+8)
  self.animation:update(dt)
end

function Cat:draw()
  self:blinkingPreDraw()
  -- Choose the character stance to display
  if self.yspeed > 0 then self.stance = 'fall' end
  if self.yspeed < 0 then self.stance = 'jump' end

  if not self.controls.right and not self.controls.left and (self.xspeed >  10 or self.xspeed < - 10) and self.onground then self.stance = 'walk' end
  if not self.controls.right and not self.controls.left and (self.xspeed > 100 or self.xspeed < -100) and self.onground then self.stance = 'surf' end

  if self.onground
  and (self.xspeed > 0 and self.controls.left )
  or  (self.xspeed < 0 and self.controls.right)
  then self.stance = 'antisurf' end

  if self.inwater and not self.onground and self.swimming then self.stance = 'swim' end
  --if self.attacking then self.stance = 'sword' end
  --if self.daft then self.stance = 'hit' end
  -- Set the new animation do display, but prevent animation self overriding
  self.nextanim = Cat.anim[self.skin][self.stance][self.direction]
  if self.animation ~= self.nextanim then
    self.animation = self.nextanim
    self.animation:seek(1)
  end
  -- Draw the animation
  self.animation:draw(math.floor(self.x-8), math.floor(self.y-8))
  self:blinkingPostDraw()

  -- love.graphics.setColor(255,   0, 255, 128)
  -- self.body:draw('fill')
  -- love.graphics.setColor(  0, 255, 255, 128)
  -- self.feet:draw('fill')
  -- love.graphics.setColor(255, 255, 255, 255)
end

function Cat:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  ---- Collision with Wall or FlyingWall or Ice
  if o.class.name == 'Wall' or o.class.name == 'FlyingWall' or o.class.name == 'Ice' then
  if dx ~= 0 and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
  if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end
  self.x, self.y = self.x - dx, self.y - dy
--
  ---- Collision with Slant
  --elseif o.class.name == 'Slant' then
  -- --if self.yspeed > 0 then self.yspeed = 0 end
  -- --self.y = self.y - dy
  -- --if dx ~= 0 then
  -- --  self.x = self.x - dx
  -- --  --if (dx < 1 or dx > 1) and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
  -- --end
  --  if dx ~= 0 and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
  --  if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end
  --  self.x, self.y = self.x - dx, self.y - dy

  -- Collision with Bridge
  elseif o.class.name == 'Bridge' then
    if dy > 0 and self.yspeed > 0 then
      self.yspeed = 0
      self.y = self.y - dy - math.abs(dx)
      self.x = self.x - dx
    end

  -- Collision with Gap
  elseif o.class.name == 'Gap' then
    if o.newx  ~= nil then self.x = o.newx*64 end
    if o.newy  ~= nil then self.y = o.newy*64 end
    if o.plusx ~= nil then self.x = self.x + o.plusx*64 end
    if o.plusy ~= nil then self.y = self.y + o.plusy*64 end
    actors.switchMap(o.target)

  -- Collision with Arrow
  elseif o.class.name == 'Arrow' then
    self.x, self.y = self.x - dx, self.y - dy
    if dy > 0 and self.yspeed > 0 then
      TEsound.play(sfx.arrow)
      self.yspeed = - 1.75 * self.jumpspeed
    end
    if dx ~= 0 and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
    if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end

  -- Collision with an enemy
  elseif (o.class.name == 'Crab'
       or o.class.name == 'UpDownSpike'
       or o.class.name == 'Spike'
       or o.class.name == 'AcidDrop')
  and not self.invincible then
    if not o.HP or o.HP > 0 then
      self.HP = self.HP - 1
      if self.HP <= 0 then
        TEsound.play(sfx.die)
        self.daft = true
        self.invincible = true
        --self.stance = 'hit'
        CRON.after(1, function()
          --actors.list[self.name] = nil
          --Collider:remove(self.body)
          --Cat.instances = Cat.instances - 1
        end)
      else
        TEsound.play(sfx.hit)
        if dx < -0.1 then self.xspeed = 3 elseif dx > 0.1 then self.xspeed = -3 end
        self.yspeed = -50
        self.invincible = true
        self.daft = true
        CRON.after(0.5, function() self.daft = false end)
        CRON.after(2  , function() self.invincible = false end)
      end
    end

  end
end
