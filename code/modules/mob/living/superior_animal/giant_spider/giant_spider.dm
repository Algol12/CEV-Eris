//basic spider mob, these generally guard nests
/mob/living/carbon/superior_animal/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	pass_flags = PASSTABLE

	maxHealth = 200
	health = 200

	attack_sound = 'sound/weapons/spiderlunge.ogg'
	speak_emote = list("chitters")
	emote_see = list("chitters", "rubs its legs")
	speak_chance = 5

	move_to_delay = 6
	turns_per_move = 5
	see_in_dark = 10
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/xenomeat
	stop_automated_movement_when_pulled = 0

	melee_damage_lower = 15
	melee_damage_upper = 20

	var/poison_per_bite = 5
	var/poison_type = "toxin"

	faction = "spiders"
	var/busy = 0

/mob/living/carbon/superior_animal/giant_spider/New(var/location, var/atom/parent)
	get_light_and_color(parent)
	..()