Bullet = class('Bullet')

Bullet.images = {}

Bullet.images.right = love.graphics.newImage('sprites/bullet_right.png')
Bullet.images.right:setFilter("nearest","nearest")

Bullet.images.left = love.graphics.newImage('sprites/bullet_left.png')
Bullet.images.left:setFilter("nearest","nearest")

Bullet.images.up = love.graphics.newImage('sprites/bullet_up.png')
Bullet.images.up:setFilter("nearest","nearest")

Bullet.images.down = love.graphics.newImage('sprites/bullet_down.png')
Bullet.images.down:setFilter("nearest","nearest")

function Bullet:initialize(player)
  self.player = player
  self.direction = self.player.direction

  if self.player.up_btn() then self.direction = 'up'
  elseif self.player.down_btn() then self.direction = 'down'
  else self.direction = self.player.direction end

  if     self.direction == 'left'  then self.tx = self.player.x - 60; self.ty = self.player.y
  elseif self.direction == 'right' then self.tx = self.player.x + 60; self.ty = self.player.y
  elseif self.direction == 'up'    then self.ty = self.player.y - 60; self.tx = self.player.x
  elseif self.direction == 'down'  then self.ty = self.player.y + 60; self.tx = self.player.x end

  self.x = self.tx
  self.y = self.ty
  self.z = self.player.z

  self.speed = 40

  self.var = math.random(-15, 15)

  self.halloratio = 0.3

  self.display = true

  self.image = Bullet.images[self.direction]

  self.body = Collider:addCircle(self.x, self.y, 3*4)
  self.body.parent = self

  CRON.after(0.75, function() Bullet.destroy(self) end)
end

function Bullet:update(dt)
  if self.direction == 'left'  then self.x = self.x - self.speed end
  if self.direction == 'right' then self.x = self.x + self.speed end
  if self.direction == 'up'    then self.y = self.y - self.speed end
  if self.direction == 'down'  then self.y = self.y + self.speed end
  if self.direction == 'left' or self.direction == 'right' then self.y = self.ty + math.cos(self.x / 3) * self.var end
  if self.direction == 'up'   or self.direction == 'down'  then self.x = self.tx + math.cos(self.y / 3) * self.var end
  self.body:moveTo(self.x, self.y)
end

function Bullet:draw()
  love.graphics.draw(self.image, self.x-32, self.y-32)
end

function Bullet:drawhallo()
  love.graphics.draw(hallo, self.x, self.y, 0, self.halloratio, self.halloratio, 256, 256)
end

function Bullet:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Collision with most objects
  if (o.class.name == 'Wall'
  or o.class.name == 'FlyingWall'
  or o.class.name == 'Bridge'
  or o.class.name == 'Arrow'
  or o.class.name == 'Ice'
  or o.class.name == 'Spike'
  or o.class.name == 'Sword'
  or o.class.name == 'Crab'
  or o.class.name == 'Slant') and not o.invincible then
    self.x = self.x - dx
    self.y = self.y - dy
    self.halloratio = 0.5
    self.speed = 0
    TEsound.play('sounds/explosion.wav')
    self:destroy()
  end

end

function Bullet:destroy()
  Collider:remove(self.body)
  gameobjects.list[self.name] = nil
end