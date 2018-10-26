/*
	The blob is a horrible acidic slime creature that eats through airlocks and expands infinitely.
	The rate of expansion slows down as it grows, so it is ultimately soft-capped

	Its attacks deal light burn damage, but spam many hits. They deal a lot of damage by splashing acid
	onto victims, allowing acidproof gear to provide some good protection

	Blobs are very vulnerable to fire and lasers. Flamethrower is the recommended weapon, and
	In an emergency, a plasma canister and a lighter will bring a quick end to a blob
*/

/datum/storyevent/blob
	id = "blob"
	name = "Blob"


	event_type = /datum/event/blob
	event_pools = list(EVENT_LEVEL_MAJOR = POOL_THRESHOLD_MAJOR*1.2)
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_NEGATIVE)
//============================================

/datum/event/blob
	announceWhen	= 12

	var/obj/effect/blob/core/Blob

/datum/event/blob/announce()
	level_seven_announcement()

/datum/event/blob/start()
	var/area/A = random_ship_area(TRUE)
	var/turf/T = A.random_space()
	if(!T)
		log_and_message_admins("Blob failed to find a viable turf.")
		kill()
		return

	log_and_message_admins("Blob spawned at \the [get_area(T)]", location = T)
	Blob = new /obj/effect/blob/core(T)
	for(var/i = 1; i < rand(3, 4), i++)
		Blob.Process()

/datum/event/blob/tick()
	if(!Blob || !Blob.loc)
		Blob = null
		kill()
		return
	if(IsMultiple(activeFor, 3))
		Blob.Process()


//===============================================

/*
	Code for how the blob functions
	Nanako fixed this mess in October 2018
*/
/obj/effect/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob"
	var/icon_scale = 1.0
	light_range = 3
	desc = "Some blob creature thingy"
	density = FALSE //Normal blobs can be walked over, but it's not a good idea

	opacity = 0
	anchored = 1
	mouse_opacity = 2

	var/maxHealth = 30
	var/health = 1
	var/brute_resist = 1.5
	var/fire_resist = 0.75
	var/expandType = /obj/effect/blob

	//We will periodically update and track neighbors in two lists:
	//One which contains all blobs in cardinal directions, and one which contains all cardinal turfs that dont have blobs
	var/list/blob_neighbors = list()
	var/list/non_blob_neighbors = list()
	var/obj/effect/blob/core/core

	var/obj/effect/blob/parent
	var/active = FALSE

	//World time when we're allowed to expand next.
	//Expansion gets slower as the blob gets farther away from the origin core
	var/next_expansion = 0
	var/coredist = 1
	var/dist_time_scaling = 1.5

/obj/effect/blob/New(loc, var/obj/effect/blob/_parent)
	if (_parent)
		parent = _parent
		core = parent.core
		coredist = max(1,get_dist(src, core))

		//Accounting for zlevel distance
		if (src.z != core.z)
			coredist += (abs(z - core.z)*3)

		health += (maxHealth*0.5) - coredist
	update_icon()
	set_awake()


	//Random rotation for blobs, as well as larger sizing for some
	var/rot = pick(list(0, 90, 180, -90))
	var/matrix/M = matrix()
	M.Turn(rot)
	M.Scale(icon_scale)
	transform = M
	return ..(loc)

/obj/effect/blob/Destroy()
	STOP_PROCESSING(SSobj, src)
	wake_neighbors()
	return ..()

/obj/effect/blob/CanPass(var/atom/mover)
	//No letting projectiles through
	if (istype(mover, /obj/item/projectile))
		return FALSE

	//But mobs can walk over the nondense ones.
	return ..()

/obj/effect/blob/proc/update_neighbors()
	blob_neighbors = list()
	non_blob_neighbors = list()
	var/list/turfs = cardinal_turfs(src)
	for (var/t in turfs)

		var/turf/T = t
		var/turf/U = get_connecting_turf(T)//This handles Zlevel stuff
		//If the target turf connects to another across Zlevels, U will hold the destination
		var/obj/effect/blob/B = (locate(/obj/effect/blob/) in U)
		//We check for existing blobs in the destination
		if (B)
			blob_neighbors.Add(B)
		else
			//But we add the origin to our neighbors if there isnt a blob
			//Blob spawning code will handle making a new blob transition the zlevel
			non_blob_neighbors.Add(T)



/*************************************************
	Basic blob processing. Every tick we will update our neighbors, try to expand, etc
**************************************************/
/obj/effect/blob/Process()

	//Shouldn't happen, but maybe a process tick was still queued up when we stopped
	if (!active)
		return PROCESS_KILL

	//Heal ourselves
	regen()


	if (world.time >= next_expansion)
		//Update our neighbors. This may cause us to stop processing
		update_neighbors()



		//Okay if we're still active then we maybe have some expanding to do
		if (health >= maxHealth && non_blob_neighbors.len)
			//We will attempt to expand into only one of the possible nearby tiles
			expand(pick(non_blob_neighbors))


		//Maybe there are mobs in our tile we still need to melt
		if (!attack_mobs())
			//If not, try to go to sleep
			set_idle()

		//Another active check here
		if (!active)
			return PROCESS_KILL

		set_expand_time()


