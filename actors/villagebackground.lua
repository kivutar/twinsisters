VillageBackground = class('VillageBackground')

VillageBackground.sky = love.graphics.newImage('backgrounds/villagesky.png')
VillageBackground.sky:setFilter("nearest", "nearest")

VillageBackground.paralax = {
  { img=love.graphics.newImage('backgrounds/mountains2.png'), x=99, y=99 },
  { img=love.graphics.newImage('backgrounds/mountains1.png'), x= 4, y= 4 },
  { img=love.graphics.newImage('backgrounds/mountains0.png'), x= 2, y= 2 },
}
for _,bg in pairs(VillageBackground.paralax) do bg.img:setFilter("nearest", "nearest") end

function VillageBackground:initialize(x, y, z)
  self.x = 0
  self.y = 0
  self.z = 0
end

function VillageBackground:draw_before()
  love.graphics.draw(VillageBackground.sky)
end

function VillageBackground:draw()
  for _,bg in pairs(VillageBackground.paralax) do
    for i=-5,6,1 do
      love.graphics.draw(
        bg.img,
        i*128*4 + camera.x - camera.x/bg.x,
        camera.y - 64*4 + ((400*4 - camera.y)/bg.y),
        0, 1, 1, 0, 0
      )
    end
  end
end
