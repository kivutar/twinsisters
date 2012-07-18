camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

function camera:set()
  love.graphics.push()
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  ftx = math.floor(-self.x + love.graphics.getWidth()  / 2 * self.scaleX)
  fty = math.floor(-self.y + love.graphics.getHeight() / 2 * self.scaleY)
  love.graphics.translate(ftx,fty)
end

function camera:unset()
  love.graphics.pop()
end

function camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
  -- Prevent the camera to go out of the map
  if self.x < love.graphics.getWidth()/2*self.scaleX then self.x = love.graphics.getWidth()/2*self.scaleX end
  if self.x > map.width*16 - love.graphics.getWidth()/2*self.scaleX then self.x = map.width*16 - love.graphics.getWidth()/2*self.scaleX end
  if self.y < love.graphics.getHeight()/2*self.scaleY then self.y = love.graphics.getHeight()/2*self.scaleY end
  if self.y > map.height*16 - love.graphics.getHeight()/2*self.scaleY then self.y = map.height*16 - love.graphics.getHeight()/2*self.scaleY end
  -- Center the map if smaller than screen
  if map.width  * 16 < love.graphics.getWidth()  * self.scaleX then self.x = map.width  * 16 / 2 end
  if map.height * 16 < love.graphics.getHeight() * self.scaleY then self.y = map.height * 16 / 2 end
end

function camera:setScale(sx, sy)
  sx = sx or 1
  self.scaleX = sx
  self.scaleY = sy or sx
end

function camera:follow(tofollow, latency)
  tfx = 0
  tfy = 0

  for _,o in pairs(tofollow) do
    tfx = tfx + o.x
    tfy = tfy + o.y
  end

  camera:move(
    (-camera.x + tfx / #tofollow) / latency,
    (-camera.y + tfy / #tofollow) / latency
  )
end