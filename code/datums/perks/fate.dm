#define PERK_PAPER_WORM /datum/perk/paper_worm
#define PERK_FREELACER /datum/perk/freelancer
#define PERK_NIHILIST /datum/perk/nihilist
#define PERK_MORALIST /datum/perk/moralist
#define PERK_ALCOHOLIC /datum/perk/alcoholic
#define PERK_ALCOHOLIC_ACTIVE /datum/perk/alcoholic_active
#define PERK_DRUG_ADDICT /datum/perk/drug_addict
#define PERK_NOBLE /datum/perk/noble
#define PERK_RAT /datum/perk/rat
#define PERK_REJECTED_GENIUS /datum/perk/rejected_genius
#define PERK_OBORIN_SYNDROME /datum/perk/oborin_syndrome
#define PERK_LOWBORN /datum/perk/lowborn

/datum/perk/paper_worm
	name = "Paper Worms"
	icon_state = "paper"

/datum/perk/paper_worm/assign(mob/living/carbon/human/H)
	..()
	holder.sanity.positive_prob += 20
	holder.sanity.view_damage_threshold += 1000

/datum/perk/paper_worm/remove()
	holder.sanity.positive_prob -= 20
	holder.sanity.view_damage_threshold -= 1000
	..()

/datum/perk/freelancer
	name = "Freelancer"
	icon_state = "skills"

/datum/perk/freelancer/assign(mob/living/carbon/human/H)
	..()
	var/maxstatindex
	for (var/i=1 to holder.stats.stat_list.len-1)
		if(holder.stats.getStat(holder.stats.stat_list[i]) > holder.stats.getStat(holder.stats.stat_list[i+1]))
			maxstatindex = i
		else
			maxstatindex = i+1
	for(var/name in holder.stats.stat_list)
		if(name != holder.stats.stat_list[maxstatindex])
			holder.stats.addTempStat(name, 4, INFINITY, "Fate Freelancer")
		else
			holder.stats.addTempStat(name, -10, INFINITY, "Fate Freelancer")

/datum/perk/freelancer/remove()
	holder.stats.removeTempStat(STAT_MEC, "Fate Freelancer")
	holder.stats.removeTempStat(STAT_COG, "Fate Freelancer")
	holder.stats.removeTempStat(STAT_BIO, "Fate Freelancer")
	holder.stats.removeTempStat(STAT_ROB, "Fate Freelancer")
	holder.stats.removeTempStat(STAT_TGH, "Fate Freelancer")
	holder.stats.removeTempStat(STAT_VIG, "Fate Freelancer")
	..()

/datum/perk/nihilist
	name = "Nihilist"
	icon_state = "nihilist" //https://game-icons.net/1x1/lorc/tear-tracks.html

/datum/perk/nihilist/assign(mob/living/carbon/human/H)
	..()
	holder.sanity.positive_prob += 10
	holder.sanity.negative_prob += 20

/datum/perk/nihilist/remove()
	holder.sanity.positive_prob -= 10
	holder.sanity.negative_prob -= 20
	holder.stats.removeTempStat(STAT_COG, "Fate Nihilist")
	..()

/datum/perk/moralist
	name = "Moralist."
	icon_state = "moralist" //https://game-icons.net/

/datum/perk/drug_addict
	name = "Drug Addict."
	icon_state = "medicine" //https://game-icons.net/1x1/delapouite/medicines.html

/datum/perk/drug_addict/assign(mob/living/carbon/human/H)
	..()
	var/turf/T = get_turf(holder)
	var/drugtype = pick(subtypesof(/datum/reagent/drug))
	if(!(drugtype in holder.metabolism_effects.addiction_list))
		var/datum/reagent/drug = new drugtype
		holder.metabolism_effects.addiction_list.Add(drug)
		var/obj/item/weapon/storage/pill_bottle/PB = new /obj/item/weapon/storage/pill_bottle(T)
		PB.name = "bottle of happiness"
		for(var/i=1 to 7)
			var/obj/item/weapon/reagent_containers/pill/pill = new /obj/item/weapon/reagent_containers/pill(T)
			pill.reagents.add_reagent(drug.id, pill.volume)
			pill.name = "happy pill"
			PB.handle_item_insertion(pill)
		holder.put_in_hands(PB)

/datum/perk/alcoholic
	name = "Alcoholic"
	icon_state = "beer" //https://game-icons.net/1x1/delapouite/beer-bottle.html

/datum/perk/alcoholic/assign(mob/living/carbon/human/H)
	..()
	var/ethanoltype = pick(subtypesof(/datum/reagent/ethanol))
	if(!(ethanoltype in holder.metabolism_effects.addiction_list))
		var/datum/reagent/alcohol = new ethanoltype
		holder.metabolism_effects.addiction_list.Add(alcohol)

/datum/perk/alcoholic_active
	name = "Alcoholic (active)"
	icon_state = "drinking" //https://game-icons.net/1x1/delapouite/drinking.html

/datum/perk/alcoholic_active/assign(mob/living/carbon/human/H)
	..()
	holder.stats.addTempStat(STAT_ROB, 10, INFINITY, "Fate Alcoholic")

/datum/perk/alcoholic_active/remove()
	holder.stats.addTempStat(STAT_ROB, "Fate Alcoholic")
	..()


/datum/perk/noble
	name = "Noble"
	icon_state = "family" //https://game-icons.net

/datum/perk/noble/assign(mob/living/carbon/human/H)
	..()
	if(!holder.last_name)
		qdel(src)
	var/turf/T = get_turf(holder)
	var/obj/item/W = pickweight(list(/obj/item/weapon/tool/knife/butterfly = 1,
				/obj/item/weapon/tool/knife/switchblade = 1,
				/obj/item/weapon/tool/knife = 1,
				/obj/item/weapon/tool/knife/boot = 0.5,
				/obj/item/weapon/tool/knife/hook = 2,
				/obj/item/weapon/tool/knife/ritual = 0.5,
				/obj/item/weapon/tool/scythe = 0.3,
				/obj/item/weapon/tool/sword = 0.2,
				/obj/item/weapon/tool/sword/katana = 0.2,
				/obj/item/weapon/tool/knife/butch = 2,
				/obj/item/weapon/tool/knife/dagger = 0.8))
	W = new W(T)
	W.name = "[holder.last_name] family [W.name]"
	holder.put_in_hands(W)

/datum/perk/rat
	name = "rat"
	desc = " In your life you decided to feast upon what’s not yours, be that thief, raiding, or scavenging and exploring. It’s all the same no matter how you name it, after all. You know the ways of infiltrating, salvaging, and getting away with the loot."
	icon_state = "rat"

/datum/perk/rat/assign(mob/living/carbon/human/H)
	..()
	holder.sanity.max_level -= 10

/datum/perk/rat/remove()
	holder.sanity.max_level += 10
	..()

/datum/perk/rejected_genius
	name = "rejected genius"
	icon_state = "knowledge"

/datum/perk/rejected_genius/assign(mob/living/carbon/human/H)
	..()
	holder.sanity.positive_prob_multiplier -= 1
	holder.sanity.insight_passive_gain_multiplier *= 1.5
	holder.sanity.max_level -= 20

/datum/perk/rejected_genius/remove()
	holder.sanity.positive_prob_multiplier += 1
	holder.sanity.insight_passive_gain_multiplier /= 1.5
	holder.sanity.max_level += 20
	..()

/datum/perk/oborin_syndrome
	name = "Oborin Syndrome" //https://game-icons.net



/datum/perk/lowborn
	name = "lowborn"
	icon_state = "ladder" //https://game-icons.net/1x1/delapouite/hole-ladder.html
