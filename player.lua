class "Player" {}

function Player:__init(id, skin, x, y, z)
  self.id = id
  self:setSkin(skin)

  self.animation = self.anim.stand.left

  -- Physics
  self.body = love.physics.newBody(world, x, y, "dynamic") 
  self.body:setMass(50)
  self.body:setLinearDamping(1)
  self.body:setFixedRotation(true)
  self.shape = love.physics.newCircleShape(8)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setFriction(1)
  self.fixture:setRestitution(0)
  self.fixture:setUserData(self.id)

  self.z = z
  self.xspeed = 50
  self.max_xspeed = 150
  self.direction = 'left'
  self.stance = 'stand'
  self.onground = false
  self.vx = 0
  self.vy = 0
  self.nx = 0
  self.ny = 0
  self.contacts = 0

  self.jump_pressed = false

  self.left_btn = loadstring("return love.joystick.getAxis(1,1) == -1 or love.keyboard.isDown('left')")
  self.right_btn = loadstring("return love.joystick.getAxis(1,1) == 1 or love.keyboard.isDown('right')")
  self.jump_btn = loadstring("return love.joystick.isDown(1, 2) or love.keyboard.isDown('up')")
end

function Player:update(dt)

  self.vx, self.vy = self.body:getLinearVelocity()

  if self.right_btn() then
    if self.vx < self.max_xspeed then self.body:applyForce(self.xspeed, self.nx) end
    self.direction = 'right'
    self.stance = 'run'
  elseif self.left_btn() then
    if self.vx > -self.max_xspeed then self.body:applyForce(-self.xspeed, -self.nx) end
    self.direction = 'left'
    self.stance = 'run'
  else
    self.stance = 'stand'
  end
  self.fixture:setFilterData(self.fixture:getFilterData())

  if self.jump_btn() then
    if not self.jump_pressed and self.contacts > 0 and self.ny < -22 then
	  self.body:applyLinearImpulse(0, -16)
	  TEsound.play('sounds/jump.wav')
	end
    self.jump_pressed = true
  else
    self.jump_pressed = false
  end

  self.animation:update(dt)
end

function Player:draw()
  if self.contacts == 0 and self.vy >  1 then self.stance = 'fall' end
  if self.contacts == 0 and self.vy < -1 then self.stance = 'jump' end
  self.nextanim = self.anim[self.stance][self.direction]
  if self.animation ~= self.nextanim then self.animation = self.nextanim end
  self.animation:draw(self.body:getX()-16, self.body:getY()-24.5)
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