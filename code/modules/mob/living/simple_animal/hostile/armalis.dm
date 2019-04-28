/mob/living/simple_animal/armalis
	name = "Vox Armalis"
	desc = "In truth, this scares you."

	icon = 'icons/mob/armalis.dmi'
	icon_state = "armalis_naked"

	health = 125
	maxHealth = 125
	resistance = RESISTANCE_FRAGILE

	response_help   = "pats"
	response_disarm = "pushes"
	response_harm   = "hits"

	attacktext = "reaped"
	attack_sound = 'sound/effects/bamf.ogg'
	melee_damage_lower = 15
	melee_damage_upper = 20

	min_oxy = 0
	max_co2 = 0
	max_tox = 0

	speed = 2

	a_intent = I_HURT


/mob/living/simple_animal/armalis/armored
	icon_state = "armalis_armored"

	health = 175
	maxHealth = 175
	resistance = RESISTANCE_AVERAGE
	speed = 3