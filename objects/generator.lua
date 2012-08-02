Generator = class('Generator')

function Generator:initialize(w, x, y, z, type, period)
  self.w = w
  self.x = x
  self.y = y
  self.z = z
  self.type = type or 'Crab'
  self.period = period or 5

  CRON.every(self.period, function()
    addObject( { type=self.type, x=self.x, y=self.y, z=self.z }, self.w )
  end)
end