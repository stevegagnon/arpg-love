--[[
TODO: Load items asynchronously as needed.
As an item gets discovered, drops from an enemy, or shows up in the npc shop, we'll
load the item definition from disk.
]]

--[[
Item factories

First function returns a table of the item data
]]--

local tableUtils = require("utils.object-utils")

local uid = require("utils.uid")
local itemConfig = require("components.item-inventory.items.config")
local msgBus = require("components.msg-bus")
local Enum = require 'utils.enum'

local types = {}
local items = {
	types = types,
	moduleTypes = Enum({
		'EQUIPMENT_ACTIVE',
		'INVENTORY_ACTIVE',
		'MODIFIERS'
	})
}

local loadedTypes = {}
local function requireIfNecessary(item)
	local iType = item.__type
	if (not loadedTypes[iType]) then
		local loadedItem = require(require('alias').path.itemDefs..'.'..iType)
		return items.registerType(loadedItem)
	end
	return nil
end

function items.getDefinition(item)
	if not item then
		return nil
	end
	return items.types[item.__type] or requireIfNecessary(item)
end

local noop = function() end

-- registers an item type
function items.registerType(itemDefinition)
	local def = itemDefinition

	local registered = types[def.type] ~= nil
	if registered then
		return itemDefinition
	end

	local isDuplicateType = types[def.type] ~= nil
	assert(not isDuplicateType, "duplicate item type ".."\""..def.type.."\"")

	local mt = {
		info = {},
		baseModifiers = {}
	}
	mt.__index = mt
	types[def.type] = setmetatable(def.properties, mt)

	assert(itemDefinition ~= nil, "item type missing")
	local file = 'components/item-inventory/items/definitions/'..def.type
	assert(
		require(file) ~= nil,
		'Invalid type `'..tostring(def.type)..'`. Type should match the name of the file since its needed for dynamic requires'
	)

	return types[def.type]
end

local factoriesByType = {}
local itemDefaults = {
	rarity = itemConfig.rarity.NORMAL,
	experience = 0,
	stackSize = 1,
	maxStackSize = 1,
	extraModifiers = {}
}
-- Factory function that creates a new instance based on the module's instance props.
function items.create(module)
	if (type(module) == 'string') then
		return items.create(
			require('components.item-inventory.items.definitions.'..module)
		)
	end
	local createFn = factoriesByType[module.type]
	if not createFn then
		local ser = require 'utils.ser'
		createFn = loadstring(ser(module.blueprint))
		factoriesByType[module.type] = createFn
	end

	local newItem = createFn()

	newItem.__type = module.type
	newItem.__id = uid()

	local propTypes = require 'utils.prop-types'
	propTypes(newItem, itemDefaults)
	return newItem
end

items.item = {}
function items.item.addModifier(item, modifier)
	table.insert(item.extraModifiers, modifier)
	return items
end

function items.item.setRarity(item, rarity)
	item.rarity = rarity
	return items
end

function items.item.setCustomTitle(item, title)
	item.customTitle = title
	return items
end

local modulesById = {}

local modulePropValidators = {
	experienceRequired = {
		type = 'number',
		required = false
	}
}

-- registers an item module
function items.registerModule(module)
	local id = module.type .. '_' .. module.name
	assert(type(module.name) == 'string', 'modules must have a unique name')
	assert(items.moduleTypes[module.type], 'invalid module type '..module.type)
	assert(not modulesById[id], 'duplicate module with id '..id)
	modulesById[id] = module
	return function(props)
		local actualProps = (type(props) == 'function') and props() or (props or {})

		-- validate props
		for k,validator in pairs(modulePropValidators) do
			local hasValue = actualProps[k] ~= nil
			if validator.required and (not hasValue) then
				error('item property '..k..' is required')
			end
			if hasValue then
				local value = actualProps[k]
				local valueType = type(value)
				assert(valueType == validator.type, 'invalid item property '..k..'. Expected type `'..validator.type..'` received type `'..valueType..'`')
			end
		end

		return {
			id = id,
			props = actualProps
		}
	end
end

local directoriesByModuleType = {
	[items.moduleTypes.EQUIPMENT_ACTIVE] = 'equipment-actives',
	[items.moduleTypes.INVENTORY_ACTIVE] = 'inventory-actives',
	[items.moduleTypes.MODIFIERS] = 'modifiers',
}

local function loadModuleById(id)
	local loadedModule = modulesById[id]
	if loadedModule then
		return loadedModule
	end

	local start, _end = string.find(id, '[^_]*')
	local type = string.sub(id, start, _end)
	local fileName = string.sub(id, _end + 2)
	local directory = 'components.item-inventory.items.' .. directoriesByModuleType[type]
	local fullPath = directory.. '.' ..fileName

	require(fullPath)
	-- modules register themselves via `registerModule` which adds the reference to `modulesById`
	return modulesById[id]
end

function items.loadModule(moduleDefinition)
	local loadedModule = loadModuleById(moduleDefinition.id)
	local copy = {}
	for k,v in pairs(loadedModule) do
		copy[k] = v
		-- wrap method so that props are automatically passed in as second argument
		if (type(v) == 'function') then
			copy[k] = function(item)
				assert(item ~= nil, 'item missing for method '..k)
				return v(item, moduleDefinition.props, items.getState(item))
			end
		end
	end
	return copy
end

function items:loadModules(item)
	local f = require 'utils.functional'
	local function loadModule(modifier)
		local module = items.loadModule(modifier)
		module.active(item)
	end
	f.forEach(item.extraModifiers, loadModule)
	f.forEach(self.getDefinition(item).extraModifiers or {}, loadModule)
end

local Lru = require 'utils.lru'
local setProp = require 'utils.set-prop'
local statesById = Lru.new(100)

function items.getState(item)
	local id = item.__id
	local state = statesById:get(id)
	if (not state) then
		state = setProp({})
		statesById:set(id, state)
	end
	return state
end

function items.resetState(item)
	statesById:delete(item.__id)
end

return items