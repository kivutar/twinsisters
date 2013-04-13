GameOver = class('GameOver')

function GameOver:initialize()
  self.z = 30
  self.name = 'gameover'

  self.menu = Menu:new({

    { label = 'Continue', callback = function ()
      actors.list.transition = FadeTransition:new( function () actors.switchMap('title') end )
    end },

    { label = 'Quit game', callback = function ()
      actors.list.transition = FadeTransition:new( function () love.event.push("quit") end )
    end },

  })
end

function GameOver:update(dt)
  self.menu:update(dt)
end

function GameOver:draw()
  self.menu:draw()
end