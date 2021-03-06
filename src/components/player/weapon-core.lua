local Component = require 'modules.component'
local groups = require 'components.groups'
local AnimationFactory = require 'components.animation-factory'
local msgBus = require 'components.msg-bus'
local Color = require 'modules.color'
local iterateGrid = require 'utils.iterate-grid'
local halfRad = math.pi/2

local WeaponCore = {
  id = 'WEAPON_CORE',
  group = groups.all,
  muzzleFlashDuration = 0,
  recoilDuration = 0,
  recoilDurationRemaining = 0,
  facingX = 0,
  facingY = 0,
  drawOrder = function(self)
    local playerRef = Component.get('PLAYER')
    if (not playerRef) then
      return 1
    end

    -- adjust draw order based on the y-facing direction
    local config = require 'config.config'
    local offsetY = math.floor(self.facingY) * self.group.drawLayersPerGridCell
    return playerRef:drawOrder() + 1 + offsetY
  end
}

function WeaponCore.init(self)
  self.listeners = {
    msgBus.on(msgBus.PLAYER_WEAPON_ATTACK, function(msgValue)
      self.recoilDuration = msgValue.actionSpeed or 0.1
      self.recoilDurationRemaining = self.recoilDuration
    end),
    msgBus.on(msgBus.PLAYER_WEAPON_MUZZLE_FLASH, function(msgValue)
      self.muzzleFlashDuration = 0.1
      self.muzzleFlashColor = msgValue.color
      return msgValue
    end)
  }

  Component.create({
    id = 'familiar',
    x = 0,
    y = 0,
    init = function(self)
      Component.addToGroup(self, 'all')
      self.animationInner = AnimationFactory:newStaticSprite('companion/inner')
      self.animationOuter = AnimationFactory:newStaticSprite('companion/outer')

      self.outerAngle = 0
      self.clock = 0

      local tween = require 'modules.tween'
      self.rotTween = tween.new(3, self, { outerAngle = math.pi }, tween.easing.inOutQuart)
      self.rotDirection = 1
    end,

    update = function(self, dt)
      self.clock = self.clock + dt
      self.z = math.sin(self.clock) * 2
      local complete = self.rotTween:update(dt)
      if complete then
        self.rotDirection = self.rotDirection * -1
        self.rotTween:reset()
      end
    end,

    draw = function(self)
      love.graphics.setColor(1,1,1)
      local math = require 'utils.math'
      local x, y = math.round(self.x) + 0.5, math.round(self.y) + 0.5
      self.animationOuter:draw(x, y + self.z, self.outerAngle * self.rotDirection)
      self.animationInner:draw(x, y + self.z)
    end,

    drawOrder = function(self)
      return WeaponCore:drawOrder()
    end
  }):setParent(self)
end

local max = math.max
function WeaponCore.update(self, dt)
  self.recoilDurationRemaining = self.recoilDurationRemaining - dt
  self.muzzleFlashDuration = max(0, self.muzzleFlashDuration - dt)
  if self.renderAttachmentAnimation then
    self.renderAttachmentAnimation:update(
      dt * self.renderAttachmentAnimationSpeed
    )
  end

  local playerRef = Component.get('PLAYER')
  self.facingX, self.facingY = playerRef.facingDirectionX,
                               playerRef.facingDirectionY
  self.clock = (self.clock or 0) + dt
  self.z = math.sin(self.clock * 2.5) * 2
end


local function drawMuzzleFlash(color, x, y, angle, radius)
  local r,g,b,a = Color.multiply(color)
  local oBlendMode = love.graphics.getBlendMode()
  love.graphics.setBlendMode('add')

  love.graphics.setColor(r,g,b,a * 0.3)
  local centerOffsetX = 16
  local offsetX, offsetY = math.sin( -angle + halfRad ) * centerOffsetX,
    math.cos( -angle + halfRad ) * centerOffsetX
  love.graphics.circle(
    'fill',
    x + offsetX,
    y + offsetY,
    radius * 1.4
  )

  -- core
  love.graphics.setColor(r,g,b,0.6)
  local centerOffsetX = centerOffsetX - 3
  local offsetX, offsetY = math.sin( -angle + halfRad ) * centerOffsetX,
    math.cos( -angle + halfRad ) * centerOffsetX
  love.graphics.circle(
    'fill',
    x + offsetX,
    y + offsetY,
    radius * 0.65
  )

  love.graphics.setBlendMode(oBlendMode)
end

local function drawEquipment(equipmentAnimation, x, y, angle)
  local weaponLength = 26
  local spriteOffsetX, spriteOffsetY = equipmentAnimation:getSourceOffset()
  local offsetX, offsetY = math.sin( -angle + halfRad ) * (weaponLength),
    math.cos( -angle + halfRad ) * (weaponLength)

  love.graphics.setColor(0,0,0,0.17)
  love.graphics.draw(
    AnimationFactory.atlas,
    equipmentAnimation.sprite,
    x + offsetX,
    y + offsetY + 15,
    angle,
    1, 1,
    spriteOffsetX,
    spriteOffsetY
  )

  love.graphics.setColor(1,1,1)
  love.graphics.draw(
    AnimationFactory.atlas,
    equipmentAnimation.sprite,
    x + offsetX,
    y + offsetY,
    angle,
    1, 1,
    spriteOffsetX,
    spriteOffsetY
  )
end

function WeaponCore.draw(self)
  local state = self
  local playerRef = Component.get('PLAYER')
  if (not playerRef) then
    return
  end

  local playerX, playerY = playerRef:getPosition()
  self.angle = (math.atan2(self.facingX, self.facingY) * -1) + (math.pi/2)

  local recoilMaxDistance = -4
  local recoilDistance = self.recoilDurationRemaining > 0
    and (self.recoilDurationRemaining/self.recoilDuration * recoilMaxDistance)
    or 0
  local distFromPlayer = 14
  local posX = playerX + (self.facingX * distFromPlayer) + recoilDistance * math.sin(-self.angle + halfRad)
  local posY = playerY + (self.facingY * distFromPlayer) + recoilDistance * math.cos(-self.angle + halfRad)

  Component.get('familiar')
    :set('x', posX)
    :set('y', posY)

  if (self.muzzleFlashDuration > 0) then
    drawMuzzleFlash(
      self.muzzleFlashColor,
      posX,
      posY + self.z,
      self.angle,
      7
    )
  end

  local globalstate = require 'main.global-state'
  local rootStore = globalstate.gameState
  if rootStore then
    local gameState = rootStore:get()
    iterateGrid(gameState.equipment, function(item)
      local itemDef = require 'components.item-inventory.items.item-system'
      local definition = itemDef.getDefinition(item)
      local spriteName = definition and definition.renderAnimation
      if spriteName then
        local animation = AnimationFactory:newStaticSprite(spriteName)
        drawEquipment(animation, posX, posY, self.angle)
      end
    end)
  end
end

function WeaponCore.final(self)
  msgBus.off(self.listeners)
end

return Component.createFactory(WeaponCore)