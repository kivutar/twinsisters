Sword = class('Sword')

function Sword:initialize(player)
  self.player = player
  self.direction = self.player.direction
  self.w = self.player.w
  self.x = self.direction == 'left' and self.player.x - 15 or self.player.x + 15
  self.y = self.player.y
  self.z = self.player.z

  self.body = Collider:addCircle(self.x, self.y, 10)
  self.body.parent = self
end

function Sword:update(dt)
  self.direction = self.player.direction
  self.w = self.player.w
  self.x = self.direction == 'left' and self.player.x - 15 or self.player.x + 15
  self.y = self.player.y
  self.z = self.player.z
  self.body:moveTo(self.x, self.y)
end

function Sword:destroy()
  Collider:remove(self.body)
  objects[self.name] = nil
end