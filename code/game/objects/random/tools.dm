/obj/spawner/tool
	name = "random tool"
	icon_state = "tool-grey"
	spawn_nothing_percentage = 15
	has_postspawn = TRUE
	tags_to_spawn = list(SPAWN_TOOL)
	restristed_tags = list(SPAWN_SURGERY_TOOL, SPAWN_KNIFE)

/obj/random/tool/item_to_spawn()
	return pickweight(list(/obj/spawner/tool = 98.5,
				/obj/item/clothing/gloves/insulated/cheap = 5,
				/obj/item/clothing/gloves/insulated = 2,
				/obj/item/clothing/head/welding = 5,
				/obj/item/device/t_scanner = 2,
				/obj/item/device/scanner/price = 2,
				/obj/item/device/antibody_scanner = 1,
				/obj/item/device/scanner/plant = 1,
				/obj/item/device/scanner/health = 3,
				/obj/item/device/scanner/mass_spectrometer = 1,
				/obj/item/device/scanner/gas = 2,
				/obj/item/weapon/autopsy_scanner = 1,
				/obj/item/device/destTagger = 1,
				/obj/item/device/robotanalyzer = 1,
				/obj/item/device/gps = 3,
				/obj/item/device/makeshift_electrolyser = 1,
				/obj/item/device/makeshift_centrifuge = 1,
				/obj/item/device/lighting/toggleable/flashlight = 10,
				/obj/item/device/flash = 2,
				/obj/item/stack/cable_coil = 5,
				/obj/item/weapon/weldpack/canister = 2,
				/obj/item/weapon/packageWrap = 1,
				/obj/item/weapon/mop = 5,
				/obj/item/weapon/inflatable_dispenser = 3,
				/obj/item/weapon/grenade/chem_grenade/cleaner = 2,
				/obj/item/weapon/tank/jetpack/carbondioxide = 1.5,
				/obj/item/weapon/tank/jetpack/oxygen = 1,
				/obj/item/weapon/storage/belt/utility = 5,
				/obj/item/weapon/storage/belt/utility/full = 1,
				/obj/item/weapon/storage/makeshift_grinder = 2,
				/obj/item/weapon/extinguisher = 5,
				/obj/item/robot_parts/robot_component/jetpack = 0.75,))


//Randomly spawned tools will often be in imperfect condition if they've been left lying out
/obj/random/tool/post_spawn(list/spawns)
	if (isturf(loc))
		for (var/obj/O in spawns)
			if (!istype(O, /obj/random) && prob(20))
				O.make_old()

/obj/spawner/tool/post_spawn(list/spawns)
	if (isturf(loc))
		for (var/obj/O in spawns)
			if (!istype(O, /obj/spawner) && prob(20))
				O.make_old()

/obj/random/tool/low_chance
	name = "low chance random tool"
	icon_state = "tool-grey-low"
	spawn_nothing_percentage = 60


/obj/spawner/tool/advanced
	name = "random advanced tool"
	icon_state = "tool-orange"
	tags_to_spawn = list(SPAWN_ADVANCED_TOOL)

/obj/spawner/tool/advanced/low_chance
	name = "low chance advanced tool"
	icon_state = "tool-orange-low"
	spawn_nothing_percentage = 60

/obj/spawner/toolbox
	name = "random toolbox"
	icon_state = "box-green"
	tags_to_spawn = list(SPAWN_TOOLBOX)

/obj/spawner/toolbox/low_chance
	name = "low chance random toolbox"
	icon_state = "box-green-low"
	spawn_nothing_percentage = 60

/obj/spawner/tool/advanced/onestar
	name = "random onestar tool"
	allow_blacklist = TRUE
	tags_to_spawn = list(SPAWN_OS_TOOL)

/obj/spawner/tool/advanced/onestar/low_chance
	icon_state = "tool-orange-low"
	spawn_nothing_percentage = 60
