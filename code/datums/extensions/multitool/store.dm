/datum/extension/multitool/store/interact(var/obj/item/weapon/tool/multitool/M, var/mob/user)
	if(CanUseTopic(user) != STATUS_INTERACTIVE)
		return

	if(M.get_buffer() == holder)
		M.set_buffer(null)
		user << SPAN_WARNING("You purge the connection data of \the [holder] from \the [M].")
	else
		M.set_buffer(holder)
		user << SPAN_NOTICE("You load connection data from \the [holder] to \the [M].")
