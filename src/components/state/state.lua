--[[

Main game state

**
NOTE:
Time sensitive game states should not rely on the state in this module.
The updates may occur asynchronously, which could throw off timing. Currently
this is mainly for keeping the gui updated with the state of the game.
**

Everything from game configuration options to game data is stored, saved, and
retrieved in this module.

]]--

local Stateful = require("utils.stateful")
local uid = require 'utils.uid'
local config = require('config.config')
local sc = require("components.state.constants")
local baseStatModifiers = require("components.state.base-stat-modifiers")
local objectUtils = require 'utils.object-utils'

local EMPTY_SLOT = sc.inventory.EMPTY_SLOT

-- NOTE: This state is immutable, so we should keep the structure as flat as possible to avoid deep updates
local function defaultState()
	return {
		__stateId = stateId,
		characterName = characterName,
		createdAt = os.time(),
		playTime = 0,
		isNewGame = true,

		level = 1,
		totalExperience = 0,
		enemyKillCount = 0,

		inventory = require'utils.make-grid'(10, 8, EMPTY_SLOT),

		--[[ equipped items ]]
		equipment = require'utils.make-grid'(2, 5, EMPTY_SLOT),
	}
end

local function createStore(initialState)
	assert((initialState == nil) or type(initialState) == 'table', 'invalid initialState')

	local baseState = defaultState()
	-- set a state id if one doesn't exist
	baseState.__stateId = initialState and initialState.__stateId or 'game-'..uid()
	return Stateful:new(
		objectUtils.assign(baseState, initialState)
	)
end

return createStore