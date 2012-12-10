Posterization = class('Posterization')

function Posterization:initialize()
  self.pe = love.graphics.newPixelEffect [[
    vec4 effect(vec4 c, Image tex, vec2 tc, vec2 p)
    {
      return floor(Texel(tex, tc) * 3.0) / 3.0;
    }
  ]]

  self.t = 0

  self.canvas = love.graphics.newCanvas()
end