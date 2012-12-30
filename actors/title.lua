Title = class('Title')

function Title:initialize()
  self.z = 0
  self.name = 'title'
  gamestate = 'title'

  self.menu = Menu:new({
    { label='New game', callback=function ()

      actors.list.transition = Transition:new(actors.list.lolo.x, actors.list.lolo.y, 15, 

      function ()
        map = ATL.load('village.tmx')
        cache = love.graphics.newImage('maps/village.png')
        cache:setFilter("nearest", "linear")
        map.drawObjects = false
        love.graphics.setBackgroundColor(map.properties.r or 0, map.properties.g or 0, map.properties.b or 0)
        for k,o in pairs(actors.list) do
          if not o.persistant then
            if o.body then Collider:remove(o.body) end
            actors.list[k] = nil
          end
        end
        actors.addFromTiled(map.ol)
        --camera:setScale(1)
        camera:follow({actors.list.lolo}, 1)
        gamestate = 'play'
      end

      )

    end
    },
    { label='Load a game state', callback=function ()
      print('Not implemented yet')
    end },
    { label='Quit without saving', callback=function ()
      actors.list.transition = Transition:new(actors.list.lolo.x, actors.list.lolo.y, 15, function ()
        love.event.push("quit")
      end )
    end },
  })
end

function Title:update(dt)
  self.menu:update(dt)
end

function Title:draw_after()
  if gamestate == 'title' then
    self.menu:draw()
  end
end