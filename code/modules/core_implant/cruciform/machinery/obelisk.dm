/obj/machinery/power/nt_obelisk
	name = "NeoTheology's obelisk."
	desc = "The obelisk."
	icon = 'icons/obj/neotheology_machinery.dmi'
	icon_state = "nt_obelisk_base"
	//TODO:
	//circuit = /obj/item/weapon/circuitboard/nt_obelisk

	density = TRUE
	anchored = TRUE
	layer = 2.8

	frame_type = FRAME_VERTICAL

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 2500

	var/active = FALSE
	var/area_radius = 7
	var/damage = 20
	var/max_targets = 5

/obj/machinery/power/nt_obelisk/New()
	..()
	Initialize()

/obj/machinery/power/nt_obelisk/process()
	..()
	if(stat)
		return
	var/new_state = check_for_faithful()
	update_icon(new_state)
	if(!active)
		use_power = 1
		for(var/obj/structure/burrow/burrow in range(area_radius, src))
			if(burrow.obelisk_around == any2ref(src))
				burrow.obelisk_around = null
	else
		use_power = 2
		for(var/obj/structure/burrow/burrow in range(area_radius, src))
			if(!burrow.obelisk_around)
				burrow.obelisk_around = any2ref(src)

		var/to_fire = max_targets
		for(var/mob/living/simple_animal/hostile/animal in range(area_radius, src))
			if(animal && animal.stat != DEAD) //got roach, spider, maybe bear
				animal.take_overall_damage(0, damage)
				to_fire--
				if(!to_fire) return
		for(var/obj/effect/plant/shroom in range(area_radius, src))
			if(shroom.seed.type == /datum/seed/mushroom/maintshroom)
				qdel(shroom)
				to_fire--
				if(!to_fire) return

/obj/machinery/power/nt_obelisk/proc/check_for_faithful()
	var/got_neoteo = FALSE
	for(var/mob/living/carbon/human/mob in range(area_radius, src))
		if(mob)
			var/obj/item/weapon/implant/core_implant/I = mob.get_core_implant()
			if(I && I.active && I.wearer)
				if(I.power < I.max_power)	I.power += 0.5
				got_neoteo = TRUE
	return got_neoteo


/obj/machinery/power/nt_obelisk/update_icon(var/state)
	if(state == active)
		return
	overlays.Cut()

	var/image/I = image(icon, "nt_obelisk_top[active?"_on":""]")
	I.layer = 5
	I.pixel_z = 32
	overlays.Add(I)

	I = image(icon, "nt_obelisk_base_overlay[state?"_pup":"_pdown"]")
	I.layer = 5
	overlays.Add(I)
	I = image(icon, "nt_obelisk_top_overlay[state?"_pup":"_pdown"]")
	I.layer = 5.021
	I.pixel_z = 32
	overlays.Add(I)
