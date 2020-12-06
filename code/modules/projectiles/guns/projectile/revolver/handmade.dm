/obj/item/weapon/gun/projectile/revolver/handmade
	name = "Handmade revolver"
	desc = "Handmade revolver, made from gun parts. and some duct tap, will it even hold up?."
	icon = 'icons/obj/guns/projectile/deckard.dmi'
	icon_state = "deckard"
	caliber = CAL_MAGNUM
	origin_tech = list(TECH_COMBAT = 1, TECH_MATERIAL = 1)
	max_shells = 5
	matter = list(MATERIAL_PLASTIC = 10, MATERIAL_STEEL = 15)
	price_tag = 250 //one of the cheapest revolvers here
	damage_multiplier = 1.3
	recoil_buildup = 60
	spawn_blacklisted = TRUE
