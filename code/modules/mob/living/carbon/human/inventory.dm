/*
Add fingerprints to items when we put them in our hands.
This saves us from having to call add_fingerprint() any time something is put in a human's hands programmatically.
*/

/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = H.get_active_hand()
		if(!I)
			H << SPAN_NOTICE("You are not holding anything to equip.")
			return
		if(H.equip_to_appropriate_slot(I))
			if(hand)
				update_inv_l_hand(0)
			else
				update_inv_r_hand(0)
		else
			H << "\red You are unable to equip that."

//Puts the item into our active hand if possible. returns 1 on success.
/mob/living/carbon/human/put_in_active_hand(var/obj/item/W)
	return (hand ? put_in_l_hand(W) : put_in_r_hand(W))

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/living/carbon/human/put_in_inactive_hand(var/obj/item/W)
	return (hand ? put_in_r_hand(W) : put_in_l_hand(W))

/mob/living/carbon/human/put_in_hands(var/obj/item/W)
	if(!W)
		return FALSE
	if(put_in_active_hand(W) || put_in_inactive_hand(W))
		world << "Successfully put in hand"
		return TRUE
	else
		return ..()

/mob/living/carbon/human/put_in_l_hand(var/obj/item/W)
	if(!..())
		return 0
	W.add_fingerprint(src)
	return 1

/mob/living/carbon/human/put_in_r_hand(var/obj/item/W)
	if(!..())
		return 0
	W.add_fingerprint(src)
	return 1


//Find HUD position on screen
/mob/living/carbon/human/proc/find_inv_position(var/slot_id)
	for(var/obj/screen/inventory/HUDinv in HUDinventory)
		if (HUDinv.slot_id == slot_id)
			return (HUDinv.invisibility == 101) ? null : HUDinv.screen_loc
	log_admin("[src] try find_inv_position a [slot_id], but not have that slot!")
	src << "Some problem hase accure, change UI style pls or call admins."
	return "7,7"

/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if (del_on_fail)
		qdel(W)
	return null


/mob/living/carbon/human/proc/has_organ(name)
	var/obj/item/organ/external/O = organs_by_name[name]

	return (O && !O.is_stump())

/mob/living/carbon/human/proc/has_organ_for_slot(slot)
	switch(slot)
		if(slot_back)
			return has_organ(BP_CHEST)
		if(slot_wear_mask)
			return has_organ(BP_HEAD)
		if(slot_handcuffed)
			return has_organ(BP_L_ARM) && has_organ(BP_R_ARM)
		if(slot_legcuffed)
			return has_organ(BP_L_LEG ) && has_organ(BP_R_LEG)
		if(slot_l_hand)
			return has_organ(BP_L_ARM)
		if(slot_r_hand)
			return has_organ(BP_R_ARM)
		if(slot_belt)
			return has_organ(BP_CHEST)
		if(slot_wear_id)
			// the only relevant check for this is the uniform check
			return 1
		if(slot_l_ear, slot_r_ear, slot_glasses)
			return has_organ(BP_HEAD)
		if(slot_gloves)
			return has_organ(BP_L_ARM) || has_organ(BP_R_ARM)
		if(slot_head)
			return has_organ(BP_HEAD)
		if(slot_shoes)
			return has_organ(BP_R_LEG) || has_organ(BP_L_LEG)
		if(slot_wear_suit, slot_w_uniform, slot_l_store, slot_r_store, slot_s_store)
			return has_organ(BP_CHEST)
		if(slot_in_backpack)
			return 1
		if(slot_accessory_buffer)
			return 1

/mob/living/carbon/human/u_equip(obj/W as obj)
	if(!W)	return 0

	if (W == wear_suit)
		if(s_store)
			drop_from_inventory(s_store)
		wear_suit = null
		update_inv_wear_suit()
	else if (W == w_uniform)
		if (r_store)
			drop_from_inventory(r_store)
		if (l_store)
			drop_from_inventory(l_store)
		if (wear_id)
			drop_from_inventory(wear_id)
		if (belt)
			drop_from_inventory(belt)
		w_uniform = null
		update_inv_w_uniform()
	else if (W == gloves)
		gloves = null
		update_inv_gloves()
	else if (W == glasses)
		glasses = null
		update_inv_glasses()
	else if (W == head)
		head = null
		if(istype(W, /obj/item))
			var/obj/item/I = W
			if(I.flags_inv & (HIDEMASK|BLOCKHAIR|BLOCKHEADHAIR))
				update_hair(0)	//rebuild hair
				update_inv_ears(0)
				update_inv_wear_mask(0)
		update_inv_head()
	else if (W == l_ear)
		l_ear = null
		update_inv_ears()
	else if (W == r_ear)
		r_ear = null
		update_inv_ears()
	else if (W == shoes)
		shoes = null
		update_inv_shoes()
	else if (W == belt)
		belt = null
		update_inv_belt()
	else if (W == wear_mask)
		wear_mask = null
		if(istype(W, /obj/item))
			var/obj/item/I = W
			if(I.flags_inv & (BLOCKHAIR|BLOCKHEADHAIR))
				update_hair(0)	//rebuild hair
				update_inv_ears(0)
		if(HUDneed.Find("internal"))
			var/obj/screen/HUDelm = HUDneed["internal"]
			HUDelm.update_icon()
