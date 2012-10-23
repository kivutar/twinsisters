DialogBox = class('DialogBox')

DialogBox.background = love.graphics.newImage('sprites/dialogbox.png')
DialogBox.background:setFilter("nearest", "nearest")

DialogBox.press_button = love.graphics.newImage('sprites/press_button.png')
DialogBox.press_button:setFilter("nearest", "nearest")

function DialogBox:initialize(message, speed, callback)
  self.message = message
  self.speed = speed or 30
  self.callback = callback
  self.display_len = 0
  self.old_display_len = 0
  self.z = 10
  self.finished = false
  self.btn_pressed = false
  gamestate = 'dialog'
end

function DialogBox:update(dt)
  if self.display_len <= self.message:len() then

    self.display_len = self.display_len + self.speed * dt

    if math.floor(self.display_len) > math.floor(self.old_display_len) then
      TEsound.play('sounds/type'..math.random(3)..'.wav')
      self.old_display_len = math.floor(self.display_len)
    end

    if (gameobjects.list.oce and gameobjects.list.oce.jump_btn())
    or (gameobjects.list.lolo and gameobjects.list.lolo.jump_btn()) then
      if not self.btn_pressed then
        self.speed = 100
      end
      self.btn_pressed = true
    else
      self.speed = 30
      self.btn_pressed = false
    end

  else
    self.finished = true

    if (gameobjects.list.oce and gameobjects.list.oce.jump_btn())
    or (gameobjects.list.lolo and gameobjects.list.lolo.jump_btn()) then
      if not self.btn_pressed then
        --self:destroy()
        self.callback()
      end
      self.btn_pressed = true
      if gameobjects.list.oce  then gameobjects.list.oce.jump_pressed = true end
      if gameobjects.list.lolo then gameobjects.list.lolo.jump_pressed = true end
    else
      self.btn_pressed = false
    end
  end
end

function DialogBox:draw()
  local uix = camera.x - love.graphics.getWidth()  / 2 * camera.scaleX
  local uiy = camera.y - love.graphics.getHeight() / 2 * camera.scaleY

  love.graphics.draw(DialogBox.background, uix, uiy, 0, 1, 1, 0, 0)

  love.graphics.setFont(font2)

  love.graphics.setColor(37, 82, 113, 255)
  love.graphics.printf("LAURIANE:", uix + 90*4, uiy + (192-16-40)*4, 180*4, 'left')

  love.graphics.setColor(0, 0, 0, 255)
  local message = string.sub(self.message, 1, math.floor(self.display_len))
  love.graphics.printf(message, uix + 90*4, uiy + (192-40)*4, 180*4, 'left')
  
  love.graphics.setColor(255, 255, 255, 255)

  if self.finished then
    love.graphics.draw(DialogBox.press_button, uix + 16*16*4, uiy+(16*13-40)*4, 0, 1, 1, 0, 0)
  end
end

function DialogBox:destroy()
  gameobjects.list.dialog = nil
  gamestate = 'play'
end
