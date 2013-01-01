Start = class('Start')

function Start:initialize()
  self.z = 0
  CRON.after(1, function()
    actors.list.transition = FadeTransition:new( function () actors.switchMap('lovelogo') end )
  end )
end