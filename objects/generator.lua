Generator = class('Generator')

function Generator:initialize(x, y, z, properties)
  self.x = x
  self.y = y
  self.z = z
  self.type = properties.type or 'Crab'
  self.period = properties.period or 5
  self.max = properties.max or -1
  self.offset = properties.offset or 1

  CRON.after(self.offset, function()
    CRON.every(self.period, function()
      if self.max < 0 or loadstring("return "..self.type..".instances < "..self.max)() then
        addObject( { type=self.type, x=self.x, y=self.y, z=self.z } )
      end
    end)
  end)
end
