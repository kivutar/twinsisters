DoomBackground = class('DoomBackground')

DoomBackground.night = love.graphics.newImage('backgrounds/doomsky.png')
DoomBackground.night:setFilter("nearest", "nearest")

DoomBackground.moon = love.graphics.newImage('backgrounds/moon.png')
DoomBackground.moon:setFilter("nearest", "nearest")

function DoomBackground:initialize(x, y, z)
  self.x = 0
  self.y = 0
  self.z = 0
end

function DoomBackground:draw_before()
  love.graphics.draw(DoomBackground.night)
end

function DoomBackground:draw()
  love.graphics.draw(DoomBackground.moon, camera.x+250, camera.y-400, 0, 1, 1, 0, 0)
end