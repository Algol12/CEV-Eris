/datum/objective/assassinate/marshal
	var/bad_info = FALSE

/datum/objective/assassinate/marshal/New()
	.=..()
	bad_info = prob(15) //The marshal has a chance to be given non-antags as targets
	//To discourage metagaming, and encourage investigation before action

/datum/objective/assassinate/marshal/get_panel_entry()
	var/target = src.target ? "[src.target.current.real_name], the [src.target.assigned_role]" : "no_target"
	return "You are after the fugitive <a href='?src=\ref[src];switch_target=1'>[target]</a>."

/datum/objective/assassinate/marshal/get_info()
	if(target)
		return "(target was [target.name])"

/datum/objective/assassinate/marshal/marshal/update_explanation()
	var/target_role = ""
	if(target && target.antagonist.len)
		for(var/datum/antagonist/A in target.antagonist)
			if(!A.outer)
				target_role = A.role_text
				break

	if(target && target.current)
		explanation_text = "Find and take down the [target_role]."
	else
		explanation_text = "Target has not arrived today. Is it a coincidence?"

/datum/objective/assassinate/marshal/get_targets_list()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner &&\
		 ishuman(possible_target.current) &&\
		  (possible_target.current.stat != 2) &&\
		   (bad_info || player_is_ship_antag(possible_target)))
			possible_targets.Add(possible_target)
	return possible_targets


/datum/objective/assassinate/marshal/check_completion()
	//If you got bad info then you don't need to kill your target
	if (bad_info)
		return TRUE
		//Possible future todo: Punish marshal for not investigating and killing an innocent person based on bad info
	return ..()