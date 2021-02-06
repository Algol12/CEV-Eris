// Station voidsuits

//Engineering rig
/obj/item/clothing/head/space/void/engineering
	name = "Technomancer voidsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "technohelmet_void_old"
	item_state = "technohelmet_void_old"
	light_overlay = "technohelmet_light"
	item_state_slots = list(
		slot_l_hand_str = "eng_helm",
		slot_r_hand_str = "eng_helm",
		)
	armor = list(
		melee = 35,
		bullet = 30,
		energy = 30,
		bomb = 40,
		bio = 100,
		rad = 100
	)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/void/engineering
	name = "Technomancer voidsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding and extra plating."
	icon_state = "technosuit_old"
	item_state = "technosuit_old"
	armor = list(
		melee = 35,
		bullet = 30,
		energy = 30,
		bomb = 40,
		bio = 100,
		rad = 100
	)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	extra_allowed = list(
		/obj/item/weapon/storage/toolbox,
		/obj/item/weapon/storage/briefcase/inflatable,
		/obj/item/device/t_scanner,
		/obj/item/weapon/rcd
	)
	helmet = /obj/item/clothing/head/space/void/engineering
	spawn_blacklisted = TRUE

/obj/item/clothing/suit/space/void/engineering/equipped
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/weapon/tank/jetpack/oxygen
	accompanying_object = null
	spawn_blacklisted = TRUE

//Femboy engineering rig
/obj/item/clothing/head/space/void/engineeringcursed
	name = "Cursed Technomancer voidsuit helmet"
	desc = "This visor has a few more options in it's shape than its classic counter part."
	icon_state = "technohelmet_void"
	item_state = "technohelmet_void"
	light_overlay = "technohelmet_light"
	item_state_slots = list(
		slot_l_hand_str = "eng_helm",
		slot_r_hand_str = "eng_helm",
		)
	armor = list(
		melee = 35,
		bullet = 30,
		energy = 30,
		bomb = 40,
		bio = 100,
		rad = 100
	)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/space/void/engineering/verb/toggle_eyeglass()
	set name = "Adjust Eyeglass node"
	set category = "Object"
	set src in usr

	if(!isliving(loc))
		return

	var/mob/M = usr
	var/list/options = list()
	options["generic"] = "technohelmet_void"
	options["visor"] = "technohelmet_void_visor"
	options["goggles"] = "technohelmet_void_goggles"

	var/choice = input(M,"What kind of eyeglass do you want to look through?","Adjust visor") as null|anything in options

	if(src && choice && !M.incapacitated() && Adjacent(M))
		icon_state = options[choice]
		to_chat(M, "You change your helmet's eyeglass mode to [choice].")
		update_icon()
		update_wear_icon()
		usr.update_action_buttons()
		return 1

/obj/item/clothing/suit/space/void/engineeringcursed
	name = "outdated Technomancer voidsuit"
	desc = "Same purpose as the standard technomancer voidsuit but was rejected by the empress for being unsightly and making the wearer look like a femboy."
	icon_state = "technosuit"
	item_state = "technosuit"
	armor = list(
		melee = 35,
		bullet = 30,
		energy = 30,
		bomb = 40,
		bio = 100,
		rad = 100
	)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	extra_allowed = list(
		/obj/item/weapon/storage/toolbox,
		/obj/item/weapon/storage/briefcase/inflatable,
		/obj/item/device/t_scanner,
		/obj/item/weapon/rcd
	)
	helmet = /obj/item/clothing/head/space/void/engineeringcursed
	spawn_blacklisted = FALSE

/obj/item/clothing/suit/space/void/engineeringcursed/equipped
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/weapon/tank/jetpack/oxygen
	accompanying_object = null
	spawn_blacklisted = TRUE

//Mining rig
/obj/item/clothing/head/space/void/mining
	name = "mining voidsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "mining_helmet"
	item_state = "mining_helmet"
	item_state_slots = list(
		slot_l_hand_str = "mining_helm",
		slot_r_hand_str = "mining_helm",
		)
	armor = list(
		melee = 50,
		bullet = 35,
		energy = 30,
		bomb = 25,
		bio = 100,
		rad = 75
	)
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/mining
	name = "mining voidsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	item_state = "miner_suit"
	icon_state = "miner_suit"
	slowdown = 0.35
	armor = list(
		melee = 50,
		bullet = 35,
		energy = 30,
		bomb = 25,
		bio = 100,
		rad = 75
	)
	helmet = /obj/item/clothing/head/space/void/mining
	spawn_blacklisted = TRUE

//Medical
/obj/item/clothing/head/space/void/medical
	name = "medical voidsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has minor radiation shielding."
	icon_state = "rig-medical"
	item_state = "rig-medical"
	item_state_slots = list(
		slot_l_hand_str = "medical_helm",
		slot_r_hand_str = "medical_helm",
		)
	armor = list(
		melee = 30,
		bullet = 10,
		energy = 35,
		bomb = 25,
		bio = 100,
		rad = 75
	)

