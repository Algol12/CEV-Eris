/mob/living/carbon/human/check_HUD()
	var/mob/living/carbon/human/H = src
	if(!H.client)
		return

//	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]
	var/recreate_flag = 0

	if(!check_HUDdatum())//�������� �������� ������� �� ������������
		log_debug("[H] try check a HUD, but HUDdatums not have \"[H.client.prefs.UI_style]!\"")
		H << "Some problem hase accure, use default HUD type"
		H.defaultHUD = "ErisStyle"
		++recreate_flag
	else if (H.client.prefs.UI_style != H.defaultHUD)//���� ����� � ���� �� ��������� �� ������ � �������
		H.defaultHUD = H.client.prefs.UI_style
		++recreate_flag

	if (recreate_flag)
		H.destroy_HUD()
		H.create_HUD()

	H.minimalize_HUD()
	H.show_HUD()

	if(!recreate_flag && !check_HUD_style())
		H.recolor_HUD(H.client.prefs.UI_style_color, H.client.prefs.UI_style_alpha)

	return recreate_flag

/mob/living/carbon/human/check_HUD_style()
	var/mob/living/carbon/human/H = src


	for (var/obj/screen/inventory/HUDinv in H.HUDinventory)

		if (HUDinv.color != H.client.prefs.UI_style_color || HUDinv.alpha != H.client.prefs.UI_style_alpha)
			return 0

	for (var/p in HUDneed)
		var/obj/screen/HUDelm = HUDneed[p]
		if (HUDelm.color != H.client.prefs.UI_style_color || HUDelm.alpha != H.client.prefs.UI_style_alpha)
			return 0
	return 1

/mob/living/carbon/human/check_HUDdatum()//correct a datum?
	var/mob/living/carbon/human/H = src

	if (H.client.prefs.UI_style && !(H.client.prefs.UI_style == "")) //���� � ������� ���� �������� �����\��� ����
		if(global.HUDdatums.Find(H.client.prefs.UI_style))//���� ���������� ����� ��� ����
			return 1

	return 0

/mob/living/carbon/human/minimalize_HUD()
	var/mob/living/carbon/human/H = src
	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]

	if (H.client.prefs.UI_compact_style && HUDdatum.MinStyleFlag)
//		if (!HUDdatum.MinStyleFlag)
//			H << "That UI not have min style"
//			return
		for (var/p in H.HUDneed)
			var/obj/screen/HUD = H.HUDneed[p]
			HUD.underlays.Cut()
			if(HUDdatum.HUDneed[p]["minloc"])
				HUD.screen_loc = HUDdatum.HUDneed[p]["minloc"]


		for (var/obj/screen/inventory/HUDinv in H.HUDinventory)
			HUDinv.underlays.Cut()
			for (var/p in H.species.hud.gear)
				if(H.species.hud.gear[p] == HUDinv.slot_id)
					if(HUDdatum.slot_data[p]["minloc"])
						HUDinv.screen_loc = HUDdatum.slot_data[p]["minloc"]
					break
		for (var/obj/screen/frippery/HUDfri in H.HUDfrippery)
			H.client.screen -= HUDfri
//		for (var/obj/screen/HUDfrip in H.HUDfrippery)

//		qdel(H.HUDneed[p])
	else
		for (var/p in H.HUDneed)
			var/obj/screen/HUD = H.HUDneed[p]
			if (HUDdatum.HUDneed[p]["background"])
				HUD.underlays += HUDdatum.IconUnderlays[HUDdatum.HUDneed[p]["background"]]
			HUD.screen_loc = HUDdatum.HUDneed[p]["loc"]

		for (var/obj/screen/inventory/HUDinv in H.HUDinventory)
			for (var/p in H.species.hud.gear)
				if(H.species.hud.gear[p] == HUDinv.slot_id)
					if (HUDdatum.slot_data[p]["background"])//(HUDdatum.slot_data[HUDinv.slot_id]["background"])
						HUDinv.underlays += HUDdatum.IconUnderlays[HUDdatum.slot_data[p]["background"]]
					HUDinv.screen_loc = HUDdatum.slot_data[p]["loc"]
					break
		for (var/obj/screen/frippery/HUDfri in H.HUDfrippery)
			H.client.screen += HUDfri

	update_inv_w_uniform(0)
	update_inv_wear_id(0)
	update_inv_gloves(0)
	update_inv_glasses(0)
	update_inv_ears(0)
	update_inv_shoes(0)
	update_inv_s_store(0)
	update_inv_wear_mask(0)
	update_inv_head(0)
	update_inv_belt(0)
	update_inv_back(0)
	update_inv_wear_suit(0)
	update_inv_r_hand(0)
	update_inv_l_hand(0)
	update_inv_handcuffed(0)
	update_inv_legcuffed(0)
	update_inv_pockets(0)
