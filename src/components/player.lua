local Color = require 'modules.color'
local groups = require 'components.groups'
local config = require 'config'
local animationFactory = require 'components.animation-factory'
local collisionWorlds = require 'components.collision-worlds'
local collisionObject = require 'modules.collision'
local camera = require 'components.camera'
local Position = require 'utils.position'

local colMap = collisionWorlds.map
local keyMap = config.keyboard
local mouseInputMap = config.mouseInputMap

local width, height = love.window.getMode()
local startPos = {
  x = 16 * 30,
  y = 16 * 30,
}

local frameRate = 60
local speed = 300 -- per frame

local activeAnimation
local DIRECTION_RIGHT = 1
local DIRECTION_LEFT = -1

local function collisionFilter(item, other)
  if other.group ~= 'obstacle' then
    return false
  end
  return 'slide'
end

local skillHandlers = {
  SKILL_1 = (function()
    local cooldown = 0.05
    local curCooldown = 0
    local skill = {}

    function skill.use(self)
      if curCooldown > 0 then
        return skill
      else
        local fireball = require 'components.fireball'
        local mx, my = camera:getMousePosition()
        fireball.create({
            debug = false
          , x = self.x
          , y = self.y
          , x2 = mx
          , y2 = my
        })
        curCooldown = cooldown
        return skill
      end
    end

    function skill.updateCooldown(dt)
      curCooldown = curCooldown - dt
      return skill
    end

    return skill
  end)()
}

local Player = {
  getInitialProps = function()
    return {
      x = startPos.x,
      y = startPos.y,

      -- collision properties
      type = 'player',
      h = 1,
      w = 1,
    }
  end,

  init = function(self)
    self.dir = DIRECTION_RIGHT
    colMap:add(self, self.x, self.y, self.w, self.h)

    self.animations = {
      idle = animationFactory:new({
        'character-1',
        'character-8',
        'character-9',
        'character-10',
        'character-11'
      }),
      run = animationFactory:new({
        'character-15',
        'character-16',
        'character-17',
        'character-18',
      })
    }

    local pixelOutlineShader = love.filesystem.read('modules/shaders/pixel-outline.fsh')
    self.outlineColor = {1,1,1,1}
    self.shader = love.graphics.newShader(pixelOutlineShader)
    local atlasData = animationFactory.atlasData
    self.shader:send('sprite_size', {atlasData.meta.size.w, atlasData.meta.size.h})
    self.shader:send('outline_width', 1)
    self.shader:send('outline_color', self.outlineColor)

    self.colObj = collisionObject:new(
      'player',
      self.x,
      self.y,
      self.w,
      self.h
    ):addToWorld(colMap)
  end,

  -- drawOrder = function(self)
  --   return 700
  -- end,

  update = function(self, dt)
    local moveAmount = speed * dt
    local moving = false
    local origx, origy = self.x, self.y

    local mx, my = camera:getMousePosition()
    local dx = Position.getDirection(self.x, self.y, mx, my)
    self.dir = dx > 0 and DIRECTION_RIGHT or DIRECTION_LEFT

    -- MOVEMENT
    if love.keyboard.isDown(keyMap.RIGHT) then
      self.x = self.x + moveAmount
      moving = true
    end

    if love.keyboard.isDown(keyMap.LEFT) then
      self.x = self.x - moveAmount
      moving = true
    end

    if love.keyboard.isDown(keyMap.UP) then
      self.y = self.y - moveAmount
      moving = true
    end

    if love.keyboard.isDown(keyMap.DOWN) then
      self.y = self.y + moveAmount
      moving = true
    end

    -- ANIMATION STATES
    if moving then
      self.animation = self.animations.run
        :update(dt/2)
    else
      self.animation = self.animations.idle
        :update(dt/12)
    end

    -- SKILL_1
    if love.keyboard.isDown(keyMap.SKILL_1) or love.mouse.isDown(mouseInputMap.SKILL_1) then
      skillHandlers.SKILL_1.use(self)
    end
    skillHandlers.SKILL_1.updateCooldown(dt)

    -- dynamically get the current animation frame's height
    local sx, sy, sw, sh = self.animation.sprite:getViewport()
    local w,h = sw, sh
    -- true center taking into account pivot
    local nextx, nexty = self.x, self.y
    local oX, oY = self.animation:getSourceOffset()
    local col = self.collisionObj

    -- COLLISION UPDATES
    self.colObj:update(
      -- use current coordinates because we only want to update size
      origx,
      origy,
      w,
      h,
      oX,
      oY
    )

    local actualX, actualY = self.colObj:move(nextx, nexty, collisionFilter)
    self.x = actualX
    self.y = actualY
    self.h = h
    self.w = w

    camera:setPosition(self.x, self.y)
  end
}

local function drawShadow(self, sx, sy, ox, oy)
  -- SHADOW
  love.graphics.setColor(0,0,0,0.2)
  love.graphics.draw(
    animationFactory.atlas,
    self.animation.sprite,
    self.x,
    self.y + self.h/2,
    math.rad(self.angle),
    sx,
    -sy / 2,
    ox,
    oy
  )
end

local function drawDebug(self)
  if config.collisionDebug then
    local ox, oy = self.animation:getOffset()
    love.graphics.setColor(1,1,1,0.5)
    local debug = require 'modules.debug'
    debug.boundingBox(
      'fill',
      self.x - ox,
      self.y - oy,
      self.w,
      self.h,
      false
    )
  end
end

function Player.draw(self)
  local ox, oy = self.animation:getOffset()
  local scaleX, scaleY = 1 * self.dir, 1

  drawShadow(self, scaleX, scaleY, ox, oy)
  drawDebug(self)

  love.graphics.setShader(self.shader)
  love.graphics.draw(
    animationFactory.atlas,
    self.animation.sprite,
    self.x,
    self.y,
    math.rad(self.angle),
    scaleX,
    scaleY,
    ox,
    oy
  )
  love.graphics.setShader()
end

local playerFactory = groups.all.createFactory(Player)

return playerFactory