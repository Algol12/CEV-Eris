proc/create_new_xenomorph(alien_caste, target)

	target = get_turf(target)
	if(!target || !alien_caste) return

	var/mob/living/carbon/human/new_alien = new(target)
	new_alien.set_species("Xenomorph [alien_caste]")
	return new_alien

/mob/living/carbon/human/xdrone/New(var/new_loc)
	h_style = "Bald"
	defaultHUD = "Xenos"
	..(new_loc, "Xenomorph Drone")

/mob/living/carbon/human/xsentinel/New(var/new_loc)
	h_style = "Bald"
	defaultHUD = "Xenos"
	..(new_loc, "Xenomorph Sentinel")

/mob/living/carbon/human/xhunter/New(var/new_loc)
	h_style = "Bald"
	defaultHUD = "Xenos"
	..(new_loc, "Xenomorph Hunter")

/mob/living/carbon/human/xqueen/New(var/new_loc)
	h_style = "Bald"
	defaultHUD = "Xenos"
	..(new_loc, "Xenomorph Queen")
