class "Player" {}

function Player:__init(id, skin, w, x, y, z)
  self.id = id
  self:setSkin(skin)
  self.w = w

  self.animation = self.anim.stand.left

  self.body = Collider:addCircle(x, y, 8)

  self.x = x
  self.y = y
  self.z = z

  self.dx = 0
  self.dy = 0

  self.gravity = 500

  self.xspeed = 0.0
  self.max_xspeed = 3.0
  self.yspeed = 0.0
  self.jumpspeed = 220
  self.friction = 0.1
  self.airfriction = 0.1
  self.acceleration = 0.1

  self.direction = 'left'
  self.stance = 'stand'

  self.onground = false
  self.onleft   = false
  self.onright  = false

  self.jump_pressed = false
  self.switch_pressed = false

  self.left_btn = loadstring("return love.joystick.getAxis(1,1) == -1 or love.keyboard.isDown('left')")
  self.right_btn = loadstring("return love.joystick.getAxis(1,1) == 1 or love.keyboard.isDown('right')")
  self.jump_btn = loadstring("return love.joystick.isDown(1,2) or love.keyboard.isDown(' ')")
  self.switch_btn = loadstring("return love.joystick.isDown(1,4) or love.keyboard.isDown('v')")
end

function Player:update(dt)

  if self.right_btn() and not self.onright then
    self.direction = 'right'
    self.stance = 'run'
    if self.xspeed < 0 then self.xspeed = 0.0 end
    if math.abs(self.xspeed) <= self.max_xspeed then self.xspeed = self.xspeed + self.acceleration end
    if self.dx < 2 and self.dx > -2 then
      self.y = self.y - self.dx * self.xspeed * 2
    end
  elseif self.left_btn() and not self.onleft then
    self.direction = 'left'
    self.stance = 'run'
    if self.xspeed > 0 then self.xspeed = 0.0 end
    if math.abs(self.xspeed) <= self.max_xspeed then self.xspeed = self.xspeed - self.acceleration end
    if self.dx < 2 and self.dx > -2 then
      self.y = self.y + self.dx * self.xspeed * 2
    end
  else
    if self.onground then
      if self.xspeed >= self.friction then
        self.xspeed = self.xspeed - self.friction
      end
      if self.xspeed <= -self.friction then
        self.xspeed = self.xspeed + self.friction
      end
    else
      if self.xspeed >= self.airfriction then
        self.xspeed = self.xspeed - self.airfriction
      end
      if self.xspeed <= -self.airfriction then
        self.xspeed = self.xspeed + self.airfriction
      end
    end
    self.stance = 'stand'
  end

  self.x = self.x + self.xspeed

  if self.jump_btn() then
    if not self.jump_pressed and self.onground then
      self.y = self.y - 1
      self.yspeed = - self.jumpspeed - math.abs(self.xspeed*20)
      TEsound.play('sounds/jump.wav')
    end
    self.jump_pressed = true
  else
    self.jump_pressed = false
  end

  if self.switch_btn() then
    if not self.switch_pressed then
      TEsound.play('sounds/switch.wav')
      if current_world == 'lolo' then 
        current_world = 'oce'
        setGhost('lolo')
        setSolid('oce')
        self:setSkin('oce')
      else
        current_world = 'lolo'
        setGhost('oce')
        setSolid('lolo')
        self:setSkin('lolo')
      end
      self.w = current_world
    end
    self.switch_pressed = true
  else
    self.switch_pressed = false
  end

  if not self.onground then
    self.y = self.y + self.yspeed * dt
    self.yspeed = self.yspeed + self.gravity * dt
  end

  self.body:moveTo(self.x, self.y)
  self.animation:update(dt)
end

function Player:draw()
  if not self.onground and self.yspeed > 0 then self.stance = 'fall' end
  if not self.onground and self.yspeed < 0 then self.stance = 'jump' end
  self.nextanim = self.anim[self.stance][self.direction]
  if self.animation ~= self.nextanim then self.animation = self.nextanim end
  self.animation:draw(self.x-16, self.y-24.5)
end

function Player:onCollision(dt, other, dx, dy)
  if other.type == 'Wall' then
    self.dx = dx
    self.dy = dy
    if dx < -1 then
      self.x = self.x - dx - 0.5
      self.onleft = true
      self.xspeed = 0
    elseif dx >  1 then
      self.x = self.x - dx + 0.5
      self.onright = true
      self.xspeed = 0
    end
    if dy < -1 then
      self.y = self.y - dy - 0.5
      self.yspeed = 0
    elseif dy > 1 then
      self.y = self.y - dy + 0.5
      self.onground = true
      self.yspeed = 0
    end
  elseif other.type == 'Spyke' then
    TEsound.play('sounds/hit.wav')
    self.x, self.y = 64, 420
  end
end

function Player:onCollisionStop(dt, other, dx, dy)
  self.onground = false
  self.onright = false
  self.onleft = false
  self.dx = 0
  self.dy = 0
end

function Player:setSkin(skin)
  -- Images
  self.img_stand_left = love.graphics.newImage('sprites/'..skin..'_stand_left.png')
  self.img_stand_left:setFilter("nearest","nearest")
  self.img_run_left = love.graphics.newImage('sprites/'..skin..'_run_left.png')
  self.img_run_left:setFilter("nearest","nearest")
  self.img_jump_left = love.graphics.newImage('sprites/'..skin..'_jump_left.png')
  self.img_jump_left:setFilter("nearest","nearest")
  self.img_fall_left = love.graphics.newImage('sprites/'..skin..'_fall_left.png')
  self.img_fall_left:setFilter("nearest","nearest")
  self.img_stand_right = love.graphics.newImage('sprites/'..skin..'_stand_right.png')
  self.img_stand_right:setFilter("nearest","nearest")
  self.img_run_right = love.graphics.newImage('sprites/'..skin..'_run_right.png')
  self.img_run_right:setFilter("nearest","nearest")
  self.img_jump_right = love.graphics.newImage('sprites/'..skin..'_jump_right.png')
  self.img_jump_right:setFilter("nearest","nearest")
  self.img_fall_right = love.graphics.newImage('sprites/'..skin..'_fall_right.png')
  self.img_fall_right:setFilter("nearest","nearest")

  -- Animations
  self.anim = {}
  self.anim.stand = {}
  self.anim.stand.left  = newAnimation(self.img_stand_left , 32, 32, 1.0, 1)
  self.anim.stand.right = newAnimation(self.img_stand_right, 32, 32, 1.0, 1)
  self.anim.run = {}
  self.anim.run.left    = newAnimation(self.img_run_left   , 32, 32, 0.2, 4)
  self.anim.run.right   = newAnimation(self.img_run_right  , 32, 32, 0.2, 4)
  self.anim.jump = {}
  self.anim.jump.left   = newAnimation(self.img_jump_left  , 32, 32, 0.1, 2)
  self.anim.jump.right  = newAnimation(self.img_jump_right , 32, 32, 0.1, 2)
  self.anim.fall = {}
  self.anim.fall.left   = newAnimation(self.img_fall_left  , 32, 32, 0.1, 2)
  self.anim.fall.right  = newAnimation(self.img_fall_right , 32, 32, 0.1, 2)
end