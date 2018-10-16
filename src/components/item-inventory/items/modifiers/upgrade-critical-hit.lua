local itemSystem = require(require('alias').path.itemSystem)
local msgBus = require 'components.msg-bus'

return itemSystem.registerModule({
  name = 'upgrade-critical-hit',
  type = itemSystem.moduleTypes.MODIFIERS,
  active = function(item, props)
    local id = item.__id
    local itemState = itemSystem.getState(item)
    msgBus.on(msgBus.CHARACTER_HIT, function(hitMessage)
      if (not itemState.equipped) then
        return msgBus.CLEANUP
      end
      local isEnoughExperience = props.experienceRequired <= item.experience
      if isEnoughExperience then
        hitMessage.criticalChance = props.chance
        hitMessage.criticalMultiplier = math.random(
          props.minMultiplier * 100,
          props.maxMultiplier * 100
        ) / 100
        return hitMessage
      end
    end, 1, function(msg)
      return msg.source == id and
        props.experienceRequired <= item.experience
    end)
  end,
  tooltip = function()
    return {
      type = 'upgrade',
      data = {
        description = {
          template = 'Attacks have a {chance}% chance to deal {minMultiplier}x - {maxMultiplier}x damage',
          data = {
            minMultiplier = 0.2,
            maxMultiplier = 0.4,
            chance = 0.25
          }
        }
      }
    }
  end
})