/obj/item/clothing/suit/space/void/medical
	name = "medical voidsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has minor radiation shielding."
	icon_state = "rig-medical"
	item_state = "rig-medical"
	slowdown = 0.15
	extra_allowed = list(
		/obj/item/weapon/storage/firstaid,
		/obj/item/device/scanner/health,
		/obj/item/stack/medical,
		/obj/item/roller
	)
	armor = list(
		melee = 20,
		bullet = 10,
		energy = 35,
		bomb = 25,
		bio = 100,
		rad = 75
	)
	helmet = /obj/item/clothing/head/space/void/medical
	rarity_value = 8.7

/obj/item/clothing/suit/space/void/medical/equipped
	boots = /obj/item/clothing/shoes/magboots
	accompanying_object = null
	spawn_blacklisted = TRUE

	//Security
/obj/item/clothing/head/space/void/security
	name = "ironhammer voidsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "ihsvoidhelm"
	item_state = "ihsvoidhelm"
	item_state_slots = list(
		slot_l_hand_str = "sec_helm",
		slot_r_hand_str = "sec_helm",
		)

	armor = list(
		melee = 35,
		bullet = 40,
		energy = 30,
		bomb = 25,
		bio = 100,
		rad = 75
	)
	siemens_coefficient = 0.7
	light_overlay = "helmet_light_ihs"

/obj/item/clothing/suit/space/void/security
	name = "ironhammer voidsuit"
	icon_state = "ihvoidsuit"
	desc = "A bulky suit that protects against hazardous, low pressure environments. Sacrifices mobility for protection."
	item_state = "ihvoidsuit"
	armor = list(
		melee = 35,
		bullet = 40,
		energy = 30,
		bomb = 25,
		bio = 100,
		rad = 75
	)
	siemens_coefficient = 0.7
	helmet = /obj/item/clothing/head/space/void/security
	spawn_blacklisted = TRUE

/obj/item/clothing/suit/space/void/security/equipped
	boots = /obj/item/clothing/shoes/magboots
	tank = /obj/item/weapon/tank/jetpack/oxygen
	accompanying_object = null
	spawn_blacklisted = TRUE

//Atmospherics Rig (BS12)
/obj/item/clothing/head/space/void/atmos
	desc = "A special helmet designed for work in a hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	name = "atmospherics voidsuit helmet"
	icon_state = "rig0-atmos"
	item_state = "atmos_helm"
	item_state_slots = list(
		slot_l_hand_str = "atmos_helm",
		slot_r_hand_str = "atmos_helm",
		)
	armor = list(
		melee = 30,
		bullet = 10,
		energy = 10,
		bomb = 25,
		bio = 100,
		rad = 75
	)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/atmos
	desc = "A special suit that protects against hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	icon_state = "rig-atmos"
	name = "atmos voidsuit"
	item_state = "atmos_voidsuit"
	armor = list(
		melee = 30,
		bullet = 10,
		energy = 10,
		bomb = 25,
		bio = 100,
		rad = 75
	)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	helmet = /obj/item/clothing/head/space/void/atmos
	rarity_value = 16

//Science
/obj/item/clothing/head/space/void/science
	name = "Moebius combat Helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "moebiushelmb"
	item_state = "moebiushelmb"
	item_state_slots = list(
		slot_l_hand_str = "assaulthelm",
		slot_r_hand_str = "assaulthelm",
		)
	matter = list(
	MATERIAL_PLASTEEL = 5,
	MATERIAL_STEEL = 5,
	MATERIAL_GLASS = 5
	)
	price_tag = 200
	armor = list(
		melee = 40,
		bullet = 35,
		energy = 45,
		bomb = 30,
		bio = 100,
		rad = 75
	)
	siemens_coefficient = 0.4
	light_overlay = "helmet_light_dual"

/obj/item/clothing/head/space/void/science
    var/list/icon_states = list("moebiushelmb","moebiushelmr", "moebiushelmp","moebiushelmg", "moebiushelmy", "moebiushelmw") //TODO: a manual selection anytime.

/obj/item/clothing/head/space/void/science/New()
    ..()
    icon_state = pick(icon_states)

/obj/item/clothing/suit/space/void/science
	name = "Moebius combat voidsuit"
	icon_state = "moebiussuit"
	desc = "A heavy space suit designed by Moebius personnel for work in hazardous environment. Features several advanced layers of armor."
	item_state = "moebiussuit"
	matter = list(
	MATERIAL_PLASTEEL = 15,
	MATERIAL_STEEL = 10,
	MATERIAL_PLASTIC = 10,
	MATERIAL_PLATINUM = 5
	)
	armor = list(
		melee = 40,
		bullet = 35,
		energy = 45,
		bomb = 30,
		bio = 100,
		rad = 75
	)
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 4)
	price_tag = 1200
	siemens_coefficient = 0.4
	helmet = /obj/item/clothing/head/space/void/science
	rarity_value = 50
	spawn_blacklisted = TRUE
