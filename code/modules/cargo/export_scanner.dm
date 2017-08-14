/obj/item/device/export_scanner
	name = "export scanner"
	desc = "A device used to check objects against Commercial database."
	icon = 'icons/obj/autopsy_scanner.dmi' //I know what you're thinking, but I do not have a sprite ~TermService
	icon_state = "export_scan"
	item_state = "radio"
	flags = NOBLUDGEON
	w_class = 2
	siemens_coefficient = 1
	var/power = 0
	var/obj/item/weapon/cell/cell = null
	var/suitable_cell = /obj/item/weapon/cell/small
	var/obj/machinery/computer/supplycomp/cargo_console = null

/obj/item/device/export_scanner/New()
	..()
	if(!cell && suitable_cell)
		cell = new suitable_cell(src)


/obj/item/device/export_scanner/examine(mob/user)
	..()
	if(!cargo_console)
		user << "<span class='notice'>The [src] is currently not linked to a cargo console.</span>"

/obj/item/device/export_scanner/afterattack(obj/O, mob/user, proximity)
	if(!cell || !cell.checked_use(10))
		user << "<span class='warning'>[src] battery is dead or missing</span>"
		return
	if(!istype(O) || !proximity)
		return

	if(istype(O, /obj/machinery/computer/supplycomp))
		var/obj/machinery/computer/supplycomp/C = O
		if(!C.requestonly)
			cargo_console = C
			user << "<span class='notice'>Scanner linked to [C].</span>"
	else if(!istype(cargo_console))
		user << "<span class='warning'>You must link [src] to a cargo console first!</span>"
	else
		// Before you fix it:
		// yes, checking manifests is a part of intended functionality.
		var/price = export_item_and_contents(O, cargo_console.contraband, cargo_console.emagged, dry_run=TRUE)

		if(price)
			user << "<span class='notice'>Scanned [O], value: <b>[price]</b> \
				credits[O.contents.len ? " (contents included)" : ""].</span>"
		else
			user << "<span class='warning'>Scanned [O], no export value. \
				</span>"

/obj/item/device/export_scanner/MouseDrop(over_object)
	if((src.loc == usr) && istype(over_object, /obj/screen/inventory/hand) && eject_item(cell, usr))
		cell = null

/obj/item/device/export_scanner/attackby(obj/item/C, mob/living/user)
	if(istype(C, suitable_cell) && !cell && insert_item(C, user))
		src.cell = C
