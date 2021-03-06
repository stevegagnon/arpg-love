local GuiText = require 'components.gui.gui-text'
local Component = require 'modules.component'
local groups = require 'components.groups'
local msgBus = require 'components.msg-bus'
local Color = require 'modules.color'
local CollisionObject = require 'modules.collision'
local config = require 'config.config'
local InputContext = require 'modules.input-context'

local state = {
  showConsole = true
}

local function toggleCollisionDebug()
  msgBus.send(msgBus.SET_CONFIG, {
    collisionDebug = (not config.collisionDebug)
  })
end

local function toggleConsole()
  msgBus.send(msgBus.SET_CONFIG, {
    enableConsole = (not config.enableConsole)
  })
end

local keyActions = setmetatable({
  o = toggleCollisionDebug,
  c = toggleConsole
}, {
  __index = function()
    local noop = require 'utils.noop'
    return noop
  end
})

msgBus.on(msgBus.KEY_DOWN, function(v)
  local inputState = require 'main.inputs.keyboard-manager'.state
  local keysPressed = inputState.keyboard.keysPressed
  if (not v.isRepeated) and keysPressed.lctrl and keysPressed.lshift then
    keyActions[v.key]()
  end
  return v
end)

local Console = {
  name = 'Console',
  resetMaxEveryNumFrames = 60,
  stats = {
    accumulatedMemoryUsed = 0,
    currentMemoryUsed = 0,
    frameCount = 0,
  }
}

local edgeOffset = 10

local function printTable(t, lineHeight, x, y)
  local i = 0
  for k,v in pairs(t) do
    love.graphics.print(
      k..': '..v,
      x,
      y + (i * lineHeight)
    )
    i = i + 1
  end
end

local function getAllGameObjectStats()
  local stats = {
    count = 0
  }
  for _,group in pairs(groups) do
    stats.count = stats.count + group.getStats()
  end
  return stats
end

local canvas = love.graphics.newCanvas(1000, 1000)

local Logger = require'utils.logger'
local logger = Logger:new(10)

function Console.debug(...)
  local args = {...}
  local output = ''
  for i=1, #args do
    output = output..' '..tostring(args[i])
  end
  logger:add(output)
end

-- GLOBAL console logger
consoleLog = Console.debug

function Console.init(self)
  Component.addToGroup(self, groups.system)
  local perf = require 'utils.perf'
  self.msgCountPerFrame = 0
  msgBus.send = perf({
    done = function(_, totalTime, callCount)
      self.msgBusAverageTime = totalTime/callCount
      self.msgCountPerFrame = self.msgCountPerFrame + 1
    end
  })(msgBus.send)
end

function Console.update(self)
  local noop = require 'utils.noop'
  -- set logger function to noop if console is disabled
  consoleLog = config.enableConsole and Console.debug or noop
  self:setDrawDisabled(not config.enableConsole)
  if (not config.enableConsole) then
    return
  end

  local s = self.stats
  s.currentMemoryUsed = collectgarbage('count')
  s.frameCount = s.frameCount + 1
  s.accumulatedMemoryUsed = s.accumulatedMemoryUsed + s.currentMemoryUsed

  self.previousInputContext = InputContext.get()
end

local function calcMessageBusHandlers()
  local handlersByType = msgBus.getStats()
  local handlersByTypeCount = 0
  for _,handlers in pairs(handlersByType) do
    handlersByTypeCount = handlersByTypeCount + #handlers
  end
  return handlersByTypeCount
end

local maxGraphicStats = {}

function Console.draw(self)
  local Font = require 'components.font'
  local font = Font.debug.font
  love.graphics.setFont(font)
  local charHeight = font:getLineHeight() * font:getHeight()
  local gfx = love.graphics
  local s = self.stats

  gfx.setColor(Color.MED_GRAY)
  gfx.print('COMPONENTS', edgeOffset, edgeOffset)
  gfx.setColor(Color.WHITE)
  printTable({
    objects = getAllGameObjectStats().count,
    collisionObjects = CollisionObject.getStats()
  },
    charHeight,
    edgeOffset,
    edgeOffset + charHeight
  )

  local startY = edgeOffset + (charHeight * 4)
  gfx.setColor(Color.MED_GRAY)
  gfx.print('GRAPHICS', edgeOffset, startY)
  gfx.setColor(Color.WHITE)

  -- print out each stat on its own line
  local shouldResetMaxStats = (self.stats.frameCount % self.resetMaxEveryNumFrames) == 0
  if shouldResetMaxStats then
    maxGraphicStats = {}
  end

  local nextStats = {}
  local gfxStats = gfx.getStats()
  for k,v in pairs(gfxStats) do
    local units = ''
    if k == 'texturememory' then
      units = 'M'
      v = tonumber(string.format('%0.1f', v/1024/1024))
    end
    nextStats[k] = v .. units..' '.. (maxGraphicStats[k] or 0)..units
    maxGraphicStats[k] = math.max(maxGraphicStats[k] or 0, v)
  end
  printTable(
    nextStats,
    charHeight,
    edgeOffset,
    startY + charHeight
  )

  gfx.setColor(Color.MED_GRAY)
  gfx.print('SYSTEM', edgeOffset, startY + 10 * charHeight)
  gfx.setColor(Color.WHITE)
  printTable({
      memory = string.format('%0.2fM', s.currentMemoryUsed / 1024),
      memoryAvg = string.format('%0.2fM', s.accumulatedMemoryUsed / s.frameCount / 1024),
      delta = string.format('%0.4f', love.timer.getAverageDelta()),
      fps = love.timer.getFPS(),
      eventHandlers = calcMessageBusHandlers()
    },
    charHeight,
    edgeOffset,
    startY + 11 * charHeight
  )

  gfx.printf(
    {
      Color.WHITE,
      'msgBus avgTime: '..string.format('%0.3f', self.msgBusAverageTime),
      Color.WHITE,
      '\nmsgBus send count: '..self.msgCountPerFrame,
      Color.WHITE,
      '\ninput context: ',
      Color.YELLOW,
      self.previousInputContext
    },
    edgeOffset,
    355,
    400,
    'left'
  )
  self.msgCountPerFrame = 0

  local logEntries = logger:get()
  gfx.setColor(Color.MED_GRAY)
  local loggerYPosition = 420
  local logSectionTitle = 'LOG'
  gfx.print(logSectionTitle, edgeOffset, loggerYPosition)
  gfx.setColor(Color.WHITE)
  local output = {}
  for i=1, #logEntries do
    local entry = logEntries[i]
    table.insert(output, Color.WHITE)
    table.insert(output, entry..'\n')
  end
  gfx.printf(output, 0, loggerYPosition + GuiText.getTextSize(logSectionTitle, font), 400, 'left')
end

function Console.drawOrder(self)
  return 10
end

return Component.createFactory(Console)
