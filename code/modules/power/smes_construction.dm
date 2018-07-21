// BUILDABLE SMES(Superconducting Magnetic Energy Storage) UNIT
//
// Last Change 1.1.2015 by Atlantis - Happy New Year!
//
// This is subtype of SMES that should be normally used. It can be constructed, deconstructed and hacked.
// It also supports RCON System which allows you to operate it remotely, if properly set.

//MAGNETIC COILS - These things actually store and transmit power within the SMES. Different types have different
/obj/item/weapon/smes_coil
	name = "superconductive magnetic coil"
	desc = "Standard superconductive magnetic coil with average capacity and I/O rating."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "smes_coil"			// Just few icons patched together. If someone wants to make better icon, feel free to do so!
	w_class = ITEM_SIZE_LARGE 						// It's LARGE (backpack size)
	matter = list(MATERIAL_STEEL = 10, MATERIAL_PLASTIC = 4, MATERIAL_GLASS = 4)
	var/ChargeCapacity = 10000000
	var/IOCapacity = 750000

// 20% Charge Capacity, 60% I/O Capacity. Used for substation/outpost SMESs.
/obj/item/weapon/smes_coil/weak
	name = "basic superconductive magnetic coil"
	desc = "Cheaper model of standard superconductive magnetic coil. It's capacity and I/O rating are considerably lower."
	ChargeCapacity = 2000000
	IOCapacity = 600000

// 1000% Charge Capacity, 20% I/O Capacity
/obj/item/weapon/smes_coil/super_capacity
	name = "superconductive capacitance coil"
	desc = "Specialised version of standard superconductive magnetic coil. This one has significantly stronger containment field, allowing for significantly larger power storage. It's IO rating is much lower, however."
	ChargeCapacity = 100000000
	IOCapacity = 150000

// 10% Charge Capacity, 400% I/O Capacity. Technically turns SMES into large super capacitor.Ideal for shields.
/obj/item/weapon/smes_coil/super_io
	name = "superconductive transmission coil"
	desc = "Specialised version of standard superconductive magnetic coil. While this one won't store almost any power, it rapidly transfers power, making it useful in systems which require large throughput."
	ChargeCapacity = 1000000
	IOCapacity = 3000000



// SMES itself
/obj/machinery/power/smes/buildable
	var/max_coils = 6 			//30M capacity, 1.5MW input/output when fully upgraded /w default coils
	var/cur_coils = 1 			// Current amount of installed coils
	var/safeties_enabled = 1 	// If 0 modifications can be done without discharging the SMES, at risk of critical failure.
	var/failing = 0 			// If 1 critical failure has occured and SMES explosion is imminent.
	var/datum/wires/smes/wires
	var/grounding = 1			// Cut to quickly discharge, at cost of "minor" electrical issues in output powernet.
	var/RCon = 1				// Cut to disable AI and remote control.
	var/RCon_tag = "NO_TAG"		// RCON tag, change to show it on SMES Remote control console.
	circuit = /obj/item/weapon/circuitboard/smes
	charge = 0
	should_be_mapped = 1

/obj/machinery/power/smes/buildable/Destroy()
	qdel(wires)
	wires = null
	for(var/datum/nano_module/rcon/R in world)
		R.FindDevices()
	return ..()