/obj/effect/blob/proc/regen()
	if (core && !(QDELETED(core)))
		health = min(health + 2, maxHealth)
	else
		core = null
		//When the core is gone, the blob starts dying
		//The closer it was to the core, the faster it dies. So death spreads out radially
		take_damage((1.0 / coredist))
	update_icon()

/*
	The blob is allowed to grow forever, there is no upper limit to its size
	However, the farther away each segment is from the core, the longer it must rest between expansions
*/
/obj/effect/blob/proc/set_expand_time()
	if (core && !(QDELETED(core)))
		next_expansion = world.time + ((1 SECONDS) * (dist_time_scaling ** coredist))
	else
		//If the core is gone, no more expansion
		next_expansion = INFINITY




/*
	TO minimise performance costs at massive sizes, blobs will go to sleep once they're no longer at the
	edge or relevant.
	If a blob finds itself surrounded on all sides by other blobs, and it is at full health, it has nothing to do
*/
/obj/effect/blob/proc/set_idle()
	if (!active)
		return

	if (blob_neighbors.len == 4) //We must have a full list of blobneighbors
		if (health >= maxHealth) //We must be at full health
			if (core && !(QDELETED(core)))//We must have a living core
				if (!attackable_mobs_in_turf())
					STOP_PROCESSING(SSobj, src)
					active = FALSE


/obj/effect/blob/proc/attackable_mobs_in_turf()
	for (var/mob/living/L in loc)
		if (L.stat != DEAD)
			return TRUE

	for (var/obj/mecha/M in loc)
		return TRUE

	return FALSE

/*
	Wake up the blob and make it start processing again.
	This will happen when any neighboring blob is killed
*/
/obj/effect/blob/proc/set_awake()
	if (active)
		return

	START_PROCESSING(SSobj, src)
	active = TRUE
	set_expand_time()


/obj/effect/blob/proc/wake_neighbors()
	update_neighbors()

	//Spawn it off so this part will trigger after we're qdeleted
	spawn()
		for (var/obj/effect/blob/B in blob_neighbors)
			B.set_awake()


/obj/effect/blob/ex_act(var/severity)
	switch(severity)
		if(1)
			take_damage(rand(100, 120) / brute_resist)
		if(2)
			take_damage(rand(60, 100) / brute_resist)
		if(3)
			take_damage(rand(20, 60) / brute_resist)


/obj/effect/blob/fire_act()
	take_damage(rand(20, 60) / fire_resist)

/obj/effect/blob/update_icon()
	var/healthpercent = health / maxHealth
	if(healthpercent > 0.5)
		icon_state = "blob"
	else
		icon_state = "blob_damaged"

	//Blob gradually fades out as it's damaged.
	alpha = 255 * healthpercent

/obj/effect/blob/proc/take_damage(var/damage)
	if (damage > 0)
		health -= damage

		if (damage >= 5)
			//Threshold reduces sound spam
			playsound(loc, 'sound/effects/attackblob.ogg', 50, 1)
		if(health < 0)
			playsound(loc, 'sound/effects/splat.ogg', 50, 1)
			qdel(src)
		else
			update_icon()
			wake_neighbors()







