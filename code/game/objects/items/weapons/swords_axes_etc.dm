/* Weapons
 * Contains:
 *		Sword
 *		Classic Baton
 */

/*
 * Classic Baton
 */
/obj/item/weapon/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_BELT
	force = WEAPON_FORCE_PAINFULL
	structure_damage_factor = 1.3

/obj/item/weapon/melee/classic_baton/attack(mob/M as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << SPAN_WARNING("You club yourself over the head.")
		user.Weaken(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2 * force, BRUTE, BP_HEAD)
		else
			user.take_organ_damage(2 * force)
		return
	return ..()

//Telescopic baton
/obj/item/weapon/melee/telebaton
	name = "telescopic baton"
	desc = "A compact yet rebalanced personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = "telebaton_0"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	force = 3
	var/on = 0
	structure_damage_factor = 1.3


/obj/item/weapon/melee/telebaton/attack_self(mob/user as mob)
	on = !on
	if(on)
		user.visible_message(
			SPAN_WARNING("With a flick of their wrist, [user] extends their telescopic baton."),
			SPAN_WARNING("You extend the baton."),
			"You hear an ominous click."
		)
		icon_state = "telebaton_1"
		item_state = "telebaton_1"
		update_wear_icon()
		w_class = ITEM_SIZE_NORMAL
		force = WEAPON_FORCE_PAINFULL//quite robust
		attack_verb = list("smacked", "struck", "slapped")
	else
		user.visible_message(
			SPAN_NOTICE("\The [user] collapses their telescopic baton."),
			SPAN_NOTICE("You collapse the baton."),
			"You hear a click."
		)
		icon_state = "telebaton_0"
		item_state = "telebaton_0"
		update_wear_icon()
		w_class = ITEM_SIZE_SMALL
		force = 3//not so robust now
		attack_verb = list("hit", "punched")

	playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
	add_fingerprint(user)

	if(blood_overlay && blood_DNA && (blood_DNA.len >= 1)) //updates blood overlay, if any
		overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

		var/icon/I = new /icon(src.icon, src.icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
		blood_overlay = I

		overlays += blood_overlay

	return

/obj/item/weapon/melee/telebaton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		if ((CLUMSY in user.mutations) && prob(50))
			user << SPAN_WARNING("You club yourself over the head.")
			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2 * force, BRUTE, BP_HEAD)
			else
				user.take_organ_damage(2*force)
			return
		if(..())
			//playsound(src.loc, "swing_hit", 50, 1, -1)
			return
	else
		return ..()
