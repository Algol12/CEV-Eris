/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	layer = 2

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/simulated/shuttle/floor/mining
	icon_state = "6,19"
	icon = 'icons/turf/shuttlemining.dmi'

/turf/simulated/shuttle/floor/science
	icon_state = "8,15"
	icon = 'icons/turf/shuttlescience.dmi'

/turf/simulated/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"
	level = 1

/turf/simulated/shuttle/plating/is_plating()
	return TRUE


turf/simulated/floor/plating
	icon = 'icons/turf/floors.dmi'
	name = "plating"
	icon_state = "plating"
	flags = TURF_HAS_EDGES | TURF_HAS_CORNERS
	initial_flooring = /decl/flooring/reinforced/plating
	var/plating_level = 3
	//Plating of 3 = plating
	//2 = underplating
	//1 = hull
	//0 = normal floor
	footstep_sounds = list("human" = list(\
		'sound/effects/footstep/plating1.ogg',\
		'sound/effects/footstep/plating2.ogg',\
		'sound/effects/footstep/plating3.ogg',\
		'sound/effects/footstep/plating4.ogg',\
		'sound/effects/footstep/plating5.ogg'))

/turf/simulated/floor/plating/under
	name = "underplating"
	icon_state = "un"
	icon = 'icons/turf/un.dmi'
	var/icon_base = "un"
	initial_flooring = /decl/flooring/reinforced/plating/under
	flags = TURF_HAS_EDGES | TURF_HAS_CORNERS
	var/has_base_range = null
	plating_level = 2
/*
/turf/simulated/floor/plating/under/update_icon(var/update_neighbors)
	if(lava)
		return
	// Set initial icon and strings.
	if(!isnull(set_update_icon) && istext(set_update_icon))
		icon_state = set_update_icon
	else if(flooring_override)
		icon_state = flooring_override
	else
		icon_state = icon_base
		if(has_base_range)
			icon_state = "[icon_state][rand(0,has_base_range)]"
			flooring_override = icon_state
	// Apply edges, corners, and inner corners.
	overlays.Cut()
	var/has_border = 0
	if(isnull(set_update_icon) && (flags & TURF_HAS_EDGES))
		for(var/step_dir in cardinal)
			var/turf/simulated/floor/T = get_step(src, step_dir)
			if((!istype(T) || !T || T.name != name) && !istype(T, /turf/simulated/open) && !istype(T, /turf/space))
				has_border |= step_dir
				overlays |= get_flooring_overlayu("[icon_base]-edge-[step_dir]", "[icon_base]_edges", step_dir)
		if ((flags & TURF_USE0ICON) && has_border)
			icon_state = icon_base+"0"

		// There has to be a concise numerical way to do this but I am too noob.
		if((has_border & NORTH) && (has_border & EAST))
			overlays |= get_flooring_overlayu("[icon_base]-edge-[NORTHEAST]", "[icon_base]_edges", NORTHEAST)
		if((has_border & NORTH) && (has_border & WEST))
			overlays |= get_flooring_overlayu("[icon_base]-edge-[NORTHWEST]", "[icon_base]_edges", NORTHWEST)
		if((has_border & SOUTH) && (has_border & EAST))
			overlays |= get_flooring_overlayu("[icon_base]-edge-[SOUTHEAST]", "[icon_base]_edges", SOUTHEAST)
		if((has_border & SOUTH) && (has_border & WEST))
			overlays |= get_flooring_overlayu("[icon_base]-edge-[SOUTHWEST]", "[icon_base]_edges", SOUTHWEST)

		if(flags & TURF_HAS_CORNERS)
			// As above re: concise numerical way to do this.
			if(!(has_border & NORTH))
				if(!(has_border & EAST))
					var/turf/simulated/floor/T = get_step(src, NORTHEAST)
					if((!istype(T) || !T || T.name != name) && !istype(T, /turf/simulated/open) && !istype(T, /turf/space))
						overlays |= get_flooring_overlayu("[icon_base]-corner-[NORTHEAST]", "[icon_base]_corners", NORTHEAST)
				if(!(has_border & WEST))
					var/turf/simulated/floor/T = get_step(src, NORTHWEST)
					if((!istype(T) || !T || T.name != name) && !istype(T, /turf/simulated/open) && !istype(T, /turf/space))
						overlays |= get_flooring_overlayu("[icon_base]-corner-[NORTHWEST]", "[icon_base]_corners", NORTHWEST)
			if(!(has_border & SOUTH))
				if(!(has_border & EAST))
					var/turf/simulated/floor/T = get_step(src, SOUTHEAST)
					if((!istype(T) || !T || T.name != name) && !istype(T, /turf/simulated/open) && !istype(T, /turf/space))
						overlays |= get_flooring_overlayu("[icon_base]-corner-[SOUTHEAST]", "[icon_base]_corners", SOUTHEAST)
				if(!(has_border & WEST))
					var/turf/simulated/floor/T = get_step(src, SOUTHWEST)
					if((!istype(T) || !T || T.name != name) && !istype(T, /turf/simulated/open) && !istype(T, /turf/space))
						overlays |= get_flooring_overlayu("[icon_base]-corner-[SOUTHWEST]", "[icon_base]_corners", SOUTHWEST)

	if(decals && decals.len)
		overlays |= decals

	if(is_plating() && !(isnull(broken) && isnull(burnt))) //temp, todo
		icon = 'icons/turf/flooring/plating.dmi'
		icon_state = "dmg[rand(1,4)]"
	else
		if(!isnull(broken) && (flags & TURF_CAN_BREAK))
			overlays |= get_flooring_overlayu("[icon_base]-broken-[broken]", "broken[broken]")
		if(!isnull(burnt) && (flags & TURF_CAN_BURN))
			overlays |= get_flooring_overlayu("[icon_base]-burned-[burnt]", "burned[burnt]")
	if(update_neighbors)
		for(var/turf/simulated/floor/F in trange(1, src) - src)
			F.update_icon()


/turf/simulated/floor/plating/under/proc/get_flooring_overlayu(var/cache_key, var/icon_base, var/icon_dir = 0)
	if(!flooring_cache[cache_key])
		var/image/I = image(icon = icon, icon_state = icon_base, dir = icon_dir)
		I.layer = layer
		flooring_cache[cache_key] = I
	return flooring_cache[cache_key]
*/

/turf/simulated/floor/plating/under/Entered(mob/living/M as mob)
	..()
	for(var/obj/structure/catwalk/C in get_turf(src))
		return

	//BSTs need this or they generate tons of soundspam while flying through the ship
	if(!ishuman(M)|| M.incorporeal_move || !has_gravity(src))
		return
	if(M.m_intent == "run")
		if(prob(40))
			M.adjustBruteLoss(5)
			M.slip(null, 6)
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
			M << SPAN_WARNING("You tripped over!")
			return

/turf/simulated/floor/plating/under/attackby(obj/item/C as obj, mob/user as mob)
	if (istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if(R.amount <= 2)
			return
		else
			R.use(2)
			user << SPAN_NOTICE("You start connecting [R.name]s to [src.name], creating catwalk ...")
			if(do_after(user,50))
				src.alpha = 0
				var/obj/structure/catwalk/CT = new /obj/structure/catwalk(src.loc)
				src.contents += CT
			return
	return

/turf/simulated/shuttle/plating/vox //Skipjack plating
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD

/turf/simulated/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/simulated/shuttle/floor4/vox //skipjack floors
	name = "skipjack floor"
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD
