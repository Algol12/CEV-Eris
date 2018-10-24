/datum/reagent/toxin/blattedin/touch_mob(var/mob/living/carbon/superior_animal/roach/bug, amount)
	if(istype(bug))
		if(bug.stat == DEAD)
			if((bug.blattedin_revives_left >= 0) || prob(70))//Roaches sometimes can come back to life from healing vapors
				return
			bug.blattedin_revives_left = max(0, bug.blattedin_revives_left - 1)
			bug.rejuvenate()
		bug.heal_organ_damage(amount * 0.5)
	else
		..()