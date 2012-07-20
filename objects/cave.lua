Cave = class('Cave')

Cave.paralax = {
  { img=love.graphics.newImage('backgrounds/cave2.png'), x=99, y=99 },
  { img=love.graphics.newImage('backgrounds/cave1.png'), x= 4, y= 4 },
  { img=love.graphics.newImage('backgrounds/cave0.png'), x= 2, y= 2 },
}
for _,bg in pairs(Cave.paralax) do bg.img:setFilter("nearest", "nearest") end

function Cave:initialize(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.color = {255, 255, 255, 255}
end

function Cave:draw()
  love.graphics.setColor(unpack(self.color))
  for _,bg in pairs(Cave.paralax) do
    for i=-3,4,1 do
      love.graphics.draw(
        bg.img,
        i*256 + camera.x - camera.x/bg.x,
        camera.y - 256,
        0, 1, 1, 0, 0
      )
    end
  end
  love.graphics.setColor(255, 255, 255, 255)
end