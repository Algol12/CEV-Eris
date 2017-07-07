//Due to how large this one is it gets its own file
/datum/job/chaplain
	title = "Cyberchristian priest"
	flag = CHAPLAIN
	department = "Civilian"
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the First Officer and God"
	selection_color = "#dddddd"
	access = list(access_morgue, access_chapel_office, access_crematorium, access_maint_tunnels)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium)
	idtype = /obj/item/weapon/card/id/chaplain
	uniform = /obj/item/clothing/under/rank/chaplain
	pda = /obj/item/device/pda/chaplain

/datum/job/chaplain/equip(var/mob/living/carbon/human/H)
	//DONT FORGET CHANGE THIS TO PRIEST world << "D:
	var/obj/item/weapon/implant/external/core_implant/cruciform/C = new /obj/item/weapon/implant/external/core_implant/cruciform(H)
	C.install(H)
	C.activate()
	C.add_module(new CRUCIFORM_INQUISITOR)

	H.religion = "Christianity"

	if(!..())	return FALSE

	var/obj/item/weapon/book/ritual/cruciform/B = new /obj/item/weapon/book/ritual/cruciform(H)
	H.equip_to_slot_or_del(B, slot_l_hand)
	return TRUE
