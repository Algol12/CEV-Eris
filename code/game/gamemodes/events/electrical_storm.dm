/datum/storyevent/electrical_storm
	id = "elec_storm"
	name = "Electrical Storm"


	event_type = /datum/event/electrical_storm
	event_pools = list(EVENT_LEVEL_MUNDANE = POOL_THRESHOLD_MUNDANE,
	EVENT_LEVEL_MODERATE = POOL_THRESHOLD_MODERATE)

	tags = list(TAG_SCARY, TAG_TARGETED, TAG_NEGATIVE)

////////////////////////////////////////////////

/datum/event/electrical_storm
	var/lightsoutAmount	= 1
	var/lightsoutRange	= 25


/datum/event/electrical_storm/announce()
	command_announcement.Announce("An electrical storm has been detected in your area, please repair potential electronic overloads.", "Electrical Storm Alert")


/datum/event/electrical_storm/start()
	switch(severity)
		if (EVENT_LEVEL_MUNDANE)
			lightsoutAmount = 2
		if (EVENT_LEVEL_MODERATE)
			lightsoutAmount = 5
	var/list/epicentreList = list()

	var/list/possibleEpicentres = list()
	for(var/obj/landmark/event/lightsout/newEpicentre in landmarks_list)
		if(!newEpicentre in epicentreList)
			possibleEpicentres += newEpicentre

	for(var/i=1, i <= lightsoutAmount, i++)
		if(possibleEpicentres.len)
			var/picked = pick(possibleEpicentres)
			epicentreList += picked
			possibleEpicentres -= picked
		else
			break

	if(!epicentreList.len)
		return

	for(var/obj/landmark/epicentre in epicentreList)
		for(var/obj/machinery/power/apc/apc in range(epicentre,lightsoutRange))
			apc.overload_lighting()


/proc/lightsout(isEvent = 0, lightsoutAmount = 1,lightsoutRange = 25) //leave lightsoutAmount as 0 to break ALL lights
	if(isEvent)
		command_announcement.Announce("An Electrical storm has been detected in your area, please repair potential electronic overloads.","Electrical Storm Alert")

	if(lightsoutAmount)
		var/list/possibleEpicentres = list()
		for(var/obj/landmark/event/lightsout/newEpicentre in landmarks_list)
			possibleEpicentres += newEpicentre

		var/list/epicentreList = list()
		for(var/i=1,i<=lightsoutAmount,i++)
			if(possibleEpicentres.len)
				var/picked = pick(possibleEpicentres)
				epicentreList += picked
				possibleEpicentres -= picked
			else
				break

		if(!epicentreList.len)
			return

		for(var/obj/landmark/epicentre in epicentreList)
			for(var/obj/machinery/power/apc/apc in range(epicentre,lightsoutRange))
				apc.overload_lighting()

	else
		for(var/obj/machinery/power/apc/apc in SSmachines.machinery)
			apc.overload_lighting()

	return

