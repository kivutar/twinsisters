function sign(x)
  return x < 0 and -1 or (x > 0 and 1 or 0)
end

function count(dict)
  for _,_ in pairs(dict) do
    return true
  end
  return false
end

function requiredir(dir)
  for _,v in pairs(love.filesystem.getDirectoryItems(dir)) do
    if (string.find(v, ".lua")) then
      require(dir..'/'..string.gsub(v, '.lua', ''))
    end
  end
end

function pipe( source, effect, destination )
  love.graphics.setCanvas(destination)
    if destination then destination:clear() end
    love.graphics.setPixelEffect(effect)
      love.graphics.draw(source, camera:ox(), camera:oy())
    love.graphics.setPixelEffect()
  love.graphics.setCanvas()
end