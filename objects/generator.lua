Generator = class('Generator')

function Generator:initialize(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z
  self.casted = false
end

function Generator:update(dt)
  if math.floor(love.timer.getTime()) % 10 == 0 then
    if not self.casted then
      no = Crab:new(self.w, self.x+16, self.y+24, 6)
      name = no.name or 'Crab_generated_at_'..love.timer.getTime()
      objects[name] = no
      self.casted = true
    end
  else
    self.casted = false
  end
end