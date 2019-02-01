local Vec2 = require 'modules.brinevector'
local Component = require 'modules.component'

return function(state)
  return {
    pan = function(dx, dy)
      state.initialTranslate = state.initialTranslate or state.translate
      state.translate = state.initialTranslate + Vec2(dx, dy)
    end,
    panEnd = function()
      state.initialTranslate = nil
    end,
    zoom = function(dz)
      local clamp = require 'utils.math'.clamp
      local round = require 'utils.math'.round
      Component.animate(state, {
        distScale = clamp(round(state.distScale + dz), 1, 2)
      }, 0.25, 'outCubic')
    end,
    nodeHoverIn = function(node)
      Component.animate(state.nodeStyles[node], {
        scale = 1.3
      }, 0.15, 'outQuint')
    end,
    nodeHoverOut = function(node)
      Component.animate(state.nodeStyles[node], {
        scale = 1
      }, 0.15, 'outQuint')
    end,
    nodeSelect = function(node)
      print('select', node)
    end,
    newGraph = function(model)
      state.nodeStyles = {}
      model:forEach(function(link)
        local node1, node2 = unpack(link)
        state.nodeStyles[node1] = {
          scale = 1
        }
        state.nodeStyles[node2] = {
          scale = 1
        }
      end)
    end
  }
end