/obj/item/clothing/glasses/night
	name = "Night Vision Goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	action_button_name = "Toggle Optical Matrix"
	origin_tech = list(TECH_MAGNET = 2)
	darkness_view = 7
	toggleable = 1
	prescription = 1
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	off_state = "denight"
	active = 0
	var/tick_cost = 1
	var/obj/item/weapon/cell/cell = null
	var/suitable_cell = /obj/item/weapon/cell/small

/obj/item/clothing/glasses/night/New()
	..()
	if(!cell && suitable_cell)
		cell = new /obj/item/weapon/cell/big/super(src)	 //More advanced power cell
	overlay = global_hud.nvg

obj/item/clothing/glasses/night/process()
	if(active)
		if(!cell || !cell.checked_use(tick_cost))
			if(ismob(src.loc))
				src.loc << "<span class='warning'>[src] flashes with error - LOW POWER.</span>"
			toggle(ismob(loc) && loc, 0)

obj/item/clothing/glasses/night/toggle(mob/user, new_state)
	if(new_state)
		if(!cell || !cell.check_charge(tick_cost) && user)
			user << "<span class='warning'>[src] battery is dead or missing.</span>"
			return
	..(user, new_state)

obj/item/clothing/glasses/night/MouseDrop(over_object)
	if((src.loc == usr) && istype(over_object, /obj/screen/inventory/hand) && eject_item(cell, usr))
		cell = null

obj/item/clothing/glasses/night/attackby(obj/item/C, mob/living/user)
	if(istype(C, suitable_cell) && !cell && insert_item(C, user))
		cell = C
