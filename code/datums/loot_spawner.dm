/datum/loot_spawner_data
	var/list/all_spawn_by_price = list()
	var/list/all_spawn_price_by_path = list()
	var/list/all_spawn_blacklist = list()
	var/list/all_spawn_by_frequency = list()
	var/list/all_spawn_frequency_by_path = list()
	var/list/all_spawn_by_rarity = list()
	var/list/all_spawn_rarity_by_path = list()
	var/list/all_spawn_accompanying_obj_by_path = list()
	var/list/all_spawn_by_tag = list()
	var/list/all_spawn_bad_paths = list()

/datum/loot_spawner_data/New()
	var/list/paths = list()

	//spawn vars
	var/price
	var/rarity
	var/frequency
	var/blacklisted
	var/list/spawn_tags = list()
	var/list/accompanying_objs = list()
	var/list/bad_paths = list()

	//Initialise all items, mobs and machinery
	paths = subtypesof(/obj/item)
	paths += subtypesof(/mob/living)
	paths += subtypesof(/obj/machinery)
	for(var/path in paths)
		var/atom/movable/A = path

		bad_paths = initial(A.bad_types)
		if(istext(bad_paths))
			bad_paths = splittext(bad_paths, ",")
			if(bad_paths.len)
				var/list/temp_list = bad_paths
				bad_paths = list()
				for(var/bad_path_text in temp_list)
					bad_paths += text2path(bad_path_text)
		else if(ispath(bad_paths))
			bad_paths = list(bad_paths)
		if(islist(bad_paths) && bad_paths.len)
			for(var/bad_path in bad_paths)
				if(!ispath(bad_path))
					continue
				if(!(bad_path in all_spawn_bad_paths))
					all_spawn_bad_paths += bad_path

		if(path in all_spawn_bad_paths)
			continue

		frequency = initial(A.spawn_frequency)
		if(!frequency || frequency <= 0)
			continue

		price = initial(A.price_tag)
		rarity = initial(A.rarity_value)
		blacklisted = initial(A.spawn_blacklisted)
		frequency = initial(A.spawn_frequency)
		spawn_tags = splittext(initial(A.spawn_tags), ",")
		accompanying_objs = initial(A.accompanying_object)
		if(istext(accompanying_objs))
			accompanying_objs = splittext(accompanying_objs, ",")
			if(accompanying_objs.len)
				var/list/temp_list = accompanying_objs
				accompanying_objs = list()
				for(var/obj_text in temp_list)
					accompanying_objs += text2path(obj_text)
		else if(ispath(accompanying_objs))
			accompanying_objs = list(accompanying_objs)
		if(islist(accompanying_objs) && accompanying_objs.len)
			for(var/obj_path in accompanying_objs)
				if(!ispath(obj_path))
					continue
				all_spawn_accompanying_obj_by_path[path] += list(obj_path)

		all_spawn_by_price["[price]"] += list(path)
		all_spawn_price_by_path[path] = price
		all_spawn_by_frequency["[frequency]"] += list(path)
		all_spawn_frequency_by_path[path] = frequency
		all_spawn_by_rarity["[rarity]"] += list(path)
		all_spawn_rarity_by_path[path] = rarity
		if(blacklisted)
			all_spawn_blacklist += path
		if(spawn_tags.len)
			for(var/tag in spawn_tags)
				all_spawn_by_tag[tag] += list(path)


/datum/loot_spawner_data/proc/spawn_by_tag(list/tags)
	if(!islist(tags))
		return
	var/list/things = list()
	for(var/tag in tags)
		if(all_spawn_by_tag["[tag]"] in things)
			continue
		things += all_spawn_by_tag["[tag]"]
	return things

/datum/loot_spawner_data/proc/spawns_lower_price(list/paths, price)
	if(!paths || !paths.len || !price)
		return
	var/list/things = list()
	for(var/path in paths)
		if(all_spawn_price_by_path[path] < price)
			things += path
	return things

/datum/loot_spawner_data/proc/spawns_upper_price(list/paths, price)
	if(!paths || !paths.len || !price)
		return
	var/list/things = list()
	for(var/path in paths)
		if(all_spawn_price_by_path[path] > price)
			things += path
	return things

/datum/loot_spawner_data/proc/pick_frequency(list/paths)
	if(!paths || !paths.len)
		return
	var/list/things = list()
	for(var/path in paths)
		var/frequency = all_spawn_frequency_by_path[path]
		if(!frequency)
			continue
		things["[frequency]"] = frequency
	return pickweight(things, 0)

/datum/loot_spawner_data/proc/pick_frequency_spawn(list/paths)
	if(!paths || !paths.len)
		return
	var/list/things = list()
	for(var/path in paths)
		var/frequency_path = all_spawn_frequency_by_path[path]
		things["[frequency_path]"] = frequency_path
	var/frequency = pickweight(things, 0)
	if(istext(frequency))
		frequency = text2num(frequency)
	things = list()
	for(var/path in paths)
		if(all_spawn_frequency_by_path[path] >= frequency)
			things += path
	return things

/datum/loot_spawner_data/proc/pick_rarity_spawn(list/paths)
	if(!paths || !paths.len)
		return
	var/list/things = list()
	for(var/path in paths)
		var/rarity_path = 101-all_spawn_rarity_by_path[path]
		things["[rarity_path]"] = rarity_path
	var/rarity = pickweight(things, 0)
	if(istext(rarity))
		rarity = text2num(rarity)
	rarity = 101-rarity
	things = list()
	for(var/path in paths)
		if(all_spawn_rarity_by_path[path] <= rarity)
			things += path
	return things

