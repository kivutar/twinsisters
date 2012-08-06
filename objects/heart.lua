Heart = class('Heart')
Heart:include(Blinking)

Heart.image = love.graphics.newImage('sprites/heart.png')
Heart.image:setFilter("nearest", "nearest")

function Heart:initialize(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = Collider:addCircle(self.x, self.y, 4)
  self.body.parent = self

  CRON.after(10, function() self.blinking = true end)
  CRON.after(13, function() Heart.destroy(self) end)
end

function Heart:update(dt)
  self:applyBlinking()
end

function Heart:draw()
  self:blinkingPreDraw()
  love.graphics.draw(Heart.image, self.x, self.y, 0, 1, 1, 4, 4)
  self:blinkingPostDraw()
end

function Heart:destroy()
  objects[self.name] = nil
  Collider:remove(self.body)
end

function Heart:onCollision(dt, shape, dx, dy)
  -- Get the other shape parent (its game object)
  local o = shape.parent

  -- Do nothing if the object belongs to another dimention
  if o.w ~= nil and o.w ~= self.w and self.w ~= nil then return end

  -- Collision with Player
  if o.class.name == 'Player' then
    o.HP = o.HP + 1
    if o.HP > o.maxHP then o.HP = o.maxHP end
    TEsound.play('sounds/heart.wav')
    self:destroy()

  end
end