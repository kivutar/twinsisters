camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

function camera:ox()
  return self.x - love.graphics.getWidth()  / 2 * self.scaleX
end

function camera:oy()
  return self.y - love.graphics.getHeight() / 2 * self.scaleY
end

function camera:set()
  love.graphics.push()
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(- self:ox(), - self:oy())
end

function camera:unset()
  love.graphics.pop()
end

function camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
  -- Prevent the camera to go out of the map
  if self.x < love.graphics.getWidth()/2*self.scaleX then self.x = love.graphics.getWidth()/2*self.scaleX end
  if self.x > map.width*map.tileWidth - love.graphics.getWidth()/2*self.scaleX then self.x = map.width*map.tileWidth - love.graphics.getWidth()/2*self.scaleX end
  if self.y < love.graphics.getHeight()/2*self.scaleY then self.y = love.graphics.getHeight()/2*self.scaleY end
  if self.y > map.height*map.tileWidth - love.graphics.getHeight()/2*self.scaleY then self.y = map.height*map.tileWidth - love.graphics.getHeight()/2*self.scaleY end
  -- Center the map if smaller than screen
  if map.width  * map.tileWidth < love.graphics.getWidth()  * self.scaleX then self.x = map.width  * map.tileWidth / 2 end
  if map.height * map.tileWidth < love.graphics.getHeight() * self.scaleY then self.y = map.height * map.tileWidth / 2 end
end

function camera:setScale(sx, sy)
  sx = sx or 1
  self.scaleX = sx
  self.scaleY = sy or sx
end

function camera:follow(tofollow, latency)
  if #tofollow > 0 then
    tfx = 0
    tfy = 0

    for _,o in pairs(tofollow) do
      tfx = tfx + o.x
      tfy = tfy + o.y
    end

    camera:move(
      math.floor((-camera.x + tfx / #tofollow) / latency),
      math.floor((-camera.y + tfy / #tofollow) / latency)
    )
  else
    camera:move(-camera.x, -camera.y)
  end
end