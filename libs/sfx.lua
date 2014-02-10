sfx = {}

for _,v in pairs(love.filesystem.getDirectoryItems('sounds')) do
  if (string.find(v, ".wav")) then
    local name = string.gsub(v, '.wav', '')
    local source = love.audio.newSource('sounds/'..v, 'static')
    sfx[name] = source
  end
end