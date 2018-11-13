/obj/item/weapon/rig/attackby(obj/item/I, mob/user)

	if(!isliving(user))
		return

	if(electrified != 0)
		if(shock(user)) //Handles removing charge from the cell, as well. No need to do that here.
			return



	// Lock or unlock the access panel.
	if(I.GetIdCard())
		if(subverted)
			locked = 0
			user << SPAN_DANGER("It looks like the locking system has been shorted out.")
			return

		if(locked == -1)
			user << SPAN_DANGER("The lock clicks uselessly.")
			return

		if((!req_access || !req_access.len) && (!req_one_access || !req_one_access.len))
			locked = 0
			user << SPAN_DANGER("\The [src] doesn't seem to have a locking mechanism.")
			return

		if(security_check_enabled && !src.allowed(user))
			user << SPAN_DANGER("Access denied.")
			return

		locked = !locked
		user << "You [locked ? "lock" : "unlock"] \the [src] access panel."
		return

	var/list/usable_qualities = list(QUALITY_PRYING, QUALITY_WELDING,QUALITY_WIRE_CUTTING, QUALITY_PULSING, QUALITY_CUTTING, QUALITY_BOLT_TURNING, QUALITY_SCREW_DRIVING)
	var/tool_type = I.get_tool_type(user, usable_qualities)
	switch(tool_type)
		if(QUALITY_SCREW_DRIVING)
			if (is_worn())
				user << "You can't remove an installed device while the hardsuit is being worn."
				return 1

			if(open)
				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					var/list/current_mounts = list()
					if(cell) current_mounts   += "cell"
					if(installed_modules && installed_modules.len) current_mounts += "system module"

					var/to_remove = input("Which would you like to modify?") as null|anything in current_mounts
					if(!to_remove)
						return


					switch(to_remove)
						if("cell")
							if(cell)
								user << "You detatch \the [cell] from \the [src]'s battery mount."
								for(var/obj/item/rig_module/module in installed_modules)
									module.deactivate()
								if(user.r_hand && user.l_hand)
									cell.forceMove(get_turf(user))
								else
									cell.forceMove(user.put_in_hands(cell))
								cell = null
							else
								user << "There is nothing loaded in that mount."

						if("system module")
							var/list/possible_removals = list()
							for(var/obj/item/rig_module/module in installed_modules)
								if(module.permanent)
									continue
								possible_removals[module.name] = module

							if(!possible_removals.len)
								user << "There are no installed modules to remove."
								return

							var/removal_choice = input("Which module would you like to remove?") as null|anything in possible_removals
							if(!removal_choice)
								return

							uninstall(possible_removals[removal_choice], user)
							return TRUE
			else
				user << "\The [src] access panel is closed."
				return

		if(QUALITY_WIRE_CUTTING)
			if(open)
				wires.Interact(user)
				return
			else
				user << "\The [src] access panel is closed."
				return

		if(QUALITY_PULSING)
			if(open)
				wires.Interact(user)
				return
			else
				user << "\The [src] access panel is closed."
				return

		if(QUALITY_CUTTING)
			if(open)
				wires.Interact(user)
				return
			else
				user << "\The [src] access panel is closed."
				return

		if(QUALITY_PRYING)
			if(locked != 1)
				if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					open = !open
					user << SPAN_NOTICE("You [open ? "open" : "close"] the access panel.")
					return
			else
				user << SPAN_DANGER("\The [src] access panel is locked.")
				return

		if(QUALITY_BOLT_TURNING)
			if(open)
				if(!air_supply)
					user << "There is not tank to remove."
					return

				if (is_worn())
					user << "You can't remove an installed tank while the hardsuit is being worn."
					return 1

				if(I.use_tool(user, src, WORKTIME_NEAR_INSTANT, tool_type, FAILCHANCE_VERY_EASY, required_stat = STAT_MEC))
					if(user.l_hand && user.r_hand)
						air_supply.forceMove(get_turf(user))
					else
						user.put_in_hands(air_supply)
					user << "You detach and remove \the [air_supply]."
					air_supply = null
					return
			else
				user << "\The [src] access panel is closed."
				return

		if(QUALITY_WELDING)
			//Cutting through the cover lock. This allows access to the wires inside so you can disable access requirements
			//Ridiculously difficult to do, hijacking a rig will take a long time if you don't have good mechanical training
			if(locked == 1)
				user << SPAN_NOTICE("You start cutting through the access panel's cover lock. This is a delicate task.")
				if(I.use_tool(user, src, WORKTIME_EXTREMELY_LONG, tool_type, FAILCHANCE_VERY_HARD, required_stat = STAT_MEC))
					locked = -1 //Broken, it can never be locked again
					user << SPAN_NOTICE("Success! The tension in the panel loosens with a dull click")
					playsound(src.loc, 'sound/weapons/guns/interact/pistol_magin.ogg', 75, 1)
				return
			else
				user << "\The [src] access panel is not locked, there's no need to cut it."
				//No return here, incase they're trying to repair

		if(ABORT_CHECK)
			return

	// Pass repair items on to the chestpiece.
	if(chest && (istype(I,/obj/item/stack/material) || QUALITY_WELDING in I.tool_qualities))
		return chest.attackby(I,user)

	if(open)
		// Air tank.
		if(istype(I,/obj/item/weapon/tank)) //Todo, some kind of check for suits without integrated air supplies.
			if(air_supply)
				user << "\The [src] already has a tank installed."
				return

			if(!user.unEquip(I))
				return
			air_supply = I
			I.forceMove(src)
			user << "You slot [I] into [src] and tighten the connecting valve."
			return

		// Check if this is a hardsuit upgrade or a modification.
		else if(istype(I,/obj/item/rig_module))
			if (can_install(I, user, TRUE))
				install(I, user)
			return TRUE
		else if(!cell && istype(I,/obj/item/weapon/cell/large))
			if(!user.unEquip(I))
				return
			user << "You jack \the [I] into \the [src]'s battery mount."
			I.forceMove(src)
			src.cell = I
			return

		return

	// If we've gotten this far, all we have left to do before we pass off to root procs
	// is check if any of the loaded modules want to use the item we've been given.
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.accepts_item(I,user)) //Item is handled in this proc
			return
	..()


/obj/item/weapon/rig/attack_hand(var/mob/user)

	if(electrified != 0)
		if(shock(user)) //Handles removing charge from the cell, as well. No need to do that here.
			return
	..()

/obj/item/weapon/rig/emag_act(var/remaining_charges, var/mob/user)
	if(!subverted)
		req_access.Cut()
		req_one_access.Cut()
		if (locked != -1)
			locked = 0
		subverted = 1
		user << SPAN_DANGER("You short out the access protocol for the suit.")
		return 1
