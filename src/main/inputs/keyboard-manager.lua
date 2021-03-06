local msgBus = require 'components.msg-bus'
local msgBus = require 'components.msg-bus'
local socket = require 'socket'
local config = require 'config.config'
local userSettings = require 'config.user-settings'

local keysPressed = {}
local L_SUPER = 'lgui'
local R_SUPER = 'rgui'
local L_CTRL = 'lctrl'
local R_CTRL = 'rctrl'

local state = {
  keyboard = {
    keysPressed = keysPressed,
    lastPressed = {
      timeStamp = 0
    },
    isDown = false,
  }
}

local function hasModifier()
  return keysPressed[L_SUPER]
    or keysPressed[R_SUPER]
    or keysPressed[L_CTRL]
    or keysPressed[R_CTRL]
end

local keyboardMessage = require 'utils.pooled-table'(function(t, key, scanCode, isRepeated)
  t.key = key
  t.code = scanCode
  t.isRepeated = isRepeated
  t.hasModifier = hasModifier()
  return t
end)

function love.keypressed(key, scanCode, isRepeated)
  keysPressed[key] = true

  msgBus.send(
    msgBus.KEY_DOWN,
    keyboardMessage(key, scanCode, isRepeated)
  )

  if (not state.keyboard.isDown) then
    local lastPressed = state.keyboard.lastPressed
    lastPressed.timeStamp = socket.gettime()
  end

  if userSettings.keyboard.MAIN_MENU == key then
    local MenuManager = require 'modules.menu-manager'
    if MenuManager.hasItems() then
      MenuManager.clearAll()
      msgBus.send(
        msgBus.TOGGLE_MAIN_MENU,
        false
      )
    else
      msgBus.send(
        msgBus.TOGGLE_MAIN_MENU,
        true
      )
    end

  end
end

function love.keyreleased(key, scanCode)
  keysPressed[key] = false

  local msg = keyboardMessage(key, scanCode, false)
  msgBus.send(
    msgBus.KEY_RELEASED,
    msg
  )

  local timeBetweenRelease = socket.gettime() - state.keyboard.lastPressed.timeStamp
  if timeBetweenRelease >= userSettings.keyPressedDelay then
    msgBus.send(msgBus.KEY_PRESSED, msg)
  end
end

return {
  state = state
}