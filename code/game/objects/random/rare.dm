//Rare loot. The rare spawner appears as a subset in other lists
//Mostly it includes the cream of the crop from other lists, and some unique things
/obj/random/rare
	name = "rare spawn"
	icon_state = "ai-blue"

/obj/random/rare/item_to_spawn()
	return pickweight(list(
	/obj/random/material_rare = 3,
	/obj/random/tool/advanced = 5,
	/obj/random/lathe_disk/advanced = 3,
	/obj/item/weapon/cell/small/moebius/nuclear = 1,
	/obj/item/weapon/cell/medium/moebius/hyper = 1,
	/obj/item/weapon/tank/emergency_oxygen/double = 2,
	/obj/random/rig = 1.5,
	/obj/random/rig/damaged = 1.5,
	/obj/random/voidsuit = 4,
	/obj/random/pouch/rare = 4,
	/obj/random/tool_upgrade/rare = 4,
	/obj/random/rig_module/rare = 4,
	/obj/random/credits/c5000 = 4,
	/obj/random/mecha_equipment = 3,
	/obj/item/stash_spawner = 4 //Creates a stash of goodies for a scavenger hunt
	))
