Sword = class('Sword')

function Sword:initialize(player)
  self.player = player
  self.direction = self.player.direction
  self.x = self.direction == 'left' and self.player.x - 15*4 or self.player.x + 15*4
  self.y = self.player.y
  self.z = self.player.z

  self.body = Collider:addCircle(self.x, self.y, 10*4)
  self.body.parent = self
end

function Sword:update(dt)
  self.direction = self.player.direction
  self.x = self.direction == 'left' and self.player.x - 15*4 or self.player.x + 15*4
  self.y = self.player.y
  self.z = self.player.z
  self.body:moveTo(self.x, self.y)
end

function Sword:destroy()
  Collider:remove(self.body)
  actors.list[self.name] = nil
end
