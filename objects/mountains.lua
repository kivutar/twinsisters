class "Mountains" {}

Mountains.paralax = {
  { img=love.graphics.newImage('backgrounds/mountains2.png'), x=2, y=9 },
  { img=love.graphics.newImage('backgrounds/mountains1.png'), x=3, y=6 },
  { img=love.graphics.newImage('backgrounds/mountains0.png'), x=5, y=4 },
}
for _,bg in pairs(Mountains.paralax) do bg.img:setFilter("nearest", "nearest") end

function Mountains:__init(w, x, y, z)
  self.w = w
  self.x = x
  self.y = y
  self.z = z

  self.body = {}
end

function Mountains:update(dt)
end

function Mountains:draw()
  for _,bg in pairs(Mountains.paralax) do
    for i=-6,6,1 do
      love.graphics.draw(
        bg.img,
        i*128 + camera.x / bg.x,
        -128 + (love.graphics.getHeight() / 2) + camera.y / bg.y,
        0, 1, 1, 0, 0
      )
    end
  end
end

function Mountains:onCollision()
end

function Mountains:onCollisionStop()
end