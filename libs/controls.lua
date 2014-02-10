controls = {}

function controls:update()
  self.p = {}
  self.p1 = {}
  self.p2 = {}

  self.p1.left     = love.keyboard.isDown('left')  
  self.p1.right    = love.keyboard.isDown('right') 
  self.p1.down     = love.keyboard.isDown('down')  
  self.p1.up       = love.keyboard.isDown('up')    
  self.p1.cross    = love.keyboard.isDown(' ')     
  self.p1.triangle = love.keyboard.isDown('v')     
  self.p1.circle   = love.keyboard.isDown('b')     
  self.p1.square   = love.keyboard.isDown('c')     
  self.p1.start    = love.keyboard.isDown('escape')
end