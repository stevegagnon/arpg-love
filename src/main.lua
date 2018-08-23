-- can't use lua strict right now because 'jumper' library uses globals which throws errors
-- require 'lua_modules.strict'

require 'components.run'

-- NOTE: this is necessary for crisp pixel rendering
love.graphics.setDefaultFilter('nearest', 'nearest')

local Console = require 'modules.console.console'
local groups = require 'components.groups'
local msgBus = require 'components.msg-bus'
local groups = require 'components.groups'
local config = require 'config'
local camera = require 'components.camera'
local SceneMain = require 'scene.scene-main'
local tick = require 'utils.tick'

local scale = config.scaleFactor

local scenes = {
  main = SceneMain,
  -- When in production, this module will not get loaded since it will not exist
  sandbox = (function()
    local scene = love.filesystem.load('scene/sandbox/main.lua')
    if scene then
      return scene()
    end
  end)()
}

local globalState = {
  activeScene = scenes.sandbox,
}

function love.load()
  love.keyboard.setKeyRepeat(true)
  local resolution = config.resolution
  local vw, vh = resolution.w * scale, resolution.h * scale
  love.window.setMode(vw, vh)
  camera
    :setSize(vw, vh)
    :setScale(scale)
  msgBus.send(msgBus.GAME_LOADED)

  globalState.activeScene.create()

  -- console debugging
  local console = Console.create()
  require 'components.profiler.component-groups'(console)
end

function love.update(dt)
  tick.update(dt)

  groups.all.updateAll(dt)
  groups.overlay.updateAll(dt)
  groups.debug.updateAll(dt)
  groups.hud.updateAll(dt)
  groups.gui.updateAll(dt)
  groups.system.updateAll(dt)
end

local inputMsg = require 'utils.pooled-table'(function(t, key, scanCode, isRepeated)
  t.key = key
  t.code = scanCode
  t.isRepeated = isRepeated
  return t
end)

function love.keypressed(key, scanCode, isRepeated)
  msgBus.send(
    msgBus.KEY_PRESSED,
    inputMsg(key, scanCode, isRepeated)
  )

  if config.keyboard.EXIT_GAME == key then
    love.event.quit()
  end
end

function love.keyreleased(key, scanCode)
  msgBus.send(
    msgBus.KEY_RELEASED,
    inputMsg(key, scanCode, false)
  )
end

function love.mousepressed( x, y, button, istouch, presses )
  msgBus.send(
    msgBus.MOUSE_PRESSED,
    { x, y, button, isTouch, presses }
  )
end

function love.mousereleased( x, y, button, istouch, presses )
  msgBus.send(
    msgBus.MOUSE_RELEASED,
    { x, y, button, isTouch, presses }
  )
end

function love.wheelmoved(x, y)
  msgBus.send(msgBus.MOUSE_WHEEL_MOVED, {x, y})
end

function love.textinput(t)
  msgBus.send(
    msgBus.GUI_TEXT_INPUT,
    t
  )
end

function love.draw()
  camera:attach()
  -- background
  love.graphics.clear(0.2,0.2,0.2)
  groups.all.drawAll()
  groups.overlay.drawAll()
  groups.debug.drawAll()
  camera:detach()

  love.graphics.push()
  love.graphics.scale(config.scaleFactor)
  groups.hud.drawAll()
  groups.gui.drawAll()
  love.graphics.pop()

  groups.system.drawAll()
end

--[[
  run tests after everything is loaded since some tests
  since some of the tests rely on the game loop
]]
if config.isDebug then
  require 'modules.test.index'
  require 'utils.test.index'
end