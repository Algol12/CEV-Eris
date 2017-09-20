/obj/random/gun_cheap
	name = "random cheap gun"
	icon_state = "gun-grey"
	item_to_spawn()
		return pick(prob(3);/obj/item/weapon/gun/projectile/mk58,\
					prob(1);/obj/item/weapon/gun/projectile/mk58/wood,\
					prob(4);/obj/item/weapon/gun/projectile/giskard,\
					prob(2);/obj/item/weapon/gun/projectile/shotgun/pump,\
					prob(2);/obj/item/weapon/gun/projectile/olivaw)

/obj/random/gun_cheap/low_chance
	name = "low chance random cheap gun"
	icon_state = "gun-grey-low"
	spawn_nothing_percentage = 80

/obj/random/gun_normal
	name = "random normal gun"
	icon_state = "gun-green"
	item_to_spawn()
		return pick(prob(1);/obj/item/weapon/gun/projectile/lamia,\
					prob(1);/obj/item/weapon/gun/projectile/deagle,\
					prob(2);/obj/item/weapon/gun/projectile/colt,\
					prob(2);/obj/item/weapon/gun/projectile/revolver/consul,\
					prob(2);/obj/item/weapon/gun/projectile/revolver)

/obj/random/gun_normal/low_chance
	name = "low chance random normal gun"
	icon_state = "gun-green-low"
	spawn_nothing_percentage = 80

/obj/random/gun_energy_cheap
	name = "random cheap energy weapon"
	desc = "This is a random security weapon."
	icon_state = "gun-black"
	item_to_spawn()
		return pick(prob(2);/obj/item/weapon/gun/energy/gun/martin,\
					prob(2);/obj/item/weapon/gun/energy/gun,\
					prob(1);/obj/item/weapon/gun/energy/retro)

/obj/random/gun_energy_cheap/low_chance
	name = "low chance random cheap energy weapon"
	icon_state = "gun-blue-low"
	spawn_nothing_percentage = 80
