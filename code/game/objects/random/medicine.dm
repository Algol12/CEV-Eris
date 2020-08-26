/obj/random/medical
	name = "random medicine"
	icon_state = "meds-green"

/obj/random/medical/item_to_spawn()
	return pickweight(list(/obj/item/stack/medical/bruise_pack = 4,\
				/obj/item/stack/medical/ointment = 4,\
				/obj/item/stack/medical/advanced/bruise_pack = 2,\
				/obj/item/stack/medical/advanced/ointment = 2,\
				/obj/item/stack/medical/splint = 1,\
				/obj/item/bodybag = 2,\
				/obj/item/bodybag/cryobag = 1,\
				/obj/item/weapon/storage/pill_bottle/kelotane = 2,\
				/obj/item/weapon/storage/pill_bottle/antitox = 2,\
				/obj/item/weapon/storage/pill_bottle/tramadol = 2,\
				/obj/item/weapon/storage/pill_bottle/prosurgeon = 1,
				/obj/item/weapon/reagent_containers/syringe/antitoxin = 2,\
				/obj/item/weapon/reagent_containers/syringe/inaprovaline = 2,\
				/obj/item/weapon/reagent_containers/syringe/tricordrazine = 1,\
				/obj/item/weapon/reagent_containers/syringe/spaceacillin = 1,\
				/obj/item/weapon/reagent_containers/glass/beaker/vial/nanites = 0.5,\
				/obj/item/stack/nanopaste = 1))

/obj/random/medical/low_chance
	name = "low chance random medicine"
	icon_state = "meds-green-low"
	spawn_nothing_percentage = 60

/obj/random/medical_lowcost
	name = "random low tier medicine"
	icon_state = "meds-grey"

/obj/random/medical_lowcost/item_to_spawn()
	return pickweight(list(/obj/item/stack/medical/bruise_pack = 4,\
				/obj/item/stack/medical/ointment = 4,\
				/obj/item/weapon/reagent_containers/syringe/antitoxin = 2,\
				/obj/item/weapon/reagent_containers/syringe/inaprovaline = 2,\
				/obj/item/weapon/reagent_containers/syringe/tricordrazine = 1))

/obj/random/medical_lowcost/low_chance
	name = "low chance random low tier medicine"
	icon_state = "meds-grey-low"
	spawn_nothing_percentage = 60

/obj/spawner/firstaid
	name = "random first aid kit"
	icon_state = "meds-red"
	tags_to_spawn = list(SPAWN_FIRSTAID)

/obj/spawner/firstaid/low_chance
	name = "low chance random first aid kit"
	icon_state = "meds-red-low"
	spawn_nothing_percentage = 60
