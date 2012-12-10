Distortion = class('Distortion')

function Distortion:initialize()
  self.pe = love.graphics.newPixelEffect [[
    extern number time;
    
    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
    {
      tc.y += sin(tc.x * 100 + time * 5.0) * .001;
      tc.x += sin(tc.y * 100 + time * 5.0) * .001;
      return Texel(tex,tc);
    }
  ]]

  self.t = 0

  self.canvas = love.graphics.newCanvas()
end

function Distortion:update(dt)
	self.t = self.t + math.min(dt, 1/30)
  self.pe:send("time", self.t)
end