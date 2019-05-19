/datum/autodoc_patchnote
	var/surgery_operations = 0
	var/obj/item/organ/organ = null
/datum/autodoc_patchnote/proc/Copy(var/blank = TRUE)
	var/datum/autodoc_patchnote/copy = new()
	copy.organ = organ
	if(!blank)
		copy.surgery_operations = surgery_operations
	return copy
/datum/autodoc
	var/list/scanned_patchnotes = list()
	var/list/picked_patchnotes = list()
	var/obj/holder
	var/template_name = "autodoc.tmpl"

	var/active = FALSE
	var/damage_heal_amount = 30
	var/processing_speed = 30 SECONDS
	var/current_step = 1
	var/start_op_time
	var/mob/living/carbon/human/patient = null
	var/list/possible_operations = list(AUTODOC_DAMAGE, AUTODOC_EMBED_OBJECT, AUTODOC_FRACTURE, AUTODOC_OPEN_WOUNDS, AUTODOC_TOXIN, AUTODOC_DIALYSIS, AUTODOC_BLOOD)

/datum/autodoc/proc/set_patient(var/mob/living/carbon/human/human = null)
	patient = human
/datum/autodoc/proc/scan_user()
	if(active)
		to_chat(usr, SPAN_WARNING("Autodoc already in use"))
		return FALSE
	
	scanned_patchnotes = new()
	picked_patchnotes = new()

	var/datum/autodoc_patchnote/toxnote = new()
	if(patient.getToxLoss())
		toxnote.surgery_operations |= AUTODOC_TOXIN
	if(patient.reagents.reagent_list.len)
		toxnote.surgery_operations |= AUTODOC_DIALYSIS
	if((patient.vessel.get_reagent_amount("blood") / patient.species.blood_volume) < 1)
		toxnote.surgery_operations |= AUTODOC_BLOOD
	if(toxnote.surgery_operations)
		scanned_patchnotes.Add(toxnote)
		picked_patchnotes.Add(toxnote.Copy())

	if(AUTODOC_DAMAGE in possible_operations)
		for(var/obj/item/organ/internal/internal in patient.internal_organs)
			if(internal.damage)
				var/datum/autodoc_patchnote/patchnote = new()
				patchnote.organ = internal
				patchnote.surgery_operations |= AUTODOC_DAMAGE
				scanned_patchnotes.Add(patchnote)
				picked_patchnotes.Add(patchnote.Copy())

	for(var/obj/item/organ/external/external in patient.bad_external_organs)
		var/datum/autodoc_patchnote/patchnote = new()
		patchnote.organ = external
		if(AUTODOC_DAMAGE in possible_operations)
			if(external.brute_dam || external.burn_dam)
				if(external.robotic)
					continue
				patchnote.surgery_operations |= AUTODOC_DAMAGE
		
		if(AUTODOC_FRACTURE in possible_operations)
			if(external.status & ORGAN_BROKEN)
				patchnote.surgery_operations |= AUTODOC_FRACTURE
		if(AUTODOC_EMBED_OBJECT in possible_operations)
			if(external.implants)
				if(/obj/item/weapon/material/shard/shrapnel in external.implants)
					patchnote.surgery_operations |= AUTODOC_EMBED_OBJECT

		if(external.wounds.len)
			for(var/datum/wound/wound in external.wounds)
				if(wound.internal)
					if(AUTODOC_IB in possible_operations)
						patchnote.surgery_operations |= AUTODOC_IB
				else 
					if(AUTODOC_OPEN_WOUNDS in possible_operations)
						if(!wound.is_treated())
							patchnote.surgery_operations |= AUTODOC_OPEN_WOUNDS
		if(patchnote.surgery_operations)
			scanned_patchnotes.Add(patchnote)
			picked_patchnotes.Add(patchnote.Copy())

