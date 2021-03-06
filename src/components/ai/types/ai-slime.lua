local Component = require 'modules.component'
local groups = require 'components.groups'
local collisionWorlds = require 'components.collision-worlds'
local msgBus = require 'components.msg-bus'
local animationFactory = require 'components.animation-factory'
local collisionGroups = require 'modules.collision-groups'

local function slimeAttackCollisionFilter(item)
  return collisionGroups.matches(item.group, collisionGroups.player)
end

local SlimeAttack = Component.createFactory({
  group = groups.all,
  minDamage = 15,
  maxDamage = 20,
  itemLevel = 1,
  init = function(self)
    local attackX, attackY = self.x2 - self.w/2,
      self.y2 - self.h/2
    local items, len = collisionWorlds.map:queryRect(
      attackX,
      attackY,
      self.w,
      self.h,
      slimeAttackCollisionFilter
    )

    for i=1, len do
      local it = items[i]
      msgBus.send(msgBus.CHARACTER_HIT, {
        parent = it.parent,
        damage = math.random(self.minDamage, self.maxDamage),
        source = self:getId()
      })
    end

    self:delete(true)
  end
})

local function onDestroyStart()
  local Sound = require 'components.sound'
  love.audio.play(Sound.functions.creatureDestroyed())
end

local DashAbility = {
  range = 6,
  actionSpeed = 0.2,
  cooldown = 2
}

function DashAbility.use(self, state)
  local Dash = require 'components.abilities.dash'
  local projectile = Dash.create({
      fromCaster = self
    , duration = 10/60
    , speed = 200
  })
  state.clock = 0
  return skill
end

function DashAbility.update(_, state, dt)
  if (not state.clock) then
    return false
  end
  state.clock = state.clock + dt
  local isAbilityInFlight = state.clock < DashAbility.actionSpeed
  return isAbilityInFlight
end

local SlimeSlap =  {
  range = 2,
  actionSpeed = 1.2,
  cooldown = 0.4
}

function SlimeSlap.use(self, state, targetX, targetY)
  state.isNewAttack = true
  state.targetX = targetX
  state.targetY = targetY
end

function SlimeSlap.update(self, state, dt)
  local attackAnimation = self.animations.attacking
  if state.isNewAttack then
    state.hasHit = false
    attackAnimation:setFrame(1)
  end
  if (state.isNewAttack or state.isAnimating) then
    state.isNewAttack = false
    self:set(
      'animation',
      attackAnimation
    )
    local isLastFrame = attackAnimation:isLastFrame()
    local isHitFrame = attackAnimation.index == 5
    if isHitFrame and (not state.hasHit) then
      state.hasHit = true
      local Sound = require 'components.sound'
      Sound.playEffect('splat-sound.wav')
      local attack = SlimeAttack.create({
          x = self.x
        , y = self.y
        , x2 = state.targetX
        , y2 = state.targetY
        , w = 32
        , h = 32
        , targetGroup = collisionGroups.player
      })
    end
    state.isAnimating = (not isLastFrame)
    return state.isAnimating
  else
    self:set(
      'animation',
      self.animations.idle
    )
  end
end

local Chance = require 'utils.chance'
local Color = require 'modules.color'
local getRandomProps = Chance({
  {
    chance = 1,
    __call = function()
      local Color = require 'modules.color'
      return {
        name = 'slime'
      }
    end
  }
})

local AiBlueprint = require 'components.ai.create-blueprint'
return AiBlueprint({
  baseProps = {
    type = 'ai-slime',
    moveSpeed = 75,
    maxHealth = 25,
    physicalResist = 1,
    armor = 700,
    experience = 2,
    attackRange = 2,
    onDestroyStart = onDestroyStart
  },
  create = function()
    local animations = {
      attacking = animationFactory:new({
        'slime/slime1',
        'slime/slime2',
        'slime/slime3',
        'slime/slime4',
        'slime/slime5',
        'slime/slime6',
        'slime/slime7',
        'slime/slime8',
        'slime/slime9',
        'slime/slime10',
        'slime/slime11',
      }):setDuration(SlimeSlap.actionSpeed),
      idle = animationFactory:new({
        'slime/slime12',
        'slime/slime13',
        'slime/slime14',
        'slime/slime15',
        'slime/slime16'
      }):setDuration(0.7),
      moving = animationFactory:new({
        'slime/slime12',
        'slime/slime13',
        'slime/slime14',
        'slime/slime15',
        'slime/slime16'
      }):setDuration(0.3)
    }

    local spriteWidth, spriteHeight = animations.idle:getSourceSize()

    local randomProps = getRandomProps()
    local dataSheet = {
      name = randomProps.name,
      properties = {
        'melee',
        'dashes in when near'
      }
    }

    return {
      itemData = {
        level = 2,
        dropRate = 30
      },
      fillColor = randomProps.color,
      dataSheet = dataSheet,
      w = spriteWidth,
      h = spriteHeight,
      animations = animations,
      abilities = {
        DashAbility,
        SlimeSlap,
      },
    }
  end
})