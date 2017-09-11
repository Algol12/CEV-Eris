
/obj/item/weapon/grab/proc/inspect_organ(mob/living/carbon/human/H, mob/user, var/target_zone)

	var/obj/item/organ/external/E = H.get_organ(target_zone)

	if(!E || E.is_stump())
		user << SPAN_NOTICE("[H] is missing that bodypart.")
		return

	user.visible_message(SPAN_NOTICE("[user] starts inspecting [affecting]'s [E.name] carefully."))
	if(!do_mob(user,H, 10))
		user << SPAN_NOTICE("You must stand still to inspect [E] for wounds.")
	else if(E.wounds.len)
		user << SPAN_WARNING("You find [E.get_wounds_desc()]")
	else
		user << SPAN_NOTICE("You find no visible wounds.")

	user << SPAN_NOTICE("Checking bones now...")
	if(!do_mob(user, H, 20))
		user << SPAN_NOTICE("You must stand still to feel [E] for fractures.")
	else if(E.status & ORGAN_BROKEN)
		user << "<span class='warning'>The [E.encased ? E.encased : "bone in the [E.name]"] moves slightly when you poke it!</span>"
		H.custom_pain("Your [E.name] hurts where it's poked.")
	else
		user << "<span class='notice'>The [E.encased ? E.encased : "bones in the [E.name]"] seem to be fine.</span>"

	user << SPAN_NOTICE("Checking skin now...")
	if(!do_mob(user, H, 10))
		user << SPAN_NOTICE("You must stand still to check [H]'s skin for abnormalities.")
	else
		var/bad = 0
		if(H.getToxLoss() >= 40)
			user << SPAN_WARNING("[H] has an unhealthy skin discoloration.")
			bad = 1
		if(H.getOxyLoss() >= 20)
			user << SPAN_WARNING("[H]'s skin is unusaly pale.")
			bad = 1
		if(E.status & ORGAN_DEAD)
			user << SPAN_WARNING("[E] is decaying!")
			bad = 1
		if(!bad)
			user << SPAN_NOTICE("[H]'s skin is normal.")

/obj/item/weapon/grab/proc/jointlock(mob/living/carbon/human/target, mob/attacker, var/target_zone)
	if(state < GRAB_AGGRESSIVE)
		attacker << SPAN_WARNING("You require a better grab to do this.")
		return

	var/obj/item/organ/external/organ = target.get_organ(check_zone(target_zone))
	if(!organ || organ.dislocated == -1)
		return

	attacker.visible_message("<span class='danger'>[attacker] [pick("bent", "twisted")] [target]'s [organ.name] into a jointlock!</span>")
	var/armor = target.run_armor_check(target, "melee")
	if(armor < 2)
		target << SPAN_DANGER("You feel extreme pain!")
		affecting.adjustHalLoss(Clamp(0, 60-affecting.halloss, 30)) //up to 60 halloss

/obj/item/weapon/grab/proc/attack_eye(mob/living/carbon/human/target, mob/living/carbon/human/attacker)
	if(!istype(attacker))
		return

	var/datum/unarmed_attack/attack = attacker.get_unarmed_attack(target, "eyes")

	if(!attack)
		return
	if(state < GRAB_NECK)
		attacker << SPAN_WARNING("You require a better grab to do this.")
		return
	for(var/obj/item/protection in list(target.head, target.wear_mask, target.glasses))
		if(protection && (protection.body_parts_covered & EYES))
			attacker << SPAN_DANGER("You're going to need to remove the eye covering first.")
			return
	if(!target.has_eyes())
		attacker << SPAN_DANGER("You cannot locate any eyes on [target]!")
		return

	attacker.attack_log += text("\[[time_stamp()]\] <font color='red'>Attacked [target.name]'s eyes using grab ([target.ckey])</font>")
	target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had eyes attacked by [attacker.name]'s grab ([attacker.ckey])</font>")
	msg_admin_attack("[key_name(attacker)] attacked [key_name(target)]'s eyes using a grab action.")

	attack.handle_eye_attack(attacker, target)

