/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/monkey
	icon_state = "monkey"

/mob/living/carbon/human/monkey/New(var/new_loc)
	..(new_loc, "Monkey")

/mob/living/carbon/human/dummy/mannequin/Initialize()
	. = ..()
	GLOB.human_mob_list -= src
	delete_inventory()

/mob/living/carbon/human/dummy/mannequin/Life(dt)
	return // lol no

/mob/living/carbon/human/dummy/mannequin/fully_replace_character_name(var/oldname, var/newname)
	..(newname = "[newname] (mannequin)")
