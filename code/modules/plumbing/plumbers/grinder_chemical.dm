/obj/machinery/plumbing/grinder_chemical
	name = "chemical grinder"
	desc = "chemical grinder."
	icon_state = "grinder_chemical"
	layer = ABOVE_ALL_MOB_LAYER
	reagent_flags = TRANSPARENT | DRAINABLE
	rcd_cost = 30
	rcd_delay = 30
	buffer = 400
	var/eat_dir = SOUTH

/obj/machinery/plumbing/grinder_chemical/Initialize(mapload, d=0)
	. = ..()
	AddComponent(/datum/component/plumbing/supply, anchored)

/obj/machinery/plumbing/grinder_chemical/can_be_rotated(mob/user, rotation_type)
	if(anchored)
		to_chat(user, SPAN_WARNING("It is fastened to the floor!"))
		return FALSE
	return TRUE

/obj/machinery/plumbing/grinder_chemical/set_dir(newdir)
	. = ..()
	eat_dir = newdir

/obj/machinery/plumbing/grinder_chemical/CanPass(atom/movable/AM)
	. = ..()
	if(!anchored)
		return
	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_dir)
		return TRUE

/obj/machinery/plumbing/grinder_chemical/Crossed(atom/movable/AM)
	. = ..()
	grind(AM)

/obj/machinery/plumbing/grinder_chemical/proc/grind(atom/AM)
	if(stat & NOPOWER)
		return
	if(reagents.holder_full())
		return
	if(!isitem(AM))
		return
	var/obj/item/I = AM
	if(I.reagents)
		I.reagents.trans_to(src, I.reagents.total_volume, ignore_isinjectable=TRUE)
		qdel(I)
		return

