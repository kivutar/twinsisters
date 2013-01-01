LoveLogo = class('LoveLogo')

function LoveLogo:initialize()
  self.z = 0
  TEsound.play('sounds/logo.wav')
  CRON.after(3, function()
    actors.list.transition = FadeTransition:new( function () actors.switchMap('title') end )
  end )
end