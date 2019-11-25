/obj/item/weapon/oddity/secdocs
	name = "science data"
	desc = "Folder contains some papers with important science data."
	icon = 'icons/obj/items.dmi'
	icon_state = "scifolder0"
	price_tag = 5000

	oddity_stats = list(
		STAT_COG = 5,
		STAT_VIG = 5,
	)

	var/static/inv_spawn_count = 3

/obj/item/weapon/oddity/secdocs/Initialize()
	icon_state = "scifolder[rand(0,3)]"
	name = pick("Atractor fields theory",
				"World lines theory",
				"Outside context problem evidence",
				"Use of self-learning AI for public administration",
				"Evidence of time travel related changes in history",
				"Geograpfy of non existent cyties",
				"Production of Alliance nanomachines",
				"Known S.A.U. equipment specifications",
				"Known access points to Discordia",
				"The Door phenomenon",
				"Paralell world related mutations",
				"Mass hallucinations or a breach from another world?",
				"Ironhammer budget: evidence of S.A.U. overfund",
				"Real reason of One Star fall",
				"Connection between One Star and dead alien civilizations, are we next?",
				"Unknown device blueprints")
	. = ..()
	var/mob/living/carbon/human/owner = loc
	if(istype(owner))
		var/chosen_stat = pick(oddity_stats)
		var/stat_change = rand(2, oddity_stats[chosen_stat])
		owner.stats.changeStat(chosen_stat, stat_change)
		claim(owner)
		to_chat(owner, SPAN_NOTICE("You have valuable science data on your person. It is essential that you do not let it fall into the wrong hands."))

/hook/roundstart/proc/place_docs()
	var/list/L = list()
	for(var/obj/landmark/storyevent/midgame_stash_spawn/S in landmarks_list)
		L.Add(S)

	L = shuffle(L)

	if(L.len < 3)
		warning("Failed to place secret documents: not enough landmarks.")
		return FALSE

	for(var/i in 1 to 3)
		new /obj/item/weapon/oddity/secdocs(L[i].get_loc())

	return TRUE
