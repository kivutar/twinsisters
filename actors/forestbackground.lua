ForestBackground = class('ForestBackground')

ForestBackground.paralax = {
  { img=love.graphics.newImage('backgrounds/forestbackground2.png'), x= 99, y= 99 },
  { img=love.graphics.newImage('backgrounds/forestbackground1.png'), x= 4,  y= 4 },
  { img=love.graphics.newImage('backgrounds/forestbackground0.png'), x= 2,  y= 2 },

}
for _,bg in pairs(ForestBackground.paralax) do bg.img:setFilter("nearest", "nearest") end

function ForestBackground:initialize(x, y, z)
  self.z = 0
end

function ForestBackground:draw()

  for _,bg in pairs(ForestBackground.paralax) do
    for i=-5,6,1 do
      love.graphics.draw(
        bg.img,
        i*320 + camera.x - camera.x/bg.x,
        0,
        0, 1, 1, 0, 0
      )
    end
  end
end
