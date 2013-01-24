TwinStudioLogo = class('TwinStudioLogo')

function TwinStudioLogo:initialize()
  self.z = 0
  TEsound.play(sfx.twinstudio)
  CRON.after(4, function()
    actors.list.transition = FadeTransition:new( function () actors.switchMap('title') end )
  end )
end