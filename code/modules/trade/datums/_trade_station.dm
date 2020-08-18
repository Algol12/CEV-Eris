/datum/trade_station
	var/name
	var/desc
	var/list/icon_states = "station"
	var/offer_type
	var/offer_price
	var/offer_amount

	var/spawn_always = FALSE
	var/spawn_probability = 30
	var/spawn_cost = 1
	var/start_discovered = FALSE
	var/max_missing_assortiment = 0
	var/list/linked_with //trade 'stations' or 'station' that must spawn with //list or path

	var/list/forced_overmap_zone //list(list(minx, maxx), list(miny, maxy))
	var/ovemap_opacity = 0

	var/list/name_pool = list()

	var/list/assortiment = list()
	var/list/offer_types = list()


	var/obj/effect/overmap_event/overmap_object
	var/turf/overmap_location

/datum/trade_station/New(init_on_new)
	. = ..()
	if(init_on_new)
		init_src()

/datum/trade_station/proc/init_src()
	if(name)
		crash_with("Some retard gived trade station a name before init_src, not thought name_pool. ([type])")
	for(var/datum/trade_station/S in SStrade.all_stations)
		name_pool.Remove(S.name)
		if(!length(name_pool))
			warning("Trade station name pool exhausted: [type]")
			name_pool = S.name_pool
			break
	name = pick(name_pool)
	desc = name_pool[name]

	var/removed = rand(0, max_missing_assortiment)
	while(removed-- && recursiveLen(assortiment))
		var/list/cur2remove = assortiment[pick(assortiment)]
		if(islist(cur2remove))
			cur2remove -= pick(cur2remove)

	offer_tick()
	var/x = 1
	var/y = 1
	if(recursiveLen(forced_overmap_zone) == 6)
		x = rand(forced_overmap_zone[1][1], forced_overmap_zone[1][2])
		y = rand(forced_overmap_zone[2][1], forced_overmap_zone[2][2])
	else
		x = rand(OVERMAP_EDGE, GLOB.maps_data.overmap_size)
		y = rand(OVERMAP_EDGE, GLOB.maps_data.overmap_size)
	place_overmap(min(x, GLOB.maps_data.overmap_size - OVERMAP_EDGE), min(y, GLOB.maps_data.overmap_size - OVERMAP_EDGE))

	SStrade.all_stations += src
	if(start_discovered)
		SStrade.discovered_stations += src

/datum/trade_station/proc/cost_trade_stations_budget(budget = spawn_cost)
	SStrade.trade_stations_budget -= budget
/datum/trade_station/proc/regain_trade_stations_budget(budget = spawn_cost)
	SStrade.trade_stations_budget += budget
/datum/trade_station/Destroy()
	SStrade.all_stations -= src
	SStrade.discovered_stations -= src
	qdel(overmap_location)
	return ..()

/datum/trade_station/proc/place_overmap(x, y, z = GLOB.maps_data.overmap_z)
	overmap_location = locate(x, y, z)

	overmap_object = new(overmap_location)
	overmap_object.name = name
	overmap_object.icon_state = pick(icon_states) //placeholder
	overmap_object.opacity = ovemap_opacity

	if(!start_discovered)
		GLOB.entered_event.register(overmap_location, src, .proc/discovered)

/datum/trade_station/proc/discovered(_, obj/effect/overmap/ship/ship)
	if(!istype(ship) || !ship.base)
		return

	SStrade.discovered_stations |= src
	GLOB.entered_event.unregister(overmap_location, src, .proc/discovered)

#define SPECIAL_OFFER_MIN_PRICE 200
#define SPECIAL_OFFER_MAX_PRICE 20000

#define spec_offer_price_custom_mod (isnum(offer_types[offer_type]) ? offer_types[offer_type] : 1)

/datum/trade_station/proc/generate_offer()
	if(!length(offer_types))
		return
	offer_type = pick(offer_types)
	var/atom/movable/AM = offer_type

	var/min_amt = round(SPECIAL_OFFER_MIN_PRICE / (max(1, initial(AM.price_tag))) + 1)
	var/max_amt = round(SPECIAL_OFFER_MAX_PRICE / (max(1, initial(AM.price_tag))))
	offer_amount = rand(min_amt, max_amt)

	var/min_price = clamp(offer_amount * max(1, initial(AM.price_tag)) * spec_offer_price_custom_mod, SPECIAL_OFFER_MIN_PRICE, SPECIAL_OFFER_MAX_PRICE)
	var/max_price = clamp(offer_amount * max(1, initial(AM.price_tag)) * spec_offer_price_custom_mod, min_price, SPECIAL_OFFER_MAX_PRICE)
	offer_price = rand(min_price, max_price)

#undef spec_offer_price_custom_mod
/datum/trade_station/proc/offer_tick()
	generate_offer()
