//	Buckle handlers
//	They decide how atom will behave when staff buckled to it

/datum/movement_handler/buckle_handler/vehicle/DoMove(var/direction, var/mover)
	if(host.buckled_mob)
		if(host.buckled_mob.confused && prob(20)) //vehicles tend to keep moving in the same direction
			direction = turn(direction, pick(90, -90))
	..()
	return MOVEMENT_PROCEED

/datum/movement_handler/buckle_handler/vehicle/MayMove(var/mover, var/is_external)
	if(istype(host.loc, /turf/space))
		return MOVEMENT_STOP
	if(host.buckled_mob)
		if(handleDismount())
			return MOVEMENT_STOP
		if(is_external)
			return MOVEMENT_PROCEED
	
	return MOVEMENT_STOP
	
/datum/movement_handler/buckle_handler/wheelchair/DoMove(var/direction, var/mover)
	..()
	return MOVEMENT_PROCEED

/datum/movement_handler/buckle_handler/wheelchair/MayMove(var/mover, var/is_external)
	if(istype(host.loc, /turf/space))
		return MOVEMENT_STOP
	if(host.buckled_mob )
		if(handleDismount())
			return MOVEMENT_STOP
	if(is_external)
		return MOVEMENT_PROCEED
	return MOVEMENT_STOP

// Movement of a mob mounted by other mob (basically movement of the horse)
/datum/movement_handler/buckle_handler/mob
	expected_host_type = /mob
	var/mob/mob

/datum/movement_handler/buckle_handler/mob/New(var/host)
	..()
	src.mob = host

/datum/movement_handler/buckle_handler/mob/Destroy()
	mob = null
	. = ..()

/datum/movement_handler/buckle_handler/mob/basic/DoMove(var/direction, var/mover)
	if(mob.buckled_mob)
		mob.buckled_mob.DoMove(direction, mob, TRUE)
	..()
	// movement of mob will be handled in /datum/movement_handler/mob/movement
	return MOVEMENT_PROCEED

/datum/movement_handler/buckle_handler/mob/basic/MayMove(var/mover, var/is_external)
	if(mob.buckled_mob)
		if(handleDismount())
			return MOVEMENT_PROCEED
		if(is_external)
			//mob.canBeRidedBy(mob.buckled_mob) Add something like dat
			return MOVEMENT_STOP
	return MOVEMENT_PROCEED

/datum/movement_handler/buckle_handler/proc/handleDismount()
	var/dismount = FALSE
	if(get_turf(host.buckled_mob) != get_turf(host))
		dismount = TRUE
	if (isliving(host))
		if(ishuman(host.buckled_mob))
			var/mob/living/carbon/human/driver = host.buckled_mob
			var/obj/item/organ/external/l_arm = driver.get_organ(BP_L_ARM)
			var/obj/item/organ/external/r_arm = driver.get_organ(BP_R_ARM)
			var/obj/item/organ/external/l_leg = driver.get_organ(BP_L_LEG)
			var/obj/item/organ/external/r_leg = driver.get_organ(BP_R_LEG)
			if((!l_arm || l_arm.is_stump()) && (!r_arm || r_arm.is_stump()) || !(l_leg && r_leg))
				dismount = TRUE // if no arms or no legs we cant hold onto mob
	if(dismount)
		host.buckled_mob.visible_message(SPAN_WARNING("[host.buckled_mob] has fallen of \the [host]!"), SPAN_WARNING("You have fallen of \the [host]!"))
		host.buckled_mob.buckled.unbuckle_mob(host)
		DoMove(pick(cardinal), host.buckled_mob)
		return dismount
	return dismount