local Component = require 'modules.component'
local groups = require 'components.groups'
local msgBus = require 'components.msg-bus'
local camera = require 'components.camera'
local Color = require 'modules.color'
local drawItem = require 'components.item-inventory.draw-item'
local config = require 'config'

local keyMap = config.keyboard
local mouseInputMap = config.mouseInputMap

local function ActiveItemHandler()
  local curCooldown = 0
  local skillCooldown = 0
  local activeItem = nil
  local max = math.max
  local itemDefinitions = require("components.item-inventory.items.item-definitions")
  local skill = {}

  function skill.set(item)
    local isDifferentSkill = item ~= activeItem
    -- reset cooldown
    if isDifferentSkill then
      curCooldown = 0
    end
    activeItem = item
  end

  function skill.use(self)
    if (not activeItem) or (curCooldown > 0) then
      return skill
    else
      local activateFn = itemDefinitions.getDefinition(activeItem).onActivateWhenEquipped
      local instance = activateFn(activeItem)
      curCooldown = instance.cooldown
      skillCooldown = instance.cooldown
      return skill
    end
  end

  function skill.updateCooldown(dt)
    curCooldown = max(0, curCooldown - dt)
    return skill
  end

  function skill.getStats()
    return curCooldown, skillCooldown
  end

  return skill
end

local skillHandlers = {
  SKILL_1 = (function()
    local max = math.max
    local curCooldown = 0
    local skillCooldown = 0
    local skill = {}

    local floor = math.floor
    local function modifyAbility(instance, modifiers)
      local v = instance
      local m = modifiers
			local energyCost = v.energyCost
			local baseWeapon = m.weaponDamage
			local totalWeaponDmg = v.weaponDamageScaling * baseWeapon
			local dmgMultiplier = 1 + m.percentDamage
			local min = floor((v.minDamage * dmgMultiplier) + m.flatDamage + totalWeaponDmg)
      local max = floor((v.maxDamage * dmgMultiplier) + m.flatDamage + totalWeaponDmg)

      -- update instance properties
      v:setProp('minDamage', min)
       :setProp('maxDamage', max)
       :setProp('cooldown', v.cooldown - (v.cooldown * m.cooldownReduction))

      return v
    end

    function skill.set(self)
    end

    function skill.use(self)
      if curCooldown > 0 then
        return skill
      else
        local Fireball = require 'components.fireball'
        local mx, my = camera:getMousePosition()
        local playerX, playerY = self.player:getPosition()
        local projectile = modifyAbility(
          Fireball.create({
              debug = false
            , x = playerX
            , y = playerY
            , x2 = mx
            , y2 = my
          }),
          self.rootStore:get().statModifiers
        )
        curCooldown = projectile.cooldown
        skillCooldown = projectile.cooldown
        return skill
      end
    end

    function skill.updateCooldown(dt)
      curCooldown = max(0, curCooldown - dt)
      return skill
    end

    function skill.getStats()
      return curCooldown, skillCooldown
    end

    return skill
  end)(),

  ACTIVE_ITEM_1 = ActiveItemHandler(),
  ACTIVE_ITEM_2 = ActiveItemHandler()
}

local function updateAbilities(self, dt)
  -- -- SKILL_1
  -- skillHandlers.SKILL_1.updateCooldown(dt)

  -- ACTIVE_ITEM_1
  local item = self.rootStore:get().equipment[self.slotY][self.slotX]
  skillHandlers[self.skillId].set(item)
  skillHandlers[self.skillId].updateCooldown(dt)
end

local ActiveSkillInfo = {
  group = groups.hud,
  x = 0,
  y = 0,
  skillId = nil,
  slotX = 1,
  slotY = 1,
  size = 32,
  player = nil,
  rootStore = nil
}

function ActiveSkillInfo.init(self)
  assert(skillHandlers[self.skillId] ~= nil, '[HUD activeItem] property `skillId` is required')
  assert(self.player ~= nil, '[HUD activeItem] property `player` is required')
  assert(self.rootStore ~= nil, '[HUD activeItem] property `rootStore` is required')

  msgBus.subscribe(function(msgType, value)
    if self:isDeleted() then
      return msgBus.CLEANUP
    end

    if msgBus.PLAYER_USE_SKILL == msgType and value == self.skillId then
      skillHandlers[self.skillId].use(self)
    end
  end)
end

function ActiveSkillInfo.update(self, dt)
  updateAbilities(self, dt)
end

function ActiveSkillInfo.draw(self)
  local boxSize = self.size

  love.graphics.setColor(0,0,0,0.8)
  love.graphics.rectangle('fill', self.x, self.y, boxSize, boxSize)
  love.graphics.setColor(1,1,1)
  love.graphics.rectangle('line', self.x, self.y, boxSize, boxSize)

  local activeItem = self.rootStore:get().equipment[self.slotY][self.slotX]
  if activeItem then
    drawItem(activeItem, self.x, self.y, boxSize)

    local cooldown, skillCooldown = skillHandlers[self.skillId].getStats()
    local progress = (skillCooldown - cooldown) / skillCooldown
    local offsetY = progress * boxSize
    love.graphics.setColor(1,1,1,0.2)
    love.graphics.rectangle('fill', self.x, self.y + offsetY, boxSize, boxSize - offsetY)

    if cooldown > 0 then
      local p = 5 -- padding
      self.hudTextLayer:add(
        string.format('%.1f', cooldown),
        Color.WHITE,
        self.x + p,
        self.y + p
      )
    end
  end
end

return Component.createFactory(ActiveSkillInfo)