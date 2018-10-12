//APC Damage is a mundane event that bluscreens some APCs in a radius
//It mainly exists for two purposes:
//1. To create some work for engineers
//2. To provide plausible deniability for a malfunctioning AI, so they can claim its not their doing when apcs break
/datum/storyevent/apc_damage
	id = "apc_dmg"
	name = "APC damage"

	event_type =/datum/event/apc_damage
	event_pools = list(EVENT_LEVEL_MUNDANE = POOL_THRESHOLD_MUNDANE)
	tags = list(TAG_DESTRUCTIVE, TAG_NEGATIVE)

//////////////////////////////////////////////////////////

/datum/event/apc_damage
	var/apcSelectionRange	= 25

/datum/event/apc_damage/start()
	var/obj/machinery/power/apc/A = acquire_random_apc()

	var/severity_range = 9

	for(var/obj/machinery/power/apc/apc in range(severity_range,A))
		if(is_valid_apc(apc))
			apc.emagged = 1
			apc.update_icon()

/datum/event/apc_damage/proc/acquire_random_apc()
	var/list/possibleEpicentres = list()
	var/list/apcs = list()

	for(var/obj/landmark/event/lightsout/newEpicentre in landmarks_list)
		possibleEpicentres += newEpicentre

	if(!possibleEpicentres.len)
		return

	var/epicentre = pick(possibleEpicentres)
	for(var/obj/machinery/power/apc/apc in range(epicentre,apcSelectionRange))
		if(is_valid_apc(apc))
			// Greatly reduce the chance for APCs in maintenance areas to be selected
			var/area/A = get_area(apc)
			if(!istype(A,/area/maintenance) || prob(50))
				apcs += apc

	if(!apcs.len)
		return

	return pick(apcs)

/datum/event/apc_damage/proc/is_valid_apc(var/obj/machinery/power/apc/apc)
	return !apc.is_critical && !apc.emagged && isOnPlayerLevel(apc)
