/mob/living/simple_animal/hostile/roach
	name = "Kampfer Roach"
	desc = "A monstrous cockroach the size of a grown dog. These huge mutants can be everywhere where humans are, on ships, planets and stations."
	icon_state = "roach"
	icon_living = "roach"
	icon_dead = "roach_dead"
	speak_chance = 0
	turns_per_move = 3
	response_help = "pets the"
	response_disarm = "pushes aside"
	response_harm = "stamps on"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/roachmeat
	meat_amount = 2
	speed = 4
	maxHealth = 10
	health = 10

	mob_size = MOB_SMALL
	density = 0 //Swarming roaches! They also more robust that way.

	harm_intent_damage = 3
	melee_damage_lower = 1
	melee_damage_upper = 4
	attacktext = "bitten"
	attack_sound = 'sound/weapons/bite.ogg'

	faction = "roach"


/mob/living/simple_animal/hostile/roach/FindTarget()
	. = ..()
	if(.)
		custom_emote(1,"charges at [.]!")

/mob/living/simple_animal/hostile/roach/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(5))
			L.Weaken(3)
			L.visible_message(SPAN_DANGER("\the [src] knocks down \the [L]!"))

/mob/living/simple_animal/hostile/roach/tank
	name = "Panzer Roach"
	desc = "A monstrous cockroach the size of a huge dog. This one looks more robust than others."
	meat_amount = 4
	turns_per_move = 2
	maxHealth = 30
	health = 30

	mob_size = MOB_MEDIUM
	density = 1

/mob/living/simple_animal/hostile/roach/hunter
	name = "Jager Roach"
	desc = "A monstrous cockroach the size of a grown dog. This one have a bigger claws."
	meat_amount = 3
	turns_per_move = 2
	maxHealth = 15
	health = 15

	melee_damage_lower = 3
	melee_damage_upper = 10

/mob/living/simple_animal/hostile/roach/support
	name = "Seuche Roach"
	desc = "A monstrous cockroach the size of a grown dog. This one smells like hell and secrete strange vapors."
	meat_amount = 3
	turns_per_move = 4
	maxHealth = 20
	health = 20

	melee_damage_upper = 3

/mob/living/simple_animal/hostile/roach/fuhrer
	name = "Fuhrer Roach"
	desc = "A glorious leader of cockroaches. Literally Hitler."
	meat_amount = 5
	turns_per_move = 4
	maxHealth = 60
	health = 60

	melee_damage_lower = 3
	melee_damage_upper = 20


/mob/living/simple_animal/hostile/roach/support/New()
	..()
	create_reagents(100)

/mob/living/simple_animal/hostile/roach/support/proc/gas_attack()
	if(!reagents.has_reagent("blattedin", 20))
		return
	var/location = get_turf(src)
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	S.attach(location)
	S.set_up(src.reagents, src.reagents.total_volume, 0, location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		S.start()
	reagents.clear_reagents()
	return

/mob/living/simple_animal/hostile/roach/support/Life()
	..()
	reagents.add_reagent("blattedin", 1)
	if(reagents.has_reagent("blattedin", 20)&&prob(7))
		gas_attack()

/mob/living/simple_animal/hostile/roach/support/FindTarget()
	. = ..()
	if(.)
		custom_emote(1,"charges at [.] in clouds of poison!")
		gas_attack()