/*			if(internals)
				internals.icon_state = "internal0"*/
			internal = null
		update_inv_wear_mask()
	else if (W == wear_id)
		wear_id = null
		update_inv_wear_id()
	else if (W == r_store)
		r_store = null
		update_inv_pockets()
	else if (W == l_store)
		l_store = null
		update_inv_pockets()
	else if (W == s_store)
		s_store = null
		update_inv_s_store()
	else if (W == back)
		back = null
		update_inv_back()
	else if (W == handcuffed)
		handcuffed = null
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()
		update_inv_handcuffed()
	else if (W == legcuffed)
		legcuffed = null
		update_inv_legcuffed()
	else if (W == r_hand)
		r_hand = null
		if(l_hand)
			l_hand.update_held_icon()
			update_inv_l_hand()
		update_inv_r_hand()
	else if (W == l_hand)
		l_hand = null
		if(r_hand)
			r_hand.update_held_icon()
			update_inv_l_hand()
		update_inv_l_hand()
	else
		return 0

	update_action_buttons()
	return 1

/mob/living/carbon/human/proc/get_active_hand_organ()
	if(hand)
		return get_organ(BP_L_ARM)
	else
		return get_organ(BP_R_ARM)

/mob/living/carbon/human/proc/get_holding_hand(var/obj/item/W)
	switch(get_inventory_slot(W))
		if(slot_l_hand)
			return BP_L_ARM
		if(slot_r_hand)
			return BP_R_ARM



