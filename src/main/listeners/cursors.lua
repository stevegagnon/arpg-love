return function(msgBus)
  -- custom cursor
  local cursorBaseSize = 22
  local cursorImages = {
    target = 'cursor-target',
    move = 'cursor-move',
    speech = 'cursor-speech',
    pointer = 'cursor-pointer'
  }
  local cursorsCache = {
    cursors = {},
    get = function(self, _type)
      if _type == 'default' then
        return self:get('pointer')
      end

      local config = require 'config.config'
      local size = config.scale
      _type = _type or 'pointer'
      local cursorTypes = self.cursors[_type]
      if (not cursorTypes) then
        cursorTypes = {}
        self.cursors[_type] = cursorTypes
      end
      local cursor = cursorTypes[size]
      if (not cursor) then
        local fileName = cursorImages[_type]
        local sizeSuffix = size > 1 and ('-'..size..'x') or ''
        local cursorSize = cursorBaseSize * size
        cursor = love.mouse.newCursor('built/images/cursors/'..fileName..sizeSuffix..'.png', cursorSize/2, cursorSize/2)
        cursorTypes[size] = cursor
      end
      return cursor
    end
  }
  msgBus.on(msgBus.CURSOR_SET, function(msg)
    love.mouse.setCursor(cursorsCache:get(msg.type))
  end)
end