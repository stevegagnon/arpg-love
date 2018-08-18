local Component = require 'modules.component'
local Gui = require 'components.gui.gui'
local Color = require 'modules.color'
local groups = require 'components.groups'
local msgBus = require 'components.msg-bus'
local config = require 'config'
local guiTextLayers = require 'components.item-inventory.gui-text-layers'
local setupSlotInteractions = require 'components.item-inventory.slot-interaction'
local itemConfig = require 'components.item-inventory.items.config'
local itemDefs = require("components.item-inventory.items.item-definitions")

local InventoryBlueprint = {
  rootStore = nil, -- game state
  slots = {},
  group = groups.gui,
  onDisableRequest = require'utils.noop'
}

local function calcInventorySize(slots, slotSize, margin)
  local rows, cols = #slots, #slots[1]
  local height = (rows * slotSize) + (rows * margin) + margin
  local width = (cols * slotSize) + (cols * margin) + margin
  return width, height
end

local function setupCloseHotkey(self)
  msgBus.subscribe(function(msgType, msgValue)
    if msgBus.KEY_RELEASED == msgType then
      local key = msgValue.key
      if key == config.keyboard.INVENTORY_TOGGLE then
        self:delete(true)
        return msgBus.CLEANUP
      end
    end
  end)
end

local function InteractArea(self)
  return Gui.create({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
    onPointerMove = function()
			msgBus.send(msgBus.INVENTORY_DROP_MODE_INVENTORY)
		end,
		onPointerLeave = function()
			msgBus.send(msgBus.INVENTORY_DROP_MODE_FLOOR)
		end
	})
end

function InventoryBlueprint.init(self)
  setupCloseHotkey(self)

  msgBus.subscribe(function(msgType, msg)
    local rootStore = self.rootStore

    if self.__deleted then
      return msgBus.CLEANUP
    end

    if msgBus.EQUIPMENT_SWAP == msgType then
      local item = msg
      local category = itemDefs.getDefinition(item).category
      local slotX, slotY = itemConfig.findEquipmentSlotByCategory(category)
      local currentlyEquipped = rootStore:getEquippedItem(slotX, slotY)
      local isAlreadyEquipped = currentlyEquipped == item

      if isAlreadyEquipped then
        return
      end

      local _, x, y = rootStore:findItemById(item)
      local equippedItem = rootStore:unequipItem(slotX, slotY)
      rootStore:removeItem(item)
      rootStore:equipItem(item, slotX, slotY)
      rootStore:addItemToInventory(equippedItem, {x, y})
    end
	end)

  self.slotSize = 30
  self.slotMargin = 2

  local w, h = calcInventorySize(self.slots(), self.slotSize, self.slotMargin)
  self.w = w
  self.h = h

  -- center to screen
  local offsetRight = 20
  self.x = (config.resolution.w - w) - offsetRight
  self.y = (config.resolution.h - h) / 2

  InteractArea(self):setParent(self)

  local function inventoryOnItemPickupFromSlot(x, y)
    return self.rootStore:pickupItem(x, y)
  end

  local function inventoryOnItemDropToSlot(curPickedUpItem, x, y)
    return self.rootStore:dropItem(curPickedUpItem, x, y)
  end

  setupSlotInteractions(
    self,
    self.slots,
    self.slotMargin,
    inventoryOnItemPickupFromSlot,
    inventoryOnItemDropToSlot
  )

  local equipmentW, equipmentH = 100, h
  local EquipmentPanel = require 'components.item-inventory.equipment-panel'
  EquipmentPanel.create({
    rootStore = self.rootStore,
    x = self.x - equipmentW - 5,
    y = self.y,
    w = equipmentW,
    h = h,
    slotSize = self.slotSize
  }):setParent(self)
end

local function drawTitle(self, x, y)
  guiTextLayers.title:add('Inventory', Color.WHITE, x, y)
end

function InventoryBlueprint.draw(self)
  local w, h = self.w, self.h

  drawTitle(self, self.x, 20)

  -- inventory background
  love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
  love.graphics.rectangle('fill', self.x, self.y, w, h)
end

function InventoryBlueprint.final(self)
  self.onDisableRequest()
  msgBus.send(msgBus.INVENTORY_DROP_MODE_FLOOR)
end

return Component.createFactory(InventoryBlueprint)