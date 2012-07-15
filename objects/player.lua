class "Player" {}

Player.anim = {}
for _,skin in pairs({'lolo', 'oce'}) do
  Player.anim[skin] = {}
  for stance, speed in pairs({stand=1.0, run=0.2, jump=0.1, fall=0.1}) do
    Player.anim[skin][stance] = {}
    for _,direction in pairs({'left', 'right'}) do
      img = love.graphics.newImage('sprites/'..skin..'_'..stance..'_'..direction..'.png')
      img:setFilter("nearest", "nearest")
      Player.anim[skin][stance][direction] = newAnimation(img , 32, 32, speed, 0)
    end
  end
end

function Player:__init(id, skin, w, x, y, z)
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
  self.body.type = "Player"

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
  self.color = {255, 255, 255, 255}

  self.jump_pressed = false
  self.switch_pressed = false
  self.open_pressed = true

  self.left_btn = loadstring("return love.keyboard.isDown('left')")
  self.right_btn = loadstring("return love.keyboard.isDown('right')")
  self.down_btn = loadstring("return love.keyboard.isDown('down')")
  self.up_btn = loadstring("return love.keyboard.isDown('up')")
  self.jump_btn = loadstring("return love.keyboard.isDown(' ')")
  self.switch_btn = loadstring("return love.keyboard.isDown('v')")

  self.cron = require 'libs/cron'
end

function Player:update(dt)
  self.cron.update(dt)

  local iw = count(self.inwater) and 0.75 or 1
  
  -- Moving
  if self.right_btn() and not self.daft then
    self.direction = 'right'
    self.stance = 'run'
    if self.xspeed < 0 then self.xspeed = 0 end
    if math.abs(self.xspeed) <= self.max_xspeed * iw then self.xspeed = self.xspeed + self.acceleration * dt * iw end
  elseif self.left_btn() and not self.daft then
    self.direction = 'left'
    self.stance = 'run'
    if self.xspeed > 0 then self.xspeed = 0 end
    if math.abs(self.xspeed) <= self.max_xspeed * iw then self.xspeed = self.xspeed - self.acceleration * dt * iw end
  else
    f = 0
    if count(self.ondown) then f = self.friction else f = self.airfriction end
    if self.xspeed >=  f * dt then self.xspeed = self.xspeed - f * dt end
    if self.xspeed <= -f * dt then self.xspeed = self.xspeed + f * dt end
    self.stance = 'stand'
  end
  if math.abs(self.xspeed + self.groundspeed) > 0.2 then self.x = self.x + self.xspeed + self.groundspeed end

  -- Jumping
  if self.jump_btn() then
    if not self.jump_pressed then
      if count(self.ondown) and self.down_btn() then
        self.y = self.y + 20
        Player.ondown = {}
        TEsound.play('sounds/jump.wav')
      elseif count(self.ondown) and not self.down_btn() then
        self.yspeed = - self.jumpspeed * iw -- - math.abs(self.xspeed*30*iw)
        TEsound.play('sounds/jump.wav')
      elseif count(self.inwater) then
        self.yspeed = - self.jumpspeed * iw
      end
    end
    self.jump_pressed = true
  else
    self.jump_pressed = false
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
      for body,_ in pairs(self.doors) do
        map = ATL.load(body.parent.map..'.tmx')
        map.drawObjects = false
        Collider:clear()
        for k,o in pairs(objects) do
          if not o.persistant then
            --if o.body then Collider:remove(o.body) end
            objects[k] = nil
          end
        end
        self.x = body.parent.tx*16
        self.y = body.parent.ty*16+8
        self.body = Collider:addPolygon(0,0, 0,12, 4,16, 12,16, 16,12, 16,0)
        self.body.parent = self
        self.body.type = "Player"
        self.inwater = {}
        self.ondown = {}
        self.doors = {}
        addObjects(map.ol)
        camera:move(-camera.x+objects.oce.x-8, -camera.y+objects.oce.y-12)
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
  if self.yspeed > 0 then self.stance = 'fall' end
  if self.yspeed < 0 then self.stance = 'jump' end
  self.nextanim = Player.anim[self.skin][self.stance][self.direction]
  if self.animation ~= self.nextanim then self.animation = self.nextanim end
  self.animation:draw(self.x-16, self.y-23.5)
  love.graphics.setColor(255, 255, 255, 255)
end

function Player:onCollision(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w then return end

  -- Wall
  if other.type == 'Wall' or other.type == 'FlyingWall' then
    if dx ~= 0 and sign(self.xspeed) == sign(dx) then self.xspeed = 0 end
    if dy ~= 0 and sign(self.yspeed) == sign(dy) then self.yspeed = 0 end
    if dy > 0 then self.ondown[other] = true end
    self.x, self.y = self.x - dx, self.y - dy

  -- Bridge
  elseif other.type == 'Bridge' then
    if dy > 0 and self.yspeed > 0 then
      self.yspeed = 0
      self.ondown[other] = true
      self.y = self.y - dy
    end

  -- Door
  elseif other.type == 'Door' then
    self.doors[other] = true

  -- Spike
  elseif other.type == 'Spike' then
    TEsound.play('sounds/hit.wav')
    self.x, self.y = 64, 420

  -- Arrow
  elseif other.type == 'Arrow' then
    self.x, self.y = self.x - dx, self.y - dy
    if dy > 0 and self.yspeed > 0 then
      TEsound.play('sounds/arrow.wav')
      self.yspeed = - 1.75 * self.jumpspeed
    end

  -- Crab
  elseif other.type == 'Crab' and not self.invincible then
    TEsound.play('sounds/hit.wav')
    if dx < -0.1 then self.xspeed = 3 elseif dx > 0.1 then self.xspeed = -3 end
    self.invincible = true
    self.daft = true
    self.cron.after(2, function() self.daft = false end)
    self.cron.after(4, function() self.invincible = false end)

  -- Water
  elseif other.type == 'Water' then
    self.inwater[other] = true
  end
end

function Player:onCollisionStop(dt, other, dx, dy)
  if other.parent.w ~= nil and other.parent.w ~= self.w then return end
  if other.type == 'Wall' or other.type == 'FlyingWall' or other.type == 'Bridge' then
    if dy > 0 then self.ondown[other] = nil end
  elseif other.type == 'Water' then
    self.inwater[other] = nil
  elseif other.type == 'Door' then
    self.doors[other] = nil
  end
end