/*********************************
	EXPANDING!
**********************************/
//Changes by Nanako, 14th october 2018
//Blob now deals vastly reduced damage to walls and windows, but vastly increased damage to doors
/obj/effect/blob/proc/expand(var/turf/T)
	if(istype(T, /turf/unsimulated/) || istype(T, /turf/space) || (istype(T, /turf/simulated/mineral) && T.density))
		return
	if(istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/SW = T
		SW.take_damage(rand(0,3))
		return
	var/obj/structure/girder/G = locate() in T
	if(G)
		G.take_damage(100)

		//No return here because a girder is porous, we can expand past it
	var/obj/structure/window/W = locate() in T
	if(W)
		W.take_damage(rand(0,7)) //Reinforced windows have 6 resistance so this will rarely damage them
		return
	var/obj/structure/grille/GR = locate() in T
	if(GR)
		qdel(GR)
		return
	for(var/obj/machinery/door/D in T)
		if(D.density)
			D.take_damage(100)
			//Blob eats through doors VERY quickly
			return
	var/obj/structure/foamedmetal/F = locate() in T
	if(F)
		qdel(F)
		return
	var/obj/structure/inflatable/I = locate() in T
	if(I)
		I.deflate(1)
		return

	var/obj/vehicle/V = locate() in T
	if(V)
		V.ex_act(2)
		return
	var/obj/machinery/bot/B = locate() in T
	if(B)
		B.ex_act(2)
		return
	var/obj/mecha/M = locate() in T
	if(M)
		M.visible_message(SPAN_DANGER("The blob attacks \the [M]!"))
		M.take_damage(40)
		return

	T.Enter(src) //This should make them travel down stairs

	// Above things, we destroy completely and thus can use locate. Mobs are different.
	for(var/mob/living/L in T)
		if(L.stat == DEAD)
			continue
		L.visible_message(SPAN_DANGER("The blob attacks \the [L]!"), SPAN_DANGER("The blob attacks you!"))
		playsound(loc, 'sound/effects/attackblob.ogg', 50, 1)
		L.take_organ_damage(burn = rand(15, 25))
		return

	//We'll occasionally spawn shield tiles instead of normal blobs
	var/obj/effect/blob/child
	if (prob(5))
		child = new /obj/effect/blob/shield(loc, src)
	else
		child = new expandType(loc, src)
	//Spawn the child blob and move it into the new tile
	spawn(1)
		if (child && !(QDELETED(child)))
			child.anchored = FALSE
			child.forceMove(T)
			child.anchored = TRUE
			//Often, two blobs will attempt to move into the same tile at about the same time
			for (var/obj/effect/blob/Bl in child.loc)
				if (Bl != child)
					qdel(B) //Lets make sure we don't get doubleblobs

/*******************
	BLOB ATTACKING
********************/
//Blobs will do horrible things to any mobs they share a tile with
//Returns true if any mob was damaged, false if not
/obj/effect/blob/proc/attack_mobs()
	for (var/mob/living/L in loc)
		if(L.stat == DEAD)
			continue
		L.visible_message(SPAN_DANGER("The blob attacks \the [L]!"), SPAN_DANGER("The blob attacks you!"))
		playsound(loc, 'sound/effects/attackblob.ogg', 50, 1)
		L.take_organ_damage(burn = rand_between(0.5, 2.5))

		//In addition to the flat damage above, we will also splash a small amount of acid on the target
		//This allows them to wear acidproof gear to resist it
		if (iscarbon(L))
			var/datum/reagents/R = new /datum/reagents(4, null)
			R.add_reagent("sacid", rand_between(0.8,4))
			R.trans_to(L, R.total_volume)
			qdel(R)

		return TRUE

	var/obj/mecha/M = (locate(/obj/mecha) in loc)
	if(M)
		M.visible_message(SPAN_DANGER("The blob attacks \the [M]!"))
		M.take_damage(5)
		return TRUE

	//If we get here, nobody was harmed
	return FALSE


//Stepping on a blob is bad for your health.
//When walked over, the blob will wake up and attack whoever stepped on it
//Since it's awake, it will keep attacking them every process call until they leave or die
/obj/effect/blob/Crossed()
	set_awake()
	attack_mobs()

/*******************
	BLOB DEFENSE
********************/
/obj/effect/blob/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return

	switch(Proj.damage_type)
		if(BRUTE)
			take_damage(Proj.damage / brute_resist)
		if(BURN)
			take_damage(Proj.damage / fire_resist)
	return 0

/obj/effect/blob/attackby(var/obj/item/weapon/W, var/mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(W.force && !(W.flags & NOBLUDGEON))
		visible_message("<span class='danger'>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]</span>")
		var/damage = 0
		switch(W.damtype)
			if("fire")
				damage = (W.force / fire_resist)
				if(istype(W, /obj/item/weapon/tool/weldingtool))
					playsound(loc, 'sound/items/Welder.ogg', 100, 1)
			if("brute")
				damage = (W.force / brute_resist)

		take_damage(damage)
		return 1
	return ..()

/obj/effect/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_core"
	maxHealth = 200
	health = 200
	brute_resist = 4
	fire_resist = 2
	density = TRUE
	icon_scale = 1.2

	expandType = /obj/effect/blob/shield


/obj/effect/blob/core/New()
	core = src //It is its own core
	..()

/obj/effect/blob/core/update_icon()
	return

//When the core dies, wake up all our sub-blobs so they can slowly die too
/obj/effect/blob/core/Destroy()
	for (var/obj/effect/blob/B in world)
		if (B == src)
			continue
		if (B.core == src)
			B.core = null
			B.set_awake()
	return ..()



/obj/effect/blob/shield
	name = "strong blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_idle"
	desc = "Some blob creature thingy"
	maxHealth = 180
	health = 180
	brute_resist = 2
	fire_resist = 1
	density = TRUE
	icon_scale = 1.2

/obj/effect/blob/shield/update_icon()
	var/healthpercent = health / maxHealth
	if(healthpercent > 0.6)
		icon_state = "blob_idle"
	else if(healthpercent > 0.3)
		icon_state = "blob"
	else
		icon_state = "blob_damaged"



	//Blob gradually fades out as it's damaged.
	alpha = 255 * healthpercent


