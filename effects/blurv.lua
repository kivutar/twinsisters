BlurV = class('BlurV')

function BlurV:initialize()
  self.pe = love.graphics.newPixelEffect [[
    const float blurSize = 1.0/512.0; 
    vec4 effect(vec4 global_color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
      vec4 sum = vec4(0.0);
      float fade = 0.00;
      sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y - 4.0*blurSize)) * 0.05;
      sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y- 3.0*blurSize)) * 0.09;
      sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y- 2.0*blurSize)) * 0.12;
      sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y - blurSize)) * 0.15;
      sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y)) * 0.16;
      sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + blurSize)) * 0.15;
      sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y  + 2.0*blurSize)) * 0.12;
      sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + 3.0*blurSize)) * 0.09;
      sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + 4.0*blurSize)) * 0.05;
      sum.a = 1;
      return sum ;
    }
  ]]

  self.canvas = love.graphics.newCanvas()
end