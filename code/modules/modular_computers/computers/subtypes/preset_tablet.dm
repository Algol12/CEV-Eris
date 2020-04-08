//Loadout
/obj/item/modular_computer/tablet/preset/custom_loadout/cheap/install_default_hardware()
	..()
	processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(src)
	tesla_link = new/obj/item/weapon/computer_hardware/tesla_link(src)
	hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/micro(src)
	network_card = new/obj/item/weapon/computer_hardware/network_card(src)

/obj/item/modular_computer/tablet/preset/custom_loadout/advanced/install_default_hardware()
	..()
	processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(src)
	tesla_link = new/obj/item/weapon/computer_hardware/tesla_link(src)
	hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/small(src)
	network_card = new/obj/item/weapon/computer_hardware/network_card/advanced(src)
	printer = new/obj/item/weapon/computer_hardware/printer(src)
	card_slot = new/obj/item/weapon/computer_hardware/card_slot(src)

/obj/item/modular_computer/tablet/preset/custom_loadout/standard/install_default_hardware()
	..()
	processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(src)
	tesla_link = new/obj/item/weapon/computer_hardware/tesla_link(src)
	hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/small(src)
	network_card = new/obj/item/weapon/computer_hardware/network_card(src)

/obj/item/modular_computer/tablet/preset/custom_loadout/install_default_programs()
	..()
	install_default_programs_by_job(get(src, /mob/living/carbon/human))
	hard_drive.store_file(new/datum/computer_file/program/wordprocessor())

//Map presets

/obj/item/modular_computer/tablet/lease/preset/command/install_default_hardware()
	..()
	processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(src)
	tesla_link = new/obj/item/weapon/computer_hardware/tesla_link(src)
	hard_drive = new/obj/item/weapon/computer_hardware/hard_drive(src)
	network_card = new/obj/item/weapon/computer_hardware/network_card/advanced(src)
	printer = new/obj/item/weapon/computer_hardware/printer(src)
	card_slot = new/obj/item/weapon/computer_hardware/card_slot(src)
	cell = new/obj/item/weapon/cell/small(src)
	scanner = new /obj/item/weapon/computer_hardware/scanner/paper(src)

/obj/item/modular_computer/tablet/lease/preset/command/install_default_programs()
	..()
	hard_drive.store_file(new/datum/computer_file/program/email_client())
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/wordprocessor())
	hard_drive.store_file(new/datum/computer_file/program/newsbrowser())
	hard_drive.store_file(new/datum/computer_file/program/camera_monitor())
	hard_drive.store_file(new/datum/computer_file/program/records())

/obj/item/modular_computer/tablet/lease/preset/medical/install_default_hardware()
	..()
	processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(src)
	tesla_link = new/obj/item/weapon/computer_hardware/tesla_link(src)
	hard_drive = new/obj/item/weapon/computer_hardware/hard_drive(src)
	network_card = new/obj/item/weapon/computer_hardware/network_card(src)
	printer = new/obj/item/weapon/computer_hardware/printer(src)
	cell = new /obj/item/weapon/cell/small(src)
	scanner = new /obj/item/weapon/computer_hardware/scanner/paper(src)
	gps_sensor = new /obj/item/weapon/computer_hardware/gps_sensor(src)

/obj/item/modular_computer/tablet/lease/preset/medical/install_default_programs()
	..()
	hard_drive.store_file(new/datum/computer_file/program/email_client())
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/wordprocessor())
	hard_drive.store_file(new/datum/computer_file/program/newsbrowser())
	hard_drive.store_file(new/datum/computer_file/program/camera_monitor())
	hard_drive.store_file(new/datum/computer_file/program/suit_sensors())
	hard_drive.store_file(new/datum/computer_file/program/records())
	set_autorun("sensormonitor")

/obj/item/modular_computer/tablet/lease/preset/chemistry/install_default_hardware()
	..()
	processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(src)
	tesla_link = new/obj/item/weapon/computer_hardware/tesla_link(src)
	hard_drive = new/obj/item/weapon/computer_hardware/hard_drive(src)
	network_card = new/obj/item/weapon/computer_hardware/network_card(src)
	printer = new/obj/item/weapon/computer_hardware/printer(src)
	cell = new /obj/item/weapon/cell/small(src)
	scanner = new /obj/item/weapon/computer_hardware/scanner/paper(src)
	gps_sensor = new /obj/item/weapon/computer_hardware/gps_sensor(src)

/obj/item/modular_computer/tablet/lease/preset/chemistry/install_default_programs()
	..()
	hard_drive.store_file(new/datum/computer_file/program/email_client())
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/wordprocessor())
	hard_drive.store_file(new/datum/computer_file/program/newsbrowser())
	hard_drive.store_file(new/datum/computer_file/program/camera_monitor())
	hard_drive.store_file(new/datum/computer_file/program/chem_catalog())
	hard_drive.store_file(new/datum/computer_file/program/records())
	set_autorun("chemCatalog")