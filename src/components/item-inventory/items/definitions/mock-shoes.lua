local itemConfig = require("components.item-inventory.items.config")

return {
	type = "mock-shoes",

	blueprint =  {
		baseModifiers = {
			cooldown = {1, 1},
		},

		extraModifiers = {
			require 'components.item-inventory.items.modifiers.stat'({
				armor = {20, 30},
				moveSpeed = {100, 100},
			})
		},

		onActivate = require 'components.item-inventory.items.inventory-actives.equip-on-click'(),
		onActivateWhenEquipped = require(require('alias').path.items..'.equipment-actives.movespeed-boost')({
			speedBoost = 300,
			speedBoostDuration = 1
		})
	},

	properties = {
		sprite = "shoe_5",
		title = 'Mock shoes',
		baseDropChance = 1,
		category = itemConfig.category.SHOES,
	}
}