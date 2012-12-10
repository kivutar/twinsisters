Chromashift = class('Chromashift')

function Chromashift:initialize()
  self.pe = love.graphics.newPixelEffect [[
	  extern number time;
	
	  vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
	  {
	    vec2 shift = vec2(0.0, sin(time*5)/50);
	    return vec4(Texel(tex, tc+shift).r, Texel(tex,tc).g, Texel(tex,tc-shift).b, 1.0);
	  }
	]]

  self.t = 0

  self.canvas = love.graphics.newCanvas()
end

function Chromashift:update(dt)
	self.t = self.t + math.min(dt, 1/30)
  self.pe:send("time", self.t)
end