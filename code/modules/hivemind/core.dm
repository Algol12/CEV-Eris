//The Hivemind is a rogue AI using nanites.
//The objective of this AI is to spread across the ship and destroy as much as possible.

#define HIVE_FACTION 			"hive"
#define MAX_NODES_AMOUNT 	10
#define MIN_NODES_RANGE		15
#define ishivemindmob(A) 	istype(A, /mob/living/simple_animal/hostile/hivemind)

var/datum/hivemind/hive_mind_ai

/datum/hivemind
	var/name
	var/surname
	var/evo_points = 0
	var/evo_points_max = 1000
	var/failure_chance = 45				//how often will be created dummy machines. This chance reduces by 1 each 10 EP
	var/list/hives = list() 			//all functional hives stored here
	//i know, whitelist is bad, but it's required here
	var/list/restricted_machineries = list( /obj/machinery/light,					/obj/machinery/atmospherics,
											/obj/machinery/portable_atmospherics,	/obj/machinery/door,
											/obj/machinery/camera,					/obj/machinery/light_switch,
											/obj/machinery/disposal,				/obj/machinery/firealarm,
											/obj/machinery/alarm,					/obj/machinery/recharger,
											/obj/machinery/hologram,				/obj/machinery/holoposter,
											/obj/machinery/button,					/obj/machinery/ai_status_display,
											/obj/machinery/status_display,			/obj/machinery/requests_console,
											/obj/machinery/newscaster,				/obj/machinery/floor_light,
											/obj/machinery/nuclearbomb,				/obj/machinery/flasher,
											/obj/machinery/filler_object,			/obj/machinery/hivemind_machine,
											/obj/machinery/meter,					/obj/machinery/cryopod,
											/obj/machinery/gravity_generator,		/obj/machinery/shield_conduit,
											/obj/machinery/power/shield_generator)
	//internals
	var/list/global_abilities_cooldown = list()
	var/list/EP_price_list = list()

/datum/hivemind/New()
	..()
	name = pick("Reclaimer", "Shaper", "Executor", "Assimilator",
				"Exploiter", "Builder", "Creator",
				"Connector", "Splicer", "Propagator")

	surname = pick("ALPHA", "BETA", "GAMMA", "DELTA", "OMEGA", "UTOPIA",
					"SALVATION-X", "CHORUS", "ICARUS", "HEGEMONY", "HARMONY")
	var/list/all_machines = subtypesof(/obj/machinery/hivemind_machine) - /obj/machinery/hivemind_machine/node
	//price list building
	//here we create list with EP price to compare it at annihilation proc
	for(var/machine_path in all_machines)
		var/obj/machinery/hivemind_machine/temporary_machine = new machine_path
		EP_price_list[machine_path] = temporary_machine.evo_points_required
		qdel(temporary_machine)
	message_admins("Hivemind [name] [surname] has been created.")


/datum/hivemind/proc/die()
	message_admins("Hivemind [name] [surname] is destroyed.")
	hive_mind_ai = null
	qdel(src)

/datum/hivemind/proc/get_points()
	if(evo_points < evo_points_max)
		evo_points++
		if(failure_chance > 10 && (evo_points % 10 == 0))
			failure_chance -= 1
