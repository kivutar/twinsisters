controls = {}

function controls:update()
  self.p = {}
  self.p1 = {}

  self.p1.left     = love.keyboard.isDown('left')   or love.joystick.getAxis(1,1) == -1
  self.p1.right    = love.keyboard.isDown('right')  or love.joystick.getAxis(1,1) ==  1
  self.p1.down     = love.keyboard.isDown('down')   or love.joystick.getAxis(1,2) ==  1
  self.p1.up       = love.keyboard.isDown('up')     or love.joystick.getAxis(1,2) == -1
  self.p1.cross    = love.keyboard.isDown(' ')      or love.joystick.isDown(1, 2)
  self.p1.triangle = love.keyboard.isDown('v')      or love.joystick.isDown(1, 4)
  self.p1.circle   = love.keyboard.isDown('b')      or love.joystick.isDown(1, 3)
  self.p1.square   = love.keyboard.isDown('c')      or love.joystick.isDown(1, 1)
  self.p1.start    = love.keyboard.isDown('escape') or love.joystick.isDown(1,10)
end