/datum/autodoc/proc/process_note(var/datum/autodoc_patchnote/patchnote)
	if(!patchnote.surgery_operations)
		return TRUE
	var/obj/item/organ/external/external = patchnote.organ
	if(!patchnote.organ)
		if(patchnote.surgery_operations & AUTODOC_TOXIN)
			patient.adjustToxLoss(-damage_heal_amount)
			if(!patient.getToxLoss())
				patchnote.surgery_operations &= ~AUTODOC_TOXIN

		else if(patchnote.surgery_operations & AUTODOC_DIALYSIS)
			var/pumped = 0
			for(var/datum/reagent/x in patient.reagents.reagent_list)
				patient.reagents.remove_any(AUTODOC_DIALYSIS_AMOUNT)
				pumped+=AUTODOC_DIALYSIS_AMOUNT
			patient.vessel.remove_any(pumped + 1)
			if(!pumped)
				patchnote.surgery_operations &= ~AUTODOC_DIALYSIS
		
		else if (patchnote.surgery_operations & AUTODOC_BLOOD)
			var/datum/reagent/blood/blood = patient.vessel.reagent_list[1]
			blood.volume += damage_heal_amount
			if(blood.volume >= patient.vessel.total_volume)
				patchnote.surgery_operations &= ~AUTODOC_BLOOD

	else if(patchnote.surgery_operations & AUTODOC_DAMAGE)
		if(istype(patchnote.organ, /obj/item/organ/internal))
			var/obj/item/organ/internal/internal = patchnote.organ
			internal.damage -= damage_heal_amount
			if(internal.damage < 0) internal.damage = 0
			if(!internal.damage) patchnote.surgery_operations &= ~AUTODOC_DAMAGE
			return !internal.damage
		
		external.heal_damage(damage_heal_amount, damage_heal_amount)
		if(!external.brute_dam && !external.burn_dam) patchnote.surgery_operations &= ~AUTODOC_DAMAGE

	else if(patchnote.surgery_operations & AUTODOC_EMBED_OBJECT)
		for(var/obj/item/weapon/material/shard/shrapnel/shrapnel in external.implants)
			external.implants -= shrapnel
			shrapnel.loc = get_turf(patient)
		patchnote.surgery_operations &= ~AUTODOC_EMBED_OBJECT

	else if(patchnote.surgery_operations & AUTODOC_OPEN_WOUNDS)
		for(var/datum/wound/wound in external.wounds)
			if(!wound.internal)
				wound.bandaged = 1
				wound.clamped = 1
				wound.salved = 1
				wound.disinfected = 1
				wound.germ_level = 0
		patchnote.surgery_operations &= ~AUTODOC_OPEN_WOUNDS

	else if(patchnote.surgery_operations & AUTODOC_FRACTURE)
		external.mend_fracture()
		patchnote.surgery_operations &= ~AUTODOC_FRACTURE

	else if(patchnote.surgery_operations & AUTODOC_IB)
		for(var/datum/wound/wound in external.wounds)
			if(wound.internal)
				external.wounds -= wound
				qdel(wound)
				external.update_damages()
		patchnote.surgery_operations &= ~AUTODOC_IB
	return !patchnote.surgery_operations

/datum/autodoc/Process()
	if(!patient)
		stop()
	if( current_step > picked_patchnotes.len )
		stop()
		scan_user(patient)
	if(world.time > (start_op_time + processing_speed))
		start_op_time = world.time
		patient.updatehealth()
		if(process_note(picked_patchnotes[current_step]))
			current_step++