//	H.regenerate_icons()
	return



/*/mob/living/carbon/human/check_HUDinventory()//correct a HUDinventory?
	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]
	var/mob/living/carbon/human/H = src

	if ((H.HUDinventory.len != 0) && (H.HUDinventory.len == species.hud.gear.len) && !(recreate_flag))
		for (var/obj/screen/inventory/HUDinv in H.HUDinventory)
			if(!(HUDdatum.slot_data.Find(HUDinv.slot_id) && species.hud.gear.Find(HUDinv.slot_id))) //���� ������� slot_id ��� � ������ ���� � � ������ ����.
				recreate_flag = 1
				break //�� ����� ��� ������
	else
		recreate_flag = 1

	return

/mob/living/carbon/human/check_HUDneed()
	var/mob/living/carbon/human/H = src
	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]

	if ((H.HUDneed.len != 0) && (H.HUDneed.len == species.hud.ProcessHUD.len)) //���� � ���� ���� ��� � ���-�� ��. ���� ������������� �����������
		for (var/i=1,i<=HUDneed.len,i++)
			if(!(HUDdatum.HUDneed.Find(HUDneed[i]) && species.hud.ProcessHUD.Find(HUDneed[i]))) //���� ������� ���� ��� � ������ ���� � � ������ ����.
				recreate_flag = 1
				break //�� ����� ��� ������
	else
		recreate_flag = 1
	return

/mob/living/carbon/human/check_HUDfrippery()
	var/mob/living/carbon/human/H = src
	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]
	return
/mob/living/carbon/human/check_HUDprocess()
	var/mob/living/carbon/human/H = src
	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]
	return
/mob/living/carbon/human/check_HUDtech()
	var/mob/living/carbon/human/H = src
	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]
	return*/


/mob/living/carbon/human/update_hud()	//TODO: do away with this if possible
	if(client)
		check_HUD()
		client.screen |= contents
		//if(hud_used)
			//hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar







/mob/living/carbon/human/create_HUD()
//	var/mob/living/carbon/human/H = src
//	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]

	create_HUDinventory()
	create_HUDneed()
	create_HUDfrippery()
	create_HUDtech()
	recolor_HUD(src.client.prefs.UI_style_color, src.client.prefs.UI_style_alpha)

/mob/living/carbon/human/create_HUDinventory()
	var/mob/living/carbon/human/H = src
	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]

	for (var/gear_slot in species.hud.gear)//��������� �������� ���� (���������)
		if (!HUDdatum.slot_data.Find(gear_slot))
			log_debug("[usr] try take inventory data for [gear_slot], but HUDdatum not have it!")
			src << "Sorry, but something wrong witch creating a inventory slots, we recomendend chance a HUD type or call admins"
			return
		else
			var/HUDtype
			if(HUDdatum.slot_data[gear_slot]["type"])
				HUDtype = HUDdatum.slot_data[gear_slot]["type"]
			else
				HUDtype = /obj/screen/inventory

			var/obj/screen/inventory/inv_box = new HUDtype(HUDdatum.slot_data[gear_slot]["name"], species.hud.gear[gear_slot], HUDdatum.icon, HUDdatum.slot_data[gear_slot]["state"], H)
//			if(HUDdatum.slot_data[gear_slot]["dir"])
//				inv_box.set_dir(HUDdatum.slot_data[gear_slot]["dir"])
/*			if (!H.client.prefs.UI_compact_style && !HUDdatum.MinStyleFlag)
				inv_box.screen_loc = HUDdatum.slot_data[gear_slot]["loc"]
			else
				inv_box.screen_loc = HUDdatum.slot_data[gear_slot]["minloc"]
			if(!H.client.prefs.UI_compact_style && !HUDdatum.MinStyleFlag)
				if (HUDdatum.slot_data[gear_slot]["background"])
					inv_box.underlays += HUDdatum.IconUnderlays[HUDdatum.slot_data[gear_slot]["background"]]*/
			if(HUDdatum.slot_data[gear_slot]["hideflag"])
				inv_box.hideflag = HUDdatum.slot_data[gear_slot]["hideflag"]

			H.HUDinventory += inv_box
	return

