LoveLogo = class('LoveLogo')

function LoveLogo:initialize()
  self.z = 0
  TEsound.play(sfx.logo)
  CRON.after(3, function()
    actors.list.transition = FadeTransition:new( function () actors.switchMap('twinstudiologo') end )
  end )
end