BlurH = class('BlurH')

function BlurH:initialize()
  self.pe = love.graphics.newPixelEffect [[
    const float blurSize = 0.1/512.0;
    vec4 effect(vec4 global_color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
      vec4 sum = vec4(0.0);
      float fade = 0.0001;
      sum += (texture2D(texture, vec2(texture_coords.x - 4.0*blurSize, texture_coords.y)) * 0.05)-fade;
      sum += (texture2D(texture, vec2(texture_coords.x - 3.0*blurSize, texture_coords.y)) * 0.09)-fade;
      sum += (texture2D(texture, vec2(texture_coords.x - 2.0*blurSize, texture_coords.y)) * 0.12)-fade;
      sum += (texture2D(texture, vec2(texture_coords.x - blurSize, texture_coords.y)) * 0.15)-fade;
      sum += (texture2D(texture, vec2(texture_coords.x, texture_coords.y)) * 0.181)-fade;
      sum += (texture2D(texture, vec2(texture_coords.x + blurSize, texture_coords.y)) * 0.15)-fade;
      sum += (texture2D(texture, vec2(texture_coords.x + 2.0*blurSize, texture_coords.y)) * 0.12)-fade;
      sum += (texture2D(texture, vec2(texture_coords.x + 3.0*blurSize, texture_coords.y)) * 0.09)-fade;
      sum += (texture2D(texture, vec2(texture_coords.x + 4.0*blurSize, texture_coords.y)) * 0.05)-fade;
      sum.a = 1;
      return sum ;
    }
  ]]

  self.canvas = love.graphics.newCanvas()
end