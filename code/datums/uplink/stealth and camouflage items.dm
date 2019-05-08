/*******************************
* Stealth and Camouflage Items *
*******************************/
/datum/uplink_item/item/stealth_items
	category = /datum/uplink_category/stealth_items

/datum/uplink_item/item/stealth_items/spy
	name = "Bug Kit"
	item_cost = 20
	path = /obj/item/weapon/storage/box/syndie_kit/spy

/datum/uplink_item/item/stealth_items/id
	name = "Agent ID card"
	item_cost = 30
	path = /obj/item/weapon/card/id/syndicate

/datum/uplink_item/item/stealth_items/chameleon_kit
	name = "Chameleon Kit"
	item_cost = 50
	path = /obj/item/weapon/storage/box/syndie_kit/chameleon

/datum/uplink_item/item/stealth_items/voice
	name = "Chameleon Voice Changer"
	item_cost = 50
	path = /obj/item/clothing/mask/chameleon/voice
	desc = "Mask with voice changer which also doubles as chameleon mask to keep suspicions at bay."

/datum/uplink_item/item/stealth_items/chameleon_projector
	name = "Chameleon-Projector"
	item_cost = 80
	path = /obj/item/device/chameleon

/datum/uplink_item/item/stealth_items/tool_dampener
	name = "Tool Upgrade: Aural Dampener"
	item_cost = 10
	path = /obj/item/weapon/tool_upgrade/augment/dampener