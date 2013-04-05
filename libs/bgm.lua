bgm = {}

for _,v in pairs(love.filesystem.enumerate('bgm')) do
  if (string.find(v, ".ogg")) then
    local name = string.gsub(v, '.ogg', '')
    local source = love.audio.newSource('bgm/'..v, 'static')
    bgm[name] = source
  end
end