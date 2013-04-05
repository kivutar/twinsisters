StateLoader = class('StateLoader')

function StateLoader:initialize()
  self.z = 15
  self.name = 'StateLoader'
end

function StateLoader:draw()
  for i in pairs{0,1,2} do
    if i == 1 then o = 255 else o = 128 end

    love.graphics.setColor(255, 255, 255, o)
    love.graphics.rectangle('fill', camera:ox() + 16*1, camera:oy() + (16*4*i) - 32, 16*18, 16*3)
    love.graphics.setLine(2, "rough")
    love.graphics.setColor(0, 0, 255, o)
    love.graphics.rectangle('line', camera:ox() + 16*1, camera:oy() + (16*4*i) - 32, 16*18, 16*3)

    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print("New game", camera:ox() + 16 + 8, camera:oy() + (16*4*i) - 32 + 8)
  end
end