// Proc: process()
// Parameters: None
// Description: Uses parent process, but if grounding wire is cut causes sparks to fly around.
// This also causes the SMES to quickly discharge, and has small chance of damaging output APCs.
/obj/machinery/power/smes/buildable/Process()
	if(!grounding && (Percentage() > 5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		charge -= (output_level_max * SMESRATE)
		if(prob(1)) // Small chance of overload occuring since grounding is disabled.
			apcs_overload(5,10,20)

	..()

// Proc: attack_ai()
// Parameters: None
// Description: AI requires the RCON wire to be intact to operate the SMES.
/obj/machinery/power/smes/buildable/attack_ai()
	if(RCon)
		..()
	else // RCON wire cut
		usr << SPAN_WARNING("Connection error: Destination Unreachable.")

	// Cyborgs standing next to the SMES can play with the wiring.
	if(isrobot(usr) && Adjacent(usr) && open_hatch)
		wires.Interact(usr)

// Proc: New()
// Parameters: None
// Description: Set wires with requed type
/obj/machinery/power/smes/buildable/New()
	..()
	src.wires = new /datum/wires/smes(src)

// Proc: attack_hand()
// Parameters: None
// Description: Opens the UI as usual, and if cover is removed opens the wiring panel.
/obj/machinery/power/smes/buildable/attack_hand()
	..()
	if(open_hatch)
		wires.Interact(usr)

// Proc: RefreshParts()
// Parameters: None
// Description: Updates properties (IO, capacity, etc.) of this SMES by checking internal components.
/obj/machinery/power/smes/buildable/RefreshParts()
	cur_coils = 0
	capacity = 0
	input_level_max = 0
	output_level_max = 0
	for(var/obj/item/weapon/smes_coil/C in component_parts)
		cur_coils ++
		capacity += C.ChargeCapacity
		input_level_max += C.IOCapacity
		output_level_max += C.IOCapacity
	charge = between(0, charge, capacity)
	input_level = between(0, input_level, input_level_max)
	output_level = between(0, output_level, output_level_max)
	return 1

// Proc: total_system_failure()
// Parameters: 2 (intensity - how strong the failure is, user - person which caused the failure)
// Description: Checks the sensors for alerts. If change (alerts cleared or detected) occurs, calls for icon update.
/obj/machinery/power/smes/buildable/proc/total_system_failure(var/intensity = 0, var/mob/user as mob)
	// SMESs store very large amount of power. If someone screws up (ie: Disables safeties and attempts to modify the SMES) very bad things happen.
	// Bad things are based on charge percentage.
	// Possible effects:
	// Sparks - Lets out few sparks, mostly fire hazard if plasma present. Otherwise purely aesthetic.
	// Shock - Depending on intensity harms the user. Insultated Gloves protect against weaker shocks, but strong shock bypasses them.
	// EMP Pulse - Lets out EMP pulse discharge which screws up nearby electronics.
	// Light Overload - X% chance to overload each lighting circuit in connected powernet. APC based.
	// APC Failure - X% chance to destroy APC causing very weak explosion too. Won't cause hull breach or serious harm.
	// SMES Explosion - X% chance to destroy the SMES, in moderate explosion. May cause small hull breach.

	if (!intensity)
		return

	var/mob/living/carbon/human/h_user = null
	if (!ishuman(user))
		return
	else
		h_user = user


	// Preparations
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	// Check if user has protected gloves.
	var/user_protected = 0
	if(h_user.gloves)
		var/obj/item/clothing/gloves/G = h_user.gloves
		if(G.siemens_coefficient == 0)
			user_protected = 1
	log_game("SMES FAILURE: <b>[src.x]X [src.y]Y [src.z]Z</b> User: [usr.ckey], Intensity: [intensity]/100")
	message_admins("SMES FAILURE: <b>[src.x]X [src.y]Y [src.z]Z</b> User: [usr.ckey], Intensity: [intensity]/100 - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>")


	switch (intensity)
		if (0 to 15)
			// Small overcharge
			// Sparks, Weak shock
			s.set_up(2, 1, src)
			s.start()
			if (user_protected && prob(80))
				h_user << "Small electrical arc almost burns your hand. Luckily you had your gloves on!"
			else
				h_user << "Small electrical arc sparks and burns your hand as you touch the [src]!"
				h_user.adjustFireLoss(rand(5,10))
				h_user.Paralyse(2)
			charge = 0

		if (16 to 35)
			// Medium overcharge
			// Sparks, Medium shock, Weak EMP
			s.set_up(4,1,src)
			s.start()
			if (user_protected && prob(25))
				h_user << "Medium electrical arc sparks and almost burns your hand. Luckily you had your gloves on!"
			else
				h_user << "Medium electrical sparks as you touch the [src], severely burning your hand!"
				h_user.adjustFireLoss(rand(10,25))
				h_user.Paralyse(5)
			spawn(0)
				empulse(src.loc, 2, 4)
			apcs_overload(0, 5, 10)
			charge = 0

		if (36 to 60)
			// Strong overcharge
			// Sparks, Strong shock, Strong EMP, 10% light overload. 1% APC failure
			s.set_up(7,1,src)
			s.start()
			if (user_protected)
				h_user << "Strong electrical arc sparks between you and [src], ignoring your gloves and burning your hand!"
				h_user.adjustFireLoss(rand(25,60))
				h_user.Paralyse(8)
			else
				h_user << "Strong electrical arc sparks between you and [src], knocking you out for a while!"
				h_user.adjustFireLoss(rand(35,75))
				h_user.Paralyse(12)
			spawn(0)
				empulse(src.loc, 8, 16)
			charge = 0
			apcs_overload(1, 10, 20)
			energy_fail(10)
			src.ping("Caution. Output regulators malfunction. Uncontrolled discharge detected.")

		if (61 to INFINITY)
			// Massive overcharge
			// Sparks, Near - instantkill shock, Strong EMP, 25% light overload, 5% APC failure. 50% of SMES explosion. This is bad.
			s.set_up(10,1,src)
			s.start()
			h_user << "Massive electrical arc sparks between you and [src]. Last thing you can think about is \"Oh shit...\""
			// Remember, we have few gigajoules of electricity here.. Turn them into crispy toast.
			h_user.adjustFireLoss(rand(150,195))
			h_user.Paralyse(25)
			spawn(0)
				empulse(src.loc, 32, 64)
			charge = 0
			apcs_overload(5, 25, 100)
			energy_fail(30)
			src.ping("Caution. Output regulators malfunction. Significant uncontrolled discharge detected.")

			if (prob(50))
				// Added admin-notifications so they can stop it when griffed.
				log_game("SMES explosion imminent.")
				message_admins("SMES explosion imminent.")
				src.ping("DANGER! Magnetic containment field unstable! Containment field failure imminent!")
				failing = 1
				// 30 - 60 seconds and then BAM!
				spawn(rand(300,600))
					if(!failing) // Admin can manually set this var back to 0 to stop overload, for use when griffed.
						update_icon()
						src.ping("Magnetic containment stabilised.")
						return
					src.ping("DANGER! Magnetic containment field failure in 3 ... 2 ... 1 ...")
					explosion(src.loc,1,2,4,8)
					// Not sure if this is necessary, but just in case the SMES *somehow* survived..
					qdel(src)



// Proc: apcs_overload()
// Parameters: 3 (failure_chance - chance to actually break the APC, overload_chance - Chance of breaking lights, reboot_chance - Chance of temporarily disabling the APC)
// Description: Damages output powernet by power surge. Destroys few APCs and lights, depending on parameters.
/obj/machinery/power/smes/buildable/proc/apcs_overload(var/failure_chance, var/overload_chance, var/reboot_chance)
	if (!src.powernet)
		return

	for(var/obj/machinery/power/terminal/T in src.powernet.nodes)
		if(istype(T.master, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/A = T.master
			if (prob(overload_chance))
				A.overload_lighting()
			if (prob(failure_chance))
				A.set_broken()
			if(prob(reboot_chance))
				A.energy_fail(rand(30,60))

// Proc: update_icon()
// Parameters: None
// Description: Allows us to use special icon overlay for critical SMESs
/obj/machinery/power/smes/buildable/update_icon()
	if (failing)
		overlays.Cut()
		overlays += image('icons/obj/power.dmi', "smes-crit")
	else
		..()

// Proc: attackby()
// Parameters: 2 (W - object that was used on this machine, user - person which used the object)
// Description: Handles tool interaction. Allows deconstruction/upgrading/fixing.
/obj/machinery/power/smes/buildable/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	// No more disassembling of overloaded SMESs. You broke it, now enjoy the consequences.
	if (failing)
		user << SPAN_WARNING("The [src]'s screen is flashing with alerts. It seems to be overloaded! Touching it now is probably not a good idea.")
		return
	// If parent returned 1:
	// - Hatch is open, so we can modify the SMES
	// - No action was taken in parent function (terminal de/construction atm).
	if (..())

		// Multitool - change RCON tag
		if(istype(W, /obj/item/weapon/tool/multitool))
			var/newtag = input(user, "Enter new RCON tag. Use \"NO_TAG\" to disable RCON or leave empty to cancel.", "SMES RCON system") as text
			if(newtag)
				RCon_tag = newtag
				user << SPAN_NOTICE("You changed the RCON tag to: [newtag]")
			return
		// Charged above 1% and safeties are enabled.
		if((charge > (capacity/100)) && safeties_enabled)
			user << SPAN_WARNING("Safety circuit of [src] is preventing modifications while it's charged!")
			return

		if (output_attempt || input_attempt)
			user << SPAN_WARNING("Turn off the [src] first!")
			return

		// Probability of failure if safety circuit is disabled (in %)
		var/failure_probability = round((charge / capacity) * 100)

		// If failure probability is below 5% it's usually safe to do modifications
		if (failure_probability < 5)
			failure_probability = 0

		// Crowbar - Disassemble the SMES.
		if(istype(W, /obj/item/weapon/tool/crowbar))
			if (terminal)
				user << SPAN_WARNING("You have to disassemble the terminal first!")
				return

			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			user << SPAN_WARNING("You begin to disassemble the [src]!")
			if (do_after(usr, 100 * cur_coils, src)) // More coils = takes longer to disassemble. It's complex so largest one with 5 coils will take 50s

				if (failure_probability && prob(failure_probability))
					total_system_failure(failure_probability, user)
					return

				usr << SPAN_WARNING("You have disassembled the SMES cell!")
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 2
				M.icon_state = "box_1"
				for(var/obj/I in component_parts)
					I.loc = src.loc
					component_parts -= I
				qdel(src)
				return

		// Superconducting Magnetic Coil - Upgrade the SMES
		else if(istype(W, /obj/item/weapon/smes_coil))
			if (cur_coils < max_coils)

				if (failure_probability && prob(failure_probability))
					total_system_failure(failure_probability, user)
					return

				usr << "You install the coil into the SMES unit!"
				user.drop_item()
				component_parts += W
				W.loc = src
				RefreshParts()
			else
				usr << "\red You can't insert more coils to this SMES unit!"

// Proc: toggle_input()
// Parameters: None
// Description: Switches the input on/off depending on previous setting
/obj/machinery/power/smes/buildable/proc/toggle_input()
	inputting(!input_attempt)
	update_icon()

// Proc: toggle_output()
// Parameters: None
// Description: Switches the output on/off depending on previous setting
/obj/machinery/power/smes/buildable/proc/toggle_output()
	outputting(!output_attempt)
	update_icon()

// Proc: set_input()
// Parameters: 1 (new_input - New input value in Watts)
// Description: Sets input setting on this SMES. Trims it if limits are exceeded.
/obj/machinery/power/smes/buildable/proc/set_input(var/new_input = 0)
	input_level = between(0, new_input, input_level_max)
	update_icon()

// Proc: set_output()
// Parameters: 1 (new_output - New output value in Watts)
// Description: Sets output setting on this SMES. Trims it if limits are exceeded.
/obj/machinery/power/smes/buildable/proc/set_output(var/new_output = 0)
	output_level = between(0, new_output, output_level_max)
	update_icon()
