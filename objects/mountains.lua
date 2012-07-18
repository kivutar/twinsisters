class "Mountains" {}

Mountains.paralax = {
  { img=love.graphics.newImage('backgrounds/mountains2.png'), x=99, y=99 },
  { img=love.graphics.newImage('backgrounds/mountains1.png'), x= 4, y= 4 },
  { img=love.graphics.newImage('backgrounds/mountains0.png'), x= 2, y= 2 },
}
for _,bg in pairs(Mountains.paralax) do bg.img:setFilter("nearest", "nearest") end

function Mountains:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.color = {255, 255, 255, 255}
end

function Mountains:draw()
  love.graphics.setColor(unpack(self.color))
  for _,bg in pairs(Mountains.paralax) do
    for i=-3,4,1 do
      love.graphics.draw(
        bg.img,
        i*128 + camera.x - camera.x/bg.x,
        camera.y - 64 + ((400 - camera.y)/bg.y),
        0, 1, 1, 0, 0
      )
    end
  end
  love.graphics.setColor(255, 255, 255, 255)
end