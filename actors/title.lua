Title = class('Title')

function Title:initialize()
  self.z = 0
  self.name = 'title'

  self.menu = Menu:new({

    { label = 'New game', callback = function ()
      actors.list.transition = FadeTransition:new( function () actors.switchMap('village') end )
    end },

    { label = 'Load a game state', callback = function ()
      print('Not implemented yet')
    end },

    { label = 'Quit without saving', callback = function ()
      actors.list.transition = CircleTransition:new( function () love.event.push("quit") end )
    end },

  })
end

function Title:update(dt)
  self.menu:update(dt)
end

function Title:draw_after()
    self.menu:draw()
end