//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W as obj, slot, redraw_mob = 1)

	if(!slot) return
	if(!istype(W)) return
	if(!has_organ_for_slot(slot)) return
	if(!species || !species.hud || !(slot in species.hud.equip_slots)) return
	if(ismob(W.loc))
		var/mob/M = W.loc
		if(M.get_inventory_slot(W) && !M.prepare_for_slotmove(W))
			return
	W.forceMove(src)
	switch(slot)
		if(slot_back)
			src.back = W
			W.equipped(src, slot)
			update_inv_back(redraw_mob)
		if(slot_wear_mask)
			src.wear_mask = W
			if(wear_mask.flags_inv & (BLOCKHAIR|BLOCKHEADHAIR))
				update_hair(redraw_mob)	//rebuild hair
				update_inv_ears(0)
			W.equipped(src, slot)
			update_inv_wear_mask(redraw_mob)
		if(slot_handcuffed)
			src.handcuffed = W
			update_inv_handcuffed(redraw_mob)
		if(slot_legcuffed)
			src.legcuffed = W
			W.equipped(src, slot)
			update_inv_legcuffed(redraw_mob)
		if(slot_l_hand)
			src.l_hand = W
			W.equipped(src, slot)
			update_inv_l_hand(redraw_mob)
		if(slot_r_hand)
			src.r_hand = W
			W.equipped(src, slot)
			update_inv_r_hand(redraw_mob)
		if(slot_belt)
			src.belt = W
			W.equipped(src, slot)
			update_inv_belt(redraw_mob)
		if(slot_wear_id)
			src.wear_id = W
			W.equipped(src, slot)
			update_inv_wear_id(redraw_mob)
		if(slot_l_ear)
			src.l_ear = W
			if(l_ear.slot_flags & SLOT_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				equip_to_slot_if_possible(O, slot_r_ear, TRUE, FALSE, FALSE)
			W.equipped(src, slot)
			update_inv_ears(redraw_mob)

		if(slot_r_ear)
			src.r_ear = W
			if(r_ear.slot_flags & SLOT_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				equip_to_slot_if_possible(O, slot_l_ear, TRUE, FALSE, FALSE)
			W.equipped(src, slot)
			update_inv_ears(redraw_mob)
		if(slot_glasses)
			src.glasses = W
			W.equipped(src, slot)
			update_inv_glasses(redraw_mob)
		if(slot_gloves)
			src.gloves = W
			W.equipped(src, slot)
			update_inv_gloves(redraw_mob)
		if(slot_head)
			src.head = W
			if(head.flags_inv & (BLOCKHAIR|BLOCKHEADHAIR|HIDEMASK))
				update_hair(redraw_mob)	//rebuild hair
				update_inv_ears(0)
				update_inv_wear_mask(0)
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, slot)
			update_inv_head(redraw_mob)
		if(slot_shoes)
			src.shoes = W
			W.equipped(src, slot)
			update_inv_shoes(redraw_mob)
		if(slot_wear_suit)
			src.wear_suit = W
			if(wear_suit.flags_inv & HIDESHOES)
				update_inv_shoes(0)
			W.equipped(src, slot)
			update_inv_wear_suit(redraw_mob)
		if(slot_w_uniform)
			src.w_uniform = W
			W.equipped(src, slot)
			update_inv_w_uniform(redraw_mob)
		if(slot_l_store)
			src.l_store = W
			W.equipped(src, slot)
			update_inv_pockets(redraw_mob)
		if(slot_r_store)
			src.r_store = W
			W.equipped(src, slot)
			update_inv_pockets(redraw_mob)
		if(slot_s_store)
			src.s_store = W
			W.equipped(src, slot)
			update_inv_s_store(redraw_mob)
		if(slot_in_backpack)
			if(src.get_active_hand() == W)
				src.remove_from_mob(W)
			W.forceMove(src.back)
		if(slot_accessory_buffer)
			var/obj/item/clothing/under/uniform = src.w_uniform
			uniform.attackby(W,src)
		else
			src << SPAN_DANGER("You are trying to eqip this item to an unsupported inventory slot. If possible, please write a ticket with steps to reproduce. Slot was: [slot]")
			return

	if(!(slot in list(slot_in_backpack, slot_accessory_buffer)))
		W.screen_loc = find_inv_position(slot)
	W.layer = ABOVE_HUD_LAYER
	W.plane = ABOVE_HUD_PLANE

	if(W.action_button_name)
		update_action_buttons()

	return 1

//Checks if a given slot can be accessed at this time, either to equip or unequip I
/mob/living/carbon/human/slot_is_accessible(var/slot, var/obj/item/I, mob/user=null)
	var/obj/item/covering = null
	var/check_flags = 0

	switch(slot)
		if(slot_wear_mask)
			covering = src.head
			check_flags = FACE
		if(slot_glasses)
			covering = src.head
			check_flags = EYES
		if(slot_l_ear, slot_r_ear, )
			covering = src.head
		if(slot_gloves, slot_w_uniform)
			covering = src.wear_suit

	if(covering && (covering.item_flags & COVER_PREVENT_MANIPULATION) && (covering.body_parts_covered & (I.body_parts_covered|check_flags)))
		user << SPAN_WARNING("\The [covering] is in the way.")
		return 0

	if (!has_organ_for_slot(slot))
		return FALSE

	return 1

/mob/living/carbon/human/get_equipped_item(var/slot)
	switch(slot)
		if(slot_back)       return back
		if(slot_legcuffed)  return legcuffed
		if(slot_handcuffed) return handcuffed
		if(slot_l_store)    return l_store
		if(slot_r_store)    return r_store
		if(slot_wear_mask)  return wear_mask
		if(slot_l_hand)     return l_hand
		if(slot_r_hand)     return r_hand
		if(slot_wear_id)    return wear_id
		if(slot_glasses)    return glasses
		if(slot_gloves)     return gloves
		if(slot_head)       return head
		if(slot_shoes)      return shoes
		if(slot_belt)       return belt
		if(slot_wear_suit)  return wear_suit
		if(slot_w_uniform)  return w_uniform
		if(slot_s_store)    return s_store
		if(slot_l_ear)      return l_ear
		if(slot_r_ear)      return r_ear
	return ..()

/mob/living/carbon/human/get_equipped_items(var/include_carried = 0)
	var/list/items = new/list()

	if(back) items += back
	if(belt) items += belt
	if(l_ear) items += l_ear
	if(r_ear) items += r_ear
	if(glasses) items += glasses
	if(gloves) items += gloves
	if(head) items += head
	if(shoes) items += shoes
	if(wear_id) items += wear_id
	if(wear_mask) items += wear_mask
	if(wear_suit) items += wear_suit
	if(w_uniform) items += w_uniform

	if(include_carried)
		if(slot_l_hand)     items += l_hand
		if(slot_r_hand)     items += r_hand
		if(slot_l_store)    items += l_store
		if(slot_r_store)    items += r_store
		if(slot_legcuffed)  items += legcuffed
		if(slot_handcuffed) items += handcuffed
		if(slot_s_store)    items += s_store

	return items
