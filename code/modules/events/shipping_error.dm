/datum/event/shipping_error/start()
	var/datum/supply_order/O = new /datum/supply_order()
	O.ordernum = SSsupply.ordernum
	O.object = SSsupply.supply_packs[pick(SSsupply.supply_packs)]
	O.orderedby = random_name(pick(MALE,FEMALE), species = "Human")
	SSsupply.shoppinglist += O