/datum/autodoc/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 2, var/datum/topic_state/state)
	if(!patient)
		if(ui)
			ui.close()
		return
	var/list/data = form_data()
	ui = SSnano.try_update_ui(user, holder, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, holder, ui_key, template_name, "Autodoc", 600, 480, state=state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(TRUE)
		ui.set_auto_update_layout(TRUE)

/datum/autodoc/proc/form_data()
	var/list/data = list()

	data["active"] = active
	data["progress"] = (world.time - start_op_time) / processing_speed
	data["over_brute"] = patient.getBruteLoss()
	data["over_burn"] = patient.getFireLoss()
	data["over_oxy"] = patient.getOxyLoss()
	data["over_tox"] = patient.getToxLoss()
	data["blood_amount"] = patient.vessel.get_reagent_amount("blood") / patient.species.blood_volume * 100

	var/list/organs = list()
	
	var/i = 0
	if(!scanned_patchnotes.len)
		data["antitox"] = FALSE
		data["antitox_picked"] = FALSE

		data["dialysis"] = FALSE
		data["dialysis_picked"] = FALSE
			
		data["blood"] = FALSE
		data["blood_picked"] = FALSE
	else
		for(var/datum/autodoc_patchnote/note in scanned_patchnotes)
			i++
			var/list/organ = list()
			organ["id"] = i
			if(!note.organ)
				data["antitox"] = note.surgery_operations & AUTODOC_TOXIN
				data["antitox_picked"] = picked_patchnotes[i].surgery_operations & AUTODOC_TOXIN

				data["dialysis"] = note.surgery_operations & AUTODOC_DIALYSIS
				data["dialysis_picked"] = picked_patchnotes[i].surgery_operations & AUTODOC_DIALYSIS
				
				data["blood"] = note.surgery_operations & AUTODOC_BLOOD
				data["blood_picked"] = picked_patchnotes[i].surgery_operations & AUTODOC_BLOOD
				continue
			
			if(istype(note.organ, /obj/item/organ/internal))
				var/obj/item/organ/internal/internal = note.organ
				organ["name"] = internal.name
				organ["internal"] = TRUE
				organ["inner_damage"] = internal.damage

				organ["damage"] = note.surgery_operations & AUTODOC_DAMAGE
				organ["damage_picked"] = picked_patchnotes[i].surgery_operations & AUTODOC_DAMAGE
			else
				var/obj/item/organ/external/external = note.organ
				organ["name"] = external.name
				organ["brute_damage"] = external.brute_dam
				organ["burn_damage"] = external.burn_dam

				organ["fracture"] = note.surgery_operations & AUTODOC_FRACTURE
				organ["fracture_picked"] = picked_patchnotes[i].surgery_operations & AUTODOC_FRACTURE

				organ["shrapnel"] = note.surgery_operations & AUTODOC_EMBED_OBJECT
				organ["shrapnel_picked"] = picked_patchnotes[i].surgery_operations & AUTODOC_EMBED_OBJECT

				organ["damage"] = note.surgery_operations & AUTODOC_DAMAGE
				organ["damage_picked"] = picked_patchnotes[i].surgery_operations & AUTODOC_DAMAGE

				organ["wound"] = note.surgery_operations & AUTODOC_OPEN_WOUNDS
				organ["wound_picked"] = picked_patchnotes[i].surgery_operations & AUTODOC_OPEN_WOUNDS

				organ["ib"] = note.surgery_operations & AUTODOC_IB
				organ["ib_picked"] = picked_patchnotes[i].surgery_operations & AUTODOC_IB
			organs+= list(organ)
	data["organs"] = organs
	return data

/datum/autodoc/proc/stop()
	active = FALSE
	if(patient)
		patient.UpdateDamageIcon()
	if(picked_patchnotes)
		for(var/datum/autodoc_patchnote/note in picked_patchnotes)
			note.surgery_operations = 0

/datum/autodoc/proc/start()
	if(active)
		return
	current_step = 1
	src.start_op_time = world.time
	if(patient)
		active = TRUE
		spawn()
			while(active)
				sleep(1 SECOND)
				Process()
				ui_interact(patient)
	

/datum/autodoc/Topic(href, href_list)
	if(..()) return TRUE
	if(href_list["scan"])
		scan_user(patient)
	if(href_list["picked"])
		start()
	if(href_list["full"])
		picked_patchnotes = scanned_patchnotes.Copy()
		start()
	if(href_list["stop"])
		stop()
	if(href_list["toggle"])
		var/op = 0
		var/id = text2num(href_list["id"])
		switch(href_list["toggle"])
			if("damage")
				op = AUTODOC_DAMAGE
			if("wound")
				op = AUTODOC_OPEN_WOUNDS
			if("ib")
				op = AUTODOC_IB
			if("fracture")
				op = AUTODOC_FRACTURE
			if("shrapnel")
				op = AUTODOC_EMBED_OBJECT
			if("dialysis")
				op = AUTODOC_DIALYSIS
			if("antitox")
				op = AUTODOC_TOXIN
			if("blood")
				op = AUTODOC_BLOOD
		if(picked_patchnotes[id].surgery_operations & op)
			picked_patchnotes[id].surgery_operations &= ~op
		else
			picked_patchnotes[id].surgery_operations |= op
	return TRUE
	
/datum/autodoc/capitalist_autodoc
	var/datum/money_account/linked_account
	var/datum/money_account/patient_account
	var/total_cost = 0
	var/custom_cost = 0
	var/processing_cost = 0
/datum/autodoc/capitalist_autodoc/New()
	. = ..()
	linked_account = department_accounts[DEPARTMENT_MEDICAL]
	template_name = "autodoc_capitalism.tmpl"
/datum/autodoc/capitalist_autodoc/form_data()
	var/list/data = ..()

	data["patient_name"] = patient_account ? patient_account.owner_name : 0
	data["patient_money"] = patient_account ? patient_account.money : null

	data["total_cost"] = total_cost
	data["custom_cost"] = custom_cost
	data["scan_cost"] = AUTODOC_SCAN_COST

	data["damage_cost"] = AUTODOC_DAMAGE_COST
	data["wound_cost"] = AUTODOC_OPEN_WOUNDS_COST
	data["ib_cost"] = AUTODOC_IB_COST
	data["fracture_cost"] = AUTODOC_FRACTURE_COST
	data["shrapnel_cost"] = AUTODOC_EMBED_OBJECT_COST
	data["toxin_cost"] = AUTODOC_TOXIN_COST
	data["dialysis_cost"] = AUTODOC_DIALYSIS_COST
	data["blood_cost"] = AUTODOC_BLOOD_COST

	return data
/datum/autodoc/capitalist_autodoc/proc/charge(var/amount = 100)
	if(linked_account && !linked_account.is_valid())
		to_chat(patient, "Autodoc is out of service. Error code: #0x09")
		return FALSE
	if(!patient_account || !patient_account.is_valid())
		to_chat(patient, SPAN_WARNING("Proper banking account is needed."))
		return
	if(amount > patient_account.money)
		to_chat(patient, SPAN_WARNING("Insufficient funds."))
		return
	var/datum/transaction/T
	T = new(-amount, linked_account.owner_name, "Autodoc surgery", "Autodoc")
	T.apply_to(patient_account)
	T = new(amount, patient_account.owner_name, "Autodoc surgery", "Autodoc")
	T.apply_to(linked_account)
	return TRUE

/datum/autodoc/capitalist_autodoc/scan_user()
	. = ..()
	custom_cost = 0
	total_cost = recalc_costs(scanned_patchnotes)

/datum/autodoc/capitalist_autodoc/proc/recalc_costs(var/list/notes)
	var/cost = 0 
	for(var/datum/autodoc_patchnote/patchnote in notes)
		if(patchnote.surgery_operations & AUTODOC_TOXIN)
			cost += AUTODOC_TOXIN_COST
		if(patchnote.surgery_operations & AUTODOC_DIALYSIS)
			cost += AUTODOC_DIALYSIS_COST
		if (patchnote.surgery_operations & AUTODOC_BLOOD)
			cost += AUTODOC_BLOOD_COST
		if( patchnote.surgery_operations & AUTODOC_DAMAGE)
			cost += AUTODOC_DAMAGE_COST
		if( patchnote.surgery_operations & AUTODOC_EMBED_OBJECT)
			cost += AUTODOC_EMBED_OBJECT_COST
		if( patchnote.surgery_operations & AUTODOC_OPEN_WOUNDS)
			cost += AUTODOC_OPEN_WOUNDS_COST
		if( patchnote.surgery_operations & AUTODOC_FRACTURE)
			cost += AUTODOC_FRACTURE_COST
		if( patchnote.surgery_operations & AUTODOC_IB)
			cost += AUTODOC_IB_COST
	return cost
/datum/autodoc/capitalist_autodoc/proc/login()
	if(!patient)
		patient_account = null
		return
	var/obj/item/weapon/card/id/id_card = patient.GetIdCard()
	if(id_card)
		patient_account = get_account(id_card.associated_account_number)
		if(patient_account.security_level)
			var/attempt_pin = ""
			attempt_pin = input("Enter pin code", "Autodoc payement") as num
			patient_account = attempt_account_access(id_card.associated_account_number, attempt_pin, 2)
/datum/autodoc/capitalist_autodoc/start()
	if(!charge(processing_cost))
		return
	..()
/datum/autodoc/capitalist_autodoc/scan_user(mob/living/carbon/human/human)
	if(!charge(AUTODOC_SCAN_COST))
		return
	. = ..()

/datum/autodoc/capitalist_autodoc/Topic(href, href_list)
	if(href_list["full"])
		processing_cost = total_cost
	if(href_list["picked"])
		processing_cost = custom_cost
	. = ..()
	if(href_list["toggle"])
		custom_cost = recalc_costs(picked_patchnotes)
	if(href_list["login"])
		login()
		. = TRUE