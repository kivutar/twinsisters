Generator = class('Generator')

function Generator:initialize(w, x, y, z, type, period, max, offset)
  self.w = w
  self.x = x
  self.y = y
  self.z = z
  self.type = type or 'Crab'
  self.period = period or 5
  self.max = max or -1
  self.offset = offset or 1

  CRON.after(self.offset, function()
    CRON.every(self.period, function()
      if self.max < 0 or loadstring("return "..self.type..".instances < "..self.max)() then
        addObject( { type=self.type, x=self.x, y=self.y, z=self.z }, self.w )
      end
    end)
  end)
end