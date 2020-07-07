/datum/breakdown
	var/name
	var/datum/sanity/holder

	var/icon_state
	var/breakdown_sound

	var/start_message_span
	var/list/start_messages
	var/list/end_messages

	var/duration = 30 MINUTES //by default
	var/end_time
	var/delay //delay time before it occurs, or updates. it must be used manually.

	var/has_objetives = FALSE //if demandsomet hing from you
	var/finished = FALSE //if the objetives were fulfilled.
	var/isight_reward = 5 //Amount of isight for fulfilling the objetives
	var/restore_sanity_pre
	var/restore_sanity_post
	var/is_negative = FALSE

/datum/breakdown/New(datum/sanity/S)
	..()
	holder = S

/datum/breakdown/Destroy()
	holder = null
	return ..()

/datum/breakdown/proc/can_occur()
	return !!name

/datum/breakdown/proc/update()
	if(finished || (duration && world.time > end_time))
		conclude()
		return FALSE
	return TRUE

/datum/breakdown/proc/occur()
	var/image/img = image('icons/effects/insanity_statuses.dmi', holder.owner)
	holder.owner << img
	flick(icon_state, img)
	holder.owner.playsound_local(get_turf(holder.owner), breakdown_sound, 100)
	if(start_messages)
		log_and_message_admins("[holder.owner] is affected by breakdown [name] with duration [duration/10] seconds.")
		to_chat(holder.owner, span(start_message_span, pick(start_messages)))
	if(restore_sanity_pre)
		holder.restoreLevel(restore_sanity_pre)
	if(duration == 0)
		conclude()
		return FALSE
	else if(duration > 0)
		end_time = world.time + duration
	return TRUE

/datum/breakdown/proc/conclude()
	if(end_messages)
		log_and_message_admins("[holder.owner] is no longer affected by [name]")
		to_chat(holder.owner,SPAN_NOTICE(pick(end_messages)))
	if(restore_sanity_post)
		holder.restoreLevel(restore_sanity_post)
	if(has_objetives)
		if(finished)
			holder.insight += isight_reward
		else if(is_negative)
			holder.changeLevel(-rand(20,30))
	qdel(src)
