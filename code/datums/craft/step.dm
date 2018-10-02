/datum/craft_step
	var/reqed_type
	var/reqed_quality
	var/reqed_material
	var/req_amount = 0

	var/time = 15

	var/desc = ""
	var/start_msg = ""
	var/end_msg = ""


/datum/craft_step/New(var/list/params)
	if(ispath(params))
		reqed_type    = params
	else if(istext(params))
		reqed_quality = params
	else if(islist(params))
		var/validator = params[1]
		if(ispath(validator))
			reqed_type = validator
		else if(istext(validator))
			if (validator == CRAFT_MATERIAL)
				reqed_material = params[3]
			else
				reqed_quality = validator

		if(isnum(params[2])) //amount
			req_amount = params[2]

		if("time" in params)
			time = params["time"]
		else if(params.len >= 3)
			time = params[3]

	var/tool_name

	if(reqed_type)
		var/obj/item/I = reqed_type
		tool_name = initial(I.name)

	else if(reqed_quality)
		tool_name = "tool with quality of [reqed_quality]"

	else if (reqed_material)
		var/material/M = get_material_by_name("[reqed_material]")
		tool_name = M.display_name

	switch(req_amount)
		if(0)
			desc = "Apply [tool_name]"
			start_msg = "%USER% starts use %ITEM% on %TARGET%"
			end_msg = "%USER% applied %ITEM% to %TARGET%"
		if(1)
			desc = "Attach [tool_name]"
			start_msg = "%USER% starts attaching %ITEM% to %TARGET%"
			end_msg = "%USER% attached %ITEM% to %TARGET%"
		else
			desc = "Attach [req_amount] [tool_name]"
			start_msg = "%USER% starts attaching %ITEM% to %TARGET%"
			end_msg = "%USER% attached %ITEM% to %TARGET%"


/datum/craft_step/proc/announce_action(var/msg, mob/living/user, obj/item/tool, atom/target)
	msg = replacetext(msg,"%USER%","[user]")
	msg = replacetext(msg,"%ITEM%","[tool]")
	msg = replacetext(msg,"%TARGET%","[target]")
	user.visible_message(
		msg
	)

/datum/craft_step/proc/apply(obj/item/I, mob/living/user, atom/target = null)
	if(reqed_type)
		if(!istype(I, reqed_type))
			user << "Wrong item!"
			return
		if (!is_valid_to_consume(I, user))
			user << "That item can't be used for crafting!"
			return

		if(req_amount && istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			if(S.get_amount() < req_amount)
				user << "Not enough items in [I]"
				return


		if(target)
			announce_action(start_msg, user, I, target)
		if(!do_after(user, time, target || user))
			world << "Doafter Failed"
			return
	else if(reqed_quality)
		if(!I.get_tool_quality(reqed_quality))
			user << "Wrong item!"
			return
		if(target)
			announce_action(start_msg, user, I, target)
		if(!I.use_tool(user, target || user, time, reqed_quality))
			return

	if(req_amount)
		if(istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			if(!S.use(req_amount))
				world << "Using items from stack failed. "
				world << "Stack has [S.get_amount()] units and we needed [req_amount]"
				user << SPAN_WARNING("Not enough items in [S]. It has [S.get_amount()] units and we need [req_amount]")
				return FALSE
		else if (reqed_type)
			qdel(I)

	if(target)
		announce_action(end_msg, user, I, target)

	return TRUE

/datum/craft_step/proc/find_item(mob/living/user)
	var/list/items = new
	for(var/slot in list(slot_l_hand, slot_r_hand))
		items += user.get_equipped_item(slot)

	var/obj/item/weapon/storage/belt = user.get_equipped_item(slot_belt)
	if(istype(belt))
		items += belt.contents

	//Robots can use their module items as tools or materials
	//We will do a check later to prevent them from dropping their tools as consumed components
	if (isrobot(user))
		var/mob/living/silicon/robot/R = user
		if (R.module_state_1)
			items += R.module_state_1
		if (R.module_state_2)
			items += R.module_state_2
		if (R.module_state_3)
			items += R.module_state_3

	//We will allow all items in a 3x3 area, centred on the tile infront, to be used as components or mats
	//Tools must be held though
	if (!reqed_quality)
		var/turf/T = get_step(user, user.dir)
		//Use atom/movable to account for the possiblity of recipes requiring live or dead mobs as ingredients
		for (var/atom/movable/A in range(1, T))
			if (!A.anchored)
				items += A

	if(reqed_type)
		world << "Trying to find required type [reqed_type]"
		//Special handling for items that will be consumed
		for(var/atom/movable/I in items)
			//First we find the item
			world << "Checking [I]"
			if (!istype(I, reqed_type))
				//not the right type
				continue
			world << "Found a match!"
			//Okay, so we found something that matches
			if (is_valid_to_consume(I, user))
				return I



	else if(reqed_quality)
		var/best_value = 0
		for(var/obj/item/I in items)
			var/value = I.get_tool_quality(reqed_quality)
			if(value > best_value)
				value = best_value
				. = I

	else if (reqed_material)
		world << "Required material, checking items"
		for(var/obj/item/I in items)
			world << "Checking [I]"
			if (istype(I, /obj/item/stack/material))
				world << "Is material"
				var/obj/item/stack/material/MA = I
				if (MA.material && (MA.material.name == reqed_material))
					world << "Correct material, we found a match"
					return I
				else
					world << "[MA] is wrong material [reqed_material]"

/datum/craft_step/proc/is_valid_to_consume(var/obj/item/I, var/mob/living/user)
	var/holder = I.get_holding_mob()
	//Next we must check if we're actually allowed to submit it
	if (!holder)
		//If the item is lying on a turf, it's fine
		world << "Item is on turf, fine"
		return I

	if (holder != user)
		//The item is held by someone else, can't use
		world << "Item is held by another mob, cant use"
		return FALSE

	//If we get here, the item is held by our user
	if (I.loc != user)
		//The item must be inside a container on their person, it's fine
		world << "Item is in held container, fine"
		return I

	//The item is on the user
	if (user.canUnEquip(I))
		//We test if they can remove it, this will return false for robot objects
		world << "Item is removable, fine"
		return I


	if (istype(I, /obj/item/stack))
		//Robots are allowed to use stacks, since those will only deplete the amount but not destroy the item
		world << "Item is stack, fine"
		return I

	world << "===Item is a match but WAS NOT VALID==="
	//If we get here, then we found the item but it wasn't valid to use, sorry!

	return FALSE