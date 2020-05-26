/obj/random/rations
	name = "random preserved rations"
	icon_state = "food-green"

/obj/random/rations/item_to_spawn()
	return pickweight(list(/obj/item/weapon/reagent_containers/food/snacks/chips = 2,\
				/obj/item/weapon/reagent_containers/food/snacks/candy = 2,\
				/obj/item/weapon/reagent_containers/food/snacks/tastybread = 2,\
				/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 2,\
				/obj/item/weapon/reagent_containers/food/snacks/liquidfood = 4,
				/obj/item/weapon/reagent_containers/food/snacks/donkpocket/sinpocket = 1))

/obj/random/rations/low_chance
	name = "low chance preserved rations"
	icon_state = "food-green-low"
	spawn_nothing_percentage = 60


/obj/random/junkfood
	name = "random junkfood"
	icon_state = "food-red"

/obj/random/junkfood/item_to_spawn()
	return pickweight(list(/obj/item/weapon/reagent_containers/food/snacks/chips = 3,
				/obj/item/weapon/reagent_containers/food/snacks/candy = 3,
				/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 3,
				/obj/item/weapon/reagent_containers/food/snacks/tastybread = 3,
				/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 3,
				/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 3,
				/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 2,
				/obj/item/weapon/reagent_containers/food/snacks/hotdog = 1,
				/obj/item/weapon/reagent_containers/food/snacks/liquidfood = 2,
				/obj/item/weapon/reagent_containers/food/snacks/pie = 1,
				/obj/item/weapon/reagent_containers/food/snacks/sandwich = 1))

/obj/random/junkfood/low_chance
	name = "low chance junkfood"
	icon_state = "food-red-low"
	spawn_nothing_percentage = 60


/obj/random/pizza
	name = "random pizza"
	icon_state = "food-red"

/obj/random/pizza/item_to_spawn()
	return pickweight(list(/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita = 1,
				/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza = 1,
				/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza = 1,
				/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza = 1))

/obj/random/pizza/low_chance
	name = "low chance pizza"
	icon_state = "food-red-low"
	spawn_nothing_percentage = 60


/obj/random/soda
	name = "random soda"
	icon_state = "food-red"

/obj/random/soda/item_to_spawn()
	return pickweight(list(/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/starkist = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/lemon_lime = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/tonic = 1,
				/obj/item/weapon/reagent_containers/food/drinks/cans/sodawater = 1))

/obj/random/soda/low_chance
	name = "low chance soda"
	icon_state = "food-red-low"
	spawn_nothing_percentage = 60


/obj/random/junkfood/rotten
	name = "random spoiled food"
	icon_state = "food-red"
	has_postspawn = TRUE

/obj/random/junkfood/rotten/low_chance
	name = "low chance spoiled food"
	icon_state = "food-red-low"
	spawn_nothing_percentage = 60

/obj/random/junkfood/rotten/post_spawn(list/spawns)
	for(var/obj/item/weapon/reagent_containers/food in spawns)
		if(!food.reagents)
			return
		if(prob(80))
			food.reagents.add_reagent("toxin", 25)
		if(prob(30)) // So sometimes the rot is visible.
			food.make_old()
	return spawns
