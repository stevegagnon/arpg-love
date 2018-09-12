local Component = require 'modules.component'
local groups = require 'components.groups'
local collisionWorlds = require 'components.collision-worlds'
local msgBus = require 'components.msg-bus'
local animationFactory = require 'components.animation-factory'

local function slimeAttackCollisionFilter(item)
  return item.group == 'player'
end

local SlimeAttack = Component.createFactory({
  group = groups.all,
  minDamage = 5,
  maxDamage = 10,
  init = function(self)
    local items, len = collisionWorlds.map:queryRect(
      self.x2 - self.w/2,
      self.y2,
      self.w,
      self.h,
      slimeAttackCollisionFilter
    )

    for i=1, len do
      local it = items[i]
      msgBus.send(msgBus.CHARACTER_HIT, {
        parent = it.parent,
        damage = math.random(self.minDamage, self.maxDamage)
      })
    end

    self:delete(true)
  end
})

return function()
  local animations = {
    attacking = animationFactory:new({
      'slime1',
      'slime2',
      'slime3',
      'slime4',
      'slime5',
      'slime6',
      'slime7',
      'slime8',
      'slime9',
      'slime10',
      'slime11',
    }),
    idle = animationFactory:new({
      'slime12',
      'slime13',
      'slime14',
      'slime15',
      'slime16'
    }),
    moving = animationFactory:new({
      'slime12',
      'slime13',
      'slime14',
      'slime15',
      'slime16'
    })
  }

  local abilityDash = (function()
    local curCooldown = 0
    local skill = {
      range = 6
    }

    function skill.use(self)
      if curCooldown > 0 then
        return skill
      else
        local Dash = require 'components.abilities.dash'
        local projectile = Dash.create({
            fromCaster = self
          , cooldown = 1
          , duration = 7/60
          , range = skill.range
        })
        curCooldown = projectile.cooldown
        return skill
      end
    end

    function skill.updateCooldown(self, dt)
      curCooldown = curCooldown - dt
      return skill
    end

    return skill
  end)()

  local ability1 = (function()
    local curCooldown = 0
    local initialCooldown = 0
    local skill = {
      range = 3
    }
    local isAnimationComplete = false

    function skill.use(self, targetX, targetY)
      if curCooldown > 0 then
        return skill
      else
        local attack = SlimeAttack.create({
            x = self.x
          , y = self.y
          , x2 = targetX
          , y2 = targetY
          , w = 64
          , h = 36
          , cooldown = 0.5
          , targetGroup = 'player'
        })

        local Sound = require 'components.sound'
        love.audio.stop(Sound.SLIME_SPLAT)
        love.audio.play(Sound.SLIME_SPLAT)

        curCooldown = attack.cooldown
        initialCooldown = attack.cooldown
        return skill
      end
    end

    function skill.updateCooldown(self, dt)
      local isNewAttack = curCooldown == initialCooldown
      local attackAnimation = animations.attacking
      if isNewAttack then
        isAnimationComplete = false
      end
      self:set(
        'animation',
        attackAnimation
      )
      if not isAnimationComplete then
        local animation, isLastFrame = attackAnimation:update(dt/2)
        isAnimationComplete = isLastFrame
      end

      curCooldown = curCooldown - dt
      return skill
    end

    return skill
  end)()

  local attackRange = 3
  local fillColor = {0,1,0.2,1}
  local spriteWidth, spriteHeight = animations.idle:getSourceSize()

  local dataSheet = {
    name = 'slime',
    properties = {
      'melee',
      'dashes in when near'
    }
  }

  return {
    modifierNames = {},
    dataSheet = dataSheet,
    moveSpeed = 110,
    maxHealth = 30,
    w = spriteWidth,
    h = spriteHeight,
    flatPhysicalDamageReduction = 1,
    animations = animations,
    abilities = {
      ability1,
      abilityDash
    },
    armor = 900,
    experience = 2,
    attackRange = attackRange,
    fillColor = fillColor
  }
end