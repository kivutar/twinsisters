Title = class('Title')

function Title:initialize()
  self.z = 15
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

function Title:draw()
  love.graphics.rectangle('fill', camera:ox() + 64*11, camera:oy() + 64*12 + 32, 64*8, 64*4)
  love.graphics.setLine(8, "smooth")
  love.graphics.setColor(0, 0, 255, 255)
  love.graphics.rectangle('line', camera:ox() + 64*11, camera:oy() + 64*12 + 32, 64*8, 64*4)
  self.menu:draw()
end