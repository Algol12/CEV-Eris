/obj/parallax
	name = "parallax"
	mouse_opacity = 0
	blend_mode = BLEND_MULTIPLY
	plane = PLANE_SPACE_PARALLAX
//	invisibility = 101
	anchored = 1
	var/mob/owner
	var/image/image

	New(mob/M)
		owner = M
		owner.parallax = src
		image = image('icons/parallax.dmi', src, "space")
		overlays += image
		update()
		..(null)

	proc/update()
		if(!owner || !owner.client)
			return
		var/turf/T = get_turf(owner.client.eye)
		screen_loc = "CENTER:[-224-(T&&T.x)],CENTER:[-224-(T&&T.y)]"

/mob
	var/obj/parallax/parallax

/mob/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	. = ..()
	if(. && parallax)
		parallax.update()

/mob/forceMove(atom/destination, var/special_event, glide_size_override=0)
	. = ..()
	if(. && parallax)
		parallax.update()

/mob/Login()
	if(!parallax)
		parallax = new(src)
	client.screen += parallax
	..()