/mob/living/carbon/human/create_HUDneed()
	var/mob/living/carbon/human/H = src
	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]

	for(var/HUDname in species.hud.ProcessHUD) //��������� �������� ���� (�� ���������)
		if (!(HUDdatum.HUDneed.Find(HUDname))) //���� ����� � ������
			log_debug("[usr] try create a [HUDname], but it no have in HUDdatum [HUDdatum.name]")
		else
			var/HUDtype = HUDdatum.HUDneed[HUDname]["type"]
			var/obj/screen/HUD = new HUDtype(HUDname, H, HUDdatum.HUDneed[HUDname]["icon"] ? HUDdatum.HUDneed[HUDname]["icon"] : HUDdatum.icon, HUDdatum.HUDneed[HUDname]["icon_state"] ? HUDdatum.HUDneed[HUDname]["icon_state"] : null)
/*			if (!H.client.prefs.UI_compact_style && !HUDdatum.MinStyleFlag)
				HUD.screen_loc = HUDdatum.HUDneed[HUDname]["loc"]
			else
				HUD.screen_loc = HUDdatum.HUDneed[HUDname]["minloc"]
			if(!H.client.prefs.UI_compact_style && !HUDdatum.MinStyleFlag)
				if (HUDdatum.HUDneed[HUDname]["background"])
					HUD.underlays += HUDdatum.IconUnderlays[HUDdatum.HUDneed[HUDname]["background"]]*/
			if(HUDdatum.HUDneed[HUDname]["hideflag"])
				HUD.hideflag = HUDdatum.HUDneed[HUDname]["hideflag"]
			H.HUDneed[HUD.name] += HUD//��������� � ������ �����
			if (HUD.process_flag)//���� ��� ����� ����������
				H.HUDprocess += HUD//������� � �������������� ������

	return
/mob/living/carbon/human/create_HUDfrippery()
	var/mob/living/carbon/human/H = src
	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]

	//��������� �������� ���� (���������)
	for (var/list/whistle in HUDdatum.HUDfrippery)
//		world << "[whistle["icon_state"]],[whistle["loc"]],[H.name]"
		var/obj/screen/frippery/perdelka = new (whistle["icon_state"],whistle["loc"],H)
		perdelka.icon = HUDdatum.icon
		if(whistle["hideflag"])
			perdelka.hideflag = whistle["hideflag"]
		H.HUDfrippery += perdelka
	return

/mob/living/carbon/human/create_HUDtech()
	var/mob/living/carbon/human/H = src
	var/datum/hud/human/HUDdatum = global.HUDdatums[H.defaultHUD]

	//��������� ����������� ��������(damage,flash,pain... �������)
	for (var/techobject in HUDdatum.HUDoverlays)
		var/HUDtype = HUDdatum.HUDoverlays[techobject]["type"]
		var/obj/screen/HUD = new HUDtype(techobject,H, HUDdatum.HUDoverlays[techobject]["loc"], HUDdatum.HUDoverlays[techobject]["icon"] ? HUDdatum.HUDoverlays[techobject]["icon"] : null, HUDdatum.HUDoverlays[techobject]["icon_state"] ? HUDdatum.HUDoverlays[techobject]["icon_state"] : null)
/*		if(HUDdatum.HUDoverlays[techobject]["icon"])//������ �� �������� icon
			HUD.icon = HUDdatum.HUDoverlays[techobject]["icon"]
		else
			HUD.icon = HUDdatum.icon
		if(HUDdatum.HUDoverlays[techobject]["icon_state"])//������ �� �������� icon_state
			HUD.icon_state = HUDdatum.HUDoverlays[techobject]["icon_state"]*/
		H.HUDtech[HUD.name] += HUD//��������� � ������ �����
		if (HUD.process_flag)//���� ��� ����� ����������
			H.HUDprocess += HUD//������� � �������������� ������
	return