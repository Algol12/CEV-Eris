/obj/machinery/plumbing/bottler
	name = "chemical bottler"
	desc = "Puts reagents into containers, like bottles and beakers."
	icon_state = "bottler"
	layer = ABOVE_ALL_MOB_LAYER
	reagent_flags = TRANSPARENT | DRAINABLE
	rcd_cost = 50
	rcd_delay = 50
	buffer = 100
	///how much do we fill
	var/wanted_amount = 10
	///where things are sent
	var/turf/goodspot
	///where things are taken
	var/turf/inputspot
	///where beakers that are already full will be sent
	var/turf/badspot

/obj/machinery/plumbing/bottler/Initialize(mapload, d=0, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)
	set_dir(dir)

/obj/machinery/plumbing/bottler/can_be_rotated(mob/user)
	if(anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

///changes the tile array
/obj/machinery/plumbing/bottler/set_dir(newdir)
	. = ..()
	switch(dir)
		if(NORTH)
			goodspot = get_step(get_turf(src), NORTH)
			inputspot = get_step(get_turf(src), SOUTH)
			badspot  = get_step(get_turf(src), EAST)
		if(SOUTH)
			goodspot = get_step(get_turf(src), SOUTH)
			inputspot = get_step(get_turf(src), NORTH)
			badspot  = get_step(get_turf(src), WEST)
		if(WEST)
			goodspot = get_step(get_turf(src), WEST)
			inputspot = get_step(get_turf(src), EAST)
			badspot  = get_step(get_turf(src), NORTH)
		if(EAST)
			goodspot = get_step(get_turf(src), EAST)
			inputspot = get_step(get_turf(src), WEST)
			badspot  = get_step(get_turf(src), SOUTH)

///changing input ammount with a window
/obj/machinery/plumbing/bottler/interact(mob/user)
	. = ..()
	wanted_amount = clamp(round(input(user,"maximum is 100u","set ammount to fill with") as num|null, 1), 1, 100)
	reagents.clear_reagents()
	to_chat(user, SPAN_NOTICE(" The [src] will now fill for [wanted_amount]u."))

/obj/machinery/plumbing/bottler/Process()
	if(stat & NOPOWER)
		return
	///see if machine has enough to fill
	if(reagents.total_volume >= wanted_amount && anchored)
		var/obj/AM = pick(inputspot.contents)///pick a reagent_container that could be used
		if(istype(AM, /obj/item/weapon/reagent_containers))
			var/obj/item/weapon/reagent_containers/B = AM
			///see if it would overflow else inject
			if((B.reagents.total_volume + wanted_amount) <= B.reagents.maximum_volume)
				reagents.trans_to(B, wanted_amount)
				B.forceMove(goodspot)
				return
			///glass was full so we move it away
			AM.forceMove(badspot)
		if(istype(AM, /obj/item/slime_extract)) ///slime extracts need inject
			AM.forceMove(goodspot)
			reagents.trans_to(AM, wanted_amount)
			return
