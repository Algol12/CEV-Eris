/datum/job

	//The name of the job
	var/title = "NOPE"
	var/list/access = list()              // Useful for servers which either have fewer players, so each person needs to fill more than one role, or servers which like to give more access, so players can't hide forever in their super secure departments (I'm looking at you, chemistry!)
	var/list/software_on_spawn = list()   // Defines the software files that spawn on tablets and labtops
	var/flag = 0 	                      // Bitflags for the job
	var/department_flag = 0
	var/faction = "None"	              // Players will be allowed to spawn in as jobs that are set to "Station"
	var/total_positions = 0               // How many players can be this job
	var/spawn_positions = 0               // How many players can spawn in as this job
	var/current_positions = 0             // How many players have this job
	var/supervisors = null                // Supervisors, who this person answers to directly
	var/selection_color = "#ffffff"       // Selection screen color
	var/list/alt_titles

	var/req_admin_notify                  // If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/department = null                 // Does this position have a department tag?
	var/head_position = 0                 // Is this position Command?
	var/minimum_character_age = 0
	var/ideal_character_age = 30
	var/create_record = 1                 // Do we announce/make records for people who spawn on this job?
	var/list/also_known_languages = list()// additional chance based languages to all jobs.

	var/account_allowed = 1				  // Does this job type come with a station account?
	var/economic_modifier = 2			  // With how much does this job modify the initial account amount?

	var/outfit_type                       // The outfit the employee will be dressed in, if any

	var/loadout_allowed = TRUE			  // Does this job allows loadout ?
	var/description = ""
	var/duties = ""
	var/loyalties = ""

	//Character stats modifers
	var/list/stat_modifiers = list()

/datum/job/proc/equip(var/mob/living/carbon/human/H, var/alt_title)
	var/decl/hierarchy/outfit/outfit = get_outfit()
	if(!outfit)
		return FALSE
	. = outfit.equip(H, title, alt_title)

/datum/job/proc/get_outfit(var/alt_title)
	if(alt_title && alt_titles)
		. = alt_titles[alt_title]
	. = . || outfit_type
	. = outfit_by_type(.)

/datum/job/proc/add_stats(var/mob/living/carbon/human/target)
	if(!ishuman(target))
		return FALSE
	for(var/name in src.stat_modifiers)
		target.stats.changeStat(name, stat_modifiers[name])

	return TRUE

/datum/job/proc/add_additiional_language(var/mob/living/carbon/human/target)
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/H = target

	if(!also_known_languages.len)
		return FALSE

	var/i

	for(i in also_known_languages)
		if(prob(also_known_languages[i]))
			H.add_language(i)

	return TRUE

/datum/job/proc/setup_account(var/mob/living/carbon/human/H)
	if(!account_allowed || (H.mind && H.mind.initial_account))
		return

	//give them an account in the station database
	var/species_modifier = (H.species ? economic_species_modifier[H.species.type] : 2)
	if(!species_modifier)
		species_modifier = economic_species_modifier[/datum/species/human]

	var/money_amount = one_time_payment(species_modifier)
	var/datum/money_account/M = create_account(H.real_name, money_amount, null)
	if(H.mind)
		var/remembered_info = ""
		remembered_info += "<b>Your account number is:</b> #[M.account_number]<br>"
		remembered_info += "<b>Your account pin is:</b> [M.remote_access_pin]<br>"
		remembered_info += "<b>Your account funds are:</b> $[M.money]<br>"

		if(M.transaction_log.len)
			var/datum/transaction/T = M.transaction_log[1]
			remembered_info += "<b>Your account was created:</b> [T.time], [T.date] at [T.source_terminal]<br>"
		H.mind.store_memory(remembered_info)

		H.mind.initial_account = M

	H << SPAN_NOTICE("<b>Your account number is: [M.account_number], your account pin is: [M.remote_access_pin]</b>")

/datum/job/proc/one_time_payment(var/custom_factor = 1)
	return (rand(5,50) + rand(5, 50)) * economic_modifier * custom_factor

// overrideable separately so AIs/borgs can have cardborg hats without unneccessary new()/qdel()
/datum/job/proc/equip_preview(mob/living/carbon/human/H, var/alt_title, var/datum/mil_branch/branch, var/additional_skips)
	var/decl/hierarchy/outfit/outfit = get_outfit(H, alt_title)
	if(!outfit)
		return FALSE
	. = outfit.equip(H, title, alt_title, OUTFIT_ADJUSTMENT_SKIP_POST_EQUIP|OUTFIT_ADJUSTMENT_SKIP_ID_PDA|additional_skips)

/datum/job/proc/get_access()
	return src.access.Copy()

/datum/job/proc/apply_fingerprints(var/mob/living/carbon/human/target)
	if(!istype(target))
		return 0
	for(var/obj/item/item in target.contents)
		apply_fingerprints_to_item(target, item)
	return 1
/*
//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	return (available_in_days(C) == 0) //Available in 0 days = available right now = player is old enough to play.

/datum/job/proc/available_in_days(client/C)
	if(C && config.use_age_restriction_for_jobs && isnull(C.holder) && isnum(C.player_age) && isnum(minimal_player_age))
		return max(0, minimal_player_age - C.player_age)
	return 0
*/
/datum/job/proc/apply_fingerprints_to_item(var/mob/living/carbon/human/holder, var/obj/item/item)
	item.add_fingerprint(holder,1)
	if(item.contents.len)
		for(var/obj/item/sub_item in item.contents)
			apply_fingerprints_to_item(holder, sub_item)

/datum/job/proc/is_position_available()
	return (current_positions < total_positions) || (total_positions == -1)

/datum/job/proc/is_restricted(var/datum/preferences/prefs, var/feedback)

	if(minimum_character_age && (prefs.age < minimum_character_age))
		to_chat(feedback, "<span class='boldannounce'>Not old enough. Minimum character age is [minimum_character_age].</span>")
		return TRUE

	return FALSE

//	Creates mannequin with equipment for current job and stores it for future reference
//	used for preview
//	You can use getflaticon(mannequin) to get icon out of it
/datum/job/proc/get_job_mannequin()
	if(!SSjob.job_mannequins[title])
		var/mob/living/carbon/human/dummy/mannequin/mannequin = get_mannequin("#job_icon_[title]")
		dress_mannequin(mannequin)

		SSjob.job_mannequins[title] = mannequin
	return SSjob.job_mannequins[title]

/datum/job/proc/get_description_blurb()
	var/job_desc = ""
	//Here's the actual content of the description
	if (description)
		job_desc += "<h1>Overview:</h1>"
		job_desc += "<hr>"
		job_desc += description
		job_desc += "<br>"

	if (duties)
		job_desc += "<h1>Duties:</h1>"
		job_desc += "<hr>"
		job_desc += duties
		job_desc += "<br>"

	if (loyalties)
		job_desc += "<h1>Loyalties:</h1>"
		job_desc += "<hr>"
		job_desc += loyalties
		job_desc += "<br>"

	return job_desc

/datum/job/proc/dress_mannequin(var/mob/living/carbon/human/dummy/mannequin/mannequin)
	mannequin.delete_inventory(TRUE)
	equip_preview(mannequin, additional_skips = OUTFIT_ADJUSTMENT_SKIP_BACKPACK)
