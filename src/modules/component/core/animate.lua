local tween = require 'modules.tween'

return function(Component)
  local tweens = {}

  Component.animate = function (subject, target, duration, easing)
    tweens[subject] = tween.new(duration, subject, target, easing)
  end

  Component.animateUpdate = function(dt)
    for ref,t in pairs(tweens) do
      local complete = t:update(dt)
      if complete then
        tweens[ref] = nil
      end
    end
  end
end