/obj/item/weapon/grab/proc/headbut(mob/living/carbon/human/target, mob/living/carbon/human/attacker)
	if(!istype(attacker))
		return
	if(target.lying)
		return
	attacker.visible_message(SPAN_DANGER("[attacker] thrusts \his head into [target]'s skull!"))

	var/damage = 20
	var/obj/item/clothing/hat = attacker.head
	if(istype(hat))
		damage += hat.force * 3

	var/armor = target.run_armor_check("head", "melee")
	target.apply_damage(damage, BRUTE, "head", armor)
	attacker.apply_damage(10, BRUTE, "head", attacker.run_armor_check("head", "melee"))

	if(!armor && target.headcheck("head") && prob(damage))
		target.apply_effect(20, PARALYZE)
		target.visible_message(SPAN_DANGER("[target] [target.species.knockout_message]"))

	playsound(attacker.loc, "swing_hit", 25, 1, -1)
	attacker.attack_log += text("\[[time_stamp()]\] <font color='red'>Headbutted [target.name] ([target.ckey])</font>")
	target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Headbutted by [attacker.name] ([attacker.ckey])</font>")
	msg_admin_attack("[key_name(attacker)] has headbutted [key_name(target)]")

	attacker.drop_from_inventory(src)
	src.loc = null
	qdel(src)
	return

/obj/item/weapon/grab/proc/dislocate(mob/living/carbon/human/target, mob/living/attacker, var/target_zone)
	if(state < GRAB_NECK)
		attacker << SPAN_WARNING("You require a better grab to do this.")
		return
	if(target.grab_joint(attacker, target_zone))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		return

/obj/item/weapon/grab/proc/pin_down(mob/target, mob/attacker)
	if(state < GRAB_AGGRESSIVE)
		attacker << SPAN_WARNING("You require a better grab to do this.")
		return
	if(force_down)
		attacker << SPAN_WARNING("You are already pinning [target] to the ground.")

	attacker.visible_message(SPAN_DANGER("[attacker] starts forcing [target] to the ground!"))
	if(do_after(attacker, 20, progress=0) && target)
		last_action = world.time
		attacker.visible_message(SPAN_DANGER("[attacker] forces [target] to the ground!"))
		apply_pinning(target, attacker)

/obj/item/weapon/grab/proc/apply_pinning(mob/target, mob/attacker)
	force_down = 1
	target.Weaken(3)
	target.lying = 1
	step_to(attacker, target)
	attacker.set_dir(EAST) //face the victim
	target.set_dir(SOUTH) //face up

/obj/item/weapon/grab/proc/devour(mob/target, mob/user)
	var/can_eat
	if((FAT in user.mutations) && issmall(target))
		can_eat = 1
	else
		var/mob/living/carbon/human/H = user
		if(istype(H) && H.species.gluttonous && (iscarbon(target) || isanimal(target)))
			if(H.species.gluttonous == GLUT_TINY && (target.mob_size <= MOB_TINY) && !ishuman(target)) // Anything MOB_TINY or smaller
				can_eat = 1
			else if(H.species.gluttonous == GLUT_SMALLER && (H.mob_size > target.mob_size)) // Anything we're larger than
				can_eat = 1
			else if(H.species.gluttonous == GLUT_ANYTHING) // Eat anything ever
				can_eat = 2

	if(can_eat)
		var/mob/living/carbon/attacker = user
		user.visible_message(SPAN_DANGER("[user] is attempting to devour [target]!"))
		if(can_eat == 2)
			if(!do_mob(user, target, 30)) return
		else
			if(!do_mob(user, target, 100)) return
		user.visible_message(SPAN_DANGER("[user] devours [target]!"))
		admin_attack_log(attacker, target, "Devoured.", "Was devoured by.", "devoured")
		target.loc = user
		attacker.stomach_contents.Add(target)
		qdel(src)