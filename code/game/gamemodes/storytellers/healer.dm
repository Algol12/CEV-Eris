/datum/storyteller/healer
	config_tag = "healer"
	name = "The Healer"
	welcome = "Welcome to CEV Eris! We hope you enjoy your stay!"
	description = "Peaceful and relaxed storyteller who will try to help the crew a little."

	gain_mult_mundane = 1.2
	gain_mult_moderate = 0.8
	gain_mult_major = 0.8
	gain_mult_roleset = 0.8

	repetition_multiplier = 0.9

	//Healer gives you half an hour to setup before any antags
	points = list(
	0, //Mundane
	0, //Moderate
	0, //Major
	90 //Roleset
	)