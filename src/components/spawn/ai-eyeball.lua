local animationFactory = require 'components.animation-factory'
local tick = require 'utils.tick'

local function eyeballAttackCollisionFilter(item)
  return item.group == 'player'
end

return function()
  local animations = {
    idle = animationFactory:new({
      'eyeball'
    }),
    moving = animationFactory:new({
      'eyeball'
    })
  }

  -- deals damage with a chance to slow
  local ability1 = (function()
    local curCooldown = 0
    local skill = {}

    function skill.use(self, targetX, targetY)
      if curCooldown > 0 then
        return skill
      else
        local Attack = require 'components.abilities.frost-spark'
        local projectile = Attack.create({
            debug = false
          , x = self.x
          , y = self.y - self.z
          , x2 = targetX
          , y2 = targetY
          , speed = 115
          , cooldown = 0.6
          , lifeTime = 2.5
          , targetGroup = 'player'
          , drawOrder = function()
            return self.drawOrder(self) + 1
          end
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

  local spriteWidth, spriteHeight = animations.idle:getSourceSize()

  local heightChange = 4
  return {
    z = 10,
    heightOffset = math.random(0, heightChange),
    heightChange = heightChange,
    moveSpeed = 100,
    maxHealth = 17,
    w = spriteWidth,
    h = spriteHeight,
    animations = animations,
    ability1 = ability1,
    attackRange = 10,
    onUpdateStart = function(self, dt)
      self.heightOffset = self.heightOffset + (dt * self.heightChange)
      if self.heightOffset >= 4 then
        self.heightChange = math.abs(self.heightChange) * -1
      end
      if self.heightOffset <= 0 then
        self.heightChange = math.abs(self.heightChange)
      end
      -- update z position for levitation effect
      self:setPosition(
        self.x,
        self.y,
        self.z + (dt * self.heightChange)
      )
    end
  }
end