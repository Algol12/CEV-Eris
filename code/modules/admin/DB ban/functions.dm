//Either pass the mob you wish to ban in the 'banned_mob' attribute, or the banckey, banip and bancid variables. If both are passed, the mob takes priority! If a mob is not passed, banckey is the minimum that needs to be passed! banip and bancid are optional.
datum/admins/proc/DB_ban_record(var/bantype, var/mob/banned_mob, var/duration = -1, var/reason, var/job = "", var/banckey = null, var/banip = null, var/bancid = null)

	if(!check_rights(R_MOD,0) && !check_rights(R_BAN))	return

	establish_db_connection()
	if(!dbcon.IsConnected())
		if(banned_mob.ckey)
			message_admins("<font color='red'>[key_name_admin(usr)] attempted to ban [banned_mob.ckey], but somehow server could not establish a database connection.</font>",1)
		else
			message_admins("<font color='red'>[key_name_admin(usr)] attempted to ban someone, but somehow server could not establish a database connection.</font>",1)
		return

	var/server = "[world.internet_address]:[world.port]"
	var/bantype_pass = 0
	var/bantype_str
	switch(bantype)
		if(BANTYPE_PERMA)
			bantype_str = "PERMABAN"
			duration = -1
			bantype_pass = 1
		if(BANTYPE_TEMP)
			bantype_str = "TEMPBAN"
			bantype_pass = 1
		if(BANTYPE_JOB_PERMA)
			bantype_str = "JOB_PERMABAN"
			duration = -1
			bantype_pass = 1
		if(BANTYPE_JOB_TEMP)
			bantype_str = "JOB_TEMPBAN"
			bantype_pass = 1
	if( !bantype_pass ) return
	if( !istext(reason) ) return
	if( !isnum(duration) ) return

	var/ckey
	var/computerid
	var/ip

	var/target_id
	var/banned_by_id

	var/DBQuery/query

	if(ismob(banned_mob))
		ckey = banned_mob.ckey
		if(banned_mob.client)
			computerid = banned_mob.client.computer_id
			ip = banned_mob.client.address
			target_id = banned_mob.client.id
	else if(banckey)
		ckey = ckey(banckey)
		computerid = bancid
		ip = banip

	if(!target_id)
		query = dbcon.NewQuery("SELECT id FROM players WHERE ckey = '[ckey]'")
		query.Execute()
		if(!query.NextRow())
			if(!banned_mob || (banned_mob && !IsGuestKey(banned_mob.key)))
				message_admins("<font color='red'>[key_name_admin(usr)] attempted to ban [ckey], but [ckey] has not been seen yet.</font>",1)
				return

		target_id = query.item[1]

	banned_by_id = usr.client.id
	if(!banned_by_id)
		query = dbcon.NewQuery("SELECT id FROM players WHERE ckey = '[usr.ckey]'")
		query.Execute()
		if(!query.NextRow())
			message_admins("<font color='red'>[key_name_admin(usr)] attempted to ban [ckey], but somehow [key_name_admin(usr)] record does not exist in database.</font>",1)
			return
		banned_by_id = query.item[1]

	reason = sql_sanitize_text(reason)

	var/sql = "INSERT INTO bans (target_id, time, server, type, reason, job, duration, expiration_time, cid, ip, banned_by_id) VALUES ([target_id], Now(), '[server]', '[bantype_str]', '[reason]', '[job]', [(duration)?"[duration]":"0"], Now() + INTERVAL [(duration>0) ? duration : 0] MINUTE, '[computerid]', '[ip]', [banned_by_id])"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()
	usr << "\blue Ban saved to database."
	message_admins("[key_name_admin(usr)] has added a [bantype_str] for [ckey] [(job)?"([job])":""] [(duration > 0)?"([duration] minutes)":""] with the reason: \"[reason]\" to the ban database.",1)


datum/admins/proc/DB_ban_unban(var/ckey, var/bantype, var/job = "")

	if(!check_rights(R_BAN))	return

	establish_db_connection()
	if(!dbcon.IsConnected())
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to unban [ckey], but somehow server could not establish a database connection.</font>",1)
		return

	var/bantype_str
	if(bantype)
		var/bantype_pass = 0
		switch(bantype)
			if(BANTYPE_PERMA)
				bantype_str = "PERMABAN"
				bantype_pass = 1
			if(BANTYPE_TEMP)
				bantype_str = "TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_JOB_PERMA)
				bantype_str = "JOB_PERMABAN"
				bantype_pass = 1
			if(BANTYPE_JOB_TEMP)
				bantype_str = "JOB_TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_ANY_FULLBAN)
				bantype_str = "ANY"
				bantype_pass = 1
		if( !bantype_pass ) return

	var/bantype_sql
	if(bantype_str == "ANY")
		bantype_sql = "(type = 'PERMABAN' OR (type = 'TEMPBAN' AND expiration_time > Now() ) )"
	else
		bantype_sql = "type = '[bantype_str]'"

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM players WHERE ckey = '[ckey]'")
	query.Execute()
	if(!query.NextRow())
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to unban [ckey], but [ckey] has not been seen yet.</font>",1)
		return
	var/target_id = query.item[1]

	var/sql = "SELECT id FROM bans WHERE target_id = [target_id] AND [bantype_sql] AND (unbanned is null OR unbanned = false)"
	if(job)
		sql += " AND job = '[job]'"

	var/ban_id
	var/ban_number = 0 //failsafe

	query = dbcon.NewQuery(sql)
	query.Execute()
	while(query.NextRow())
		ban_id = query.item[1]
		ban_number++;

	if(ban_number == 0)
		usr << "\red Database update failed due to no bans fitting the search criteria. If this is not a legacy ban you should contact the database admin."
		return

	if(ban_number > 1)
		usr << "\red Database update failed due to multiple bans fitting the search criteria. Note down the ckey, job and current time and contact the database admin."
		return

	if(istext(ban_id))
		ban_id = text2num(ban_id)
	if(!isnum(ban_id))
		usr << "\red Database update failed due to a ban ID mismatch. Contact the database admin."
		return

	DB_ban_unban_by_id(ban_id)

datum/admins/proc/DB_ban_edit(var/banid = null, var/param = null)

	if(!check_rights(R_BAN))	return

	establish_db_connection()
	if(!dbcon.IsConnected())
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to edit ban record with id [banid], but somehow server could not establish a database connection.</font>",1)
		return

	if(!isnum(banid) || !istext(param))
		usr << "Cancelled"
		return

	var/target_id
	var/ckey
	var/duration
	var/reason

	var/DBQuery/query = dbcon.NewQuery("SELECT target_id, duration, reason FROM bans WHERE id = [banid]")
	query.Execute()
	if(query.NextRow())
		target_id = query.item[1]
		duration = query.item[2]
		reason = query.item[3]
	else
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to edit ban record with id [banid], but matching record does not exist in databse.</font>",1)
		return

	query = dbcon.NewQuery("SELECT ckey FROM players WHERE id = [target_id]")
	query.Execute()
	if(!query.NextRow())
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to edit [ckey]'s ban, but [ckey] has not been seen yet.</font>",1)
		return
	ckey = query.item[1]

	reason = sql_sanitize_text(reason)
	var/value

	switch(param)
		if("reason")
			if(!value)
				value = sanitize(input("Insert the new reason for [ckey]'s ban", "New Reason", "[reason]", null) as null|text)
				value = sql_sanitize_text(value)
				if(!value)
					usr << "Cancelled"
					return
			var/DBQuery/update_query = dbcon.NewQuery("UPDATE bans SET reason = '[value]', WHERE id = [banid]")
			update_query.Execute()
			message_admins("[key_name_admin(usr)] has edited a ban for [ckey]'s reason from [reason] to [value]",1)

		if("duration")
			if(!value)
				value = input("Insert the new duration (in minutes) for [ckey]'s ban", "New Duration", "[duration]", null) as null|num
				if(!isnum(value) || !value)
					usr << "Cancelled"
					return
			var/DBQuery/update_query = dbcon.NewQuery("UPDATE bans SET duration = [value], expiration_time = DATE_ADD(time, INTERVAL '[value]' MINUTE) WHERE id = [banid]")
			update_query.Execute()
			message_admins("[key_name_admin(usr)] has edited a ban for [ckey]'s duration from [duration] to [value]",1)

		if("unban")
			if(alert("Unban [ckey]?", "Unban?", "Yes", "No") == "Yes")
				DB_ban_unban_by_id(banid)
				return
			else
				usr << "Cancelled"
				return
		else
			usr << "Cancelled"
			return

datum/admins/proc/DB_ban_unban_by_id(var/id)

	if(!check_rights(R_BAN))	return

	establish_db_connection()
	if(!dbcon.IsConnected())
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to remove ban record with id [id], but somehow server could not establish a database connection.</font>",1)
		return

	var/ckey

	var/DBQuery/query = dbcon.NewQuery("SELECT target_id FROM bans WHERE id = [id]")
	query.Execute()
	if(query.NextRow())
		ckey = query.item[1]
	else
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to remove ban record with id [id], but record does not exist.</font>",1)
		return

	if(!src.owner || !istype(src.owner, /client))
		return

	query = dbcon.NewQuery("SELECT id FROM players WHERE ckey = '[usr.ckey]'")
	query.Execute()
	if(!query.NextRow())
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to remove ban record with id [id], but admin database record does not exist.</font>",1)
		return
	var/admin_id = query.item[1]

	var/sql_update = "UPDATE bans SET unbanned = true, unbanned_time = Now(), unbanned_by_id = [admin_id], WHERE id = [id]"

	var/DBQuery/query_update = dbcon.NewQuery(sql_update)
	query_update.Execute()
	message_admins("[key_name_admin(usr)] has lifted [ckey]'s ban.",1)


/client/proc/DB_ban_panel()
	set category = "Admin"
	set name = "Banning Panel"
	set desc = "Edit admin permissions"

	if(!holder)
		return

	holder.DB_ban_panel()


/datum/admins/proc/DB_ban_panel(var/playerckey = null, var/adminckey = null, var/playerip = null, var/playercid = null, var/dbbantype = null, var/match = null)
	if(!usr.client)
		return

	if(!check_rights(R_BAN))	return

	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	var/output = "<div align='center'><table width='90%'><tr>"

	output += "<td width='35%' align='center'>"
	output += "<h1>Banning panel</h1>"
	output += "</td>"

	output += "<td width='65%' align='center' bgcolor='#f9f9f9'>"

	output += "<form method='GET' action='?src=\ref[src]'><b>Add custom ban:</b> (ONLY use this if you can't ban through any other method)"
	output += "<input type='hidden' name='src' value='\ref[src]'>"
	output += "<table width='100%'><tr>"
	output += "<td width='50%' align='right'><b>Ban type:</b><select name='dbbanaddtype'>"
	output += "<option value=''>--</option>"
	output += "<option value='[BANTYPE_PERMA]'>PERMABAN</option>"
	output += "<option value='[BANTYPE_TEMP]'>TEMPBAN</option>"
	output += "<option value='[BANTYPE_JOB_PERMA]'>JOB PERMABAN</option>"
	output += "<option value='[BANTYPE_JOB_TEMP]'>JOB TEMPBAN</option>"
	output += "</select></td>"
	output += "<td width='50%' align='right'><b>Ckey:</b> <input type='text' name='dbbanaddckey'></td></tr>"
	output += "<tr><td width='50%' align='right'><b>IP:</b> <input type='text' name='dbbanaddip'></td>"
	output += "<td width='50%' align='right'><b>CID:</b> <input type='text' name='dbbanaddcid'></td></tr>"
	output += "<tr><td width='50%' align='right'><b>Duration:</b> <input type='text' name='dbbaddduration'></td>"
	output += "<td width='50%' align='right'><b>Job:</b><select name='dbbanaddjob'>"
	output += "<option value=''>--</option>"
	for(var/j in get_all_jobs())
		output += "<option value='[j]'>[j]</option>"
	for(var/j in nonhuman_positions)
		output += "<option value='[j]'>[j]</option>"
	var/list/bantypes = list("traitor","changeling","operative","revolutionary","cultist","wizard") //For legacy bans.
	for(var/antag_type in all_antag_types) // Grab other bans.
		var/datum/antagonist/antag = all_antag_types[antag_type]
		bantypes |= antag.bantype
	for(var/j in bantypes)
		output += "<option value='[j]'>[j]</option>"
	output += "</select></td></tr></table>"
	output += "<b>Reason:<br></b><textarea name='dbbanreason' cols='50'></textarea><br>"
	output += "<input type='submit' value='Add ban'>"
	output += "</form>"

	output += "</td>"
	output += "</tr>"
	output += "</table>"

	output += "<form method='GET' action='?src=\ref[src]'><table width='60%'><tr><td colspan='2' align='left'><b>Search:</b>"
	output += "<input type='hidden' name='src' value='\ref[src]'></td></tr>"
	output += "<tr><td width='50%' align='right'><b>Ckey:</b> <input type='text' name='dbsearchckey' value='[playerckey]'></td>"
	output += "<td width='50%' align='right'><b>Admin ckey:</b> <input type='text' name='dbsearchadmin' value='[adminckey]'></td></tr>"
	output += "<tr><td width='50%' align='right'><b>IP:</b> <input type='text' name='dbsearchip' value='[playerip]'></td>"
	output += "<td width='50%' align='right'><b>CID:</b> <input type='text' name='dbsearchcid' value='[playercid]'></td></tr>"
	output += "<tr><td width='50%' align='right' colspan='2'><b>Ban type:</b><select name='dbsearchbantype'>"
	output += "<option value=''>--</option>"
	output += "<option value='[BANTYPE_PERMA]'>PERMABAN</option>"
	output += "<option value='[BANTYPE_TEMP]'>TEMPBAN</option>"
	output += "<option value='[BANTYPE_JOB_PERMA]'>JOB PERMABAN</option>"
	output += "<option value='[BANTYPE_JOB_TEMP]'>JOB TEMPBAN</option>"
	output += "</select></td></tr></table>"
	output += "<br><input type='submit' value='search'><br>"
	output += "<input type='checkbox' value='[match]' name='dbmatch' [match? "checked=\"1\"" : null]> Match(min. 3 characters to search by key or ip, and 7 to search by cid)<br>"
	output += "</form>"
	output += "Please note that all jobban bans or unbans are in-effect the following round.<br>"
	output += "This search shows only last 100 bans."

	if(adminckey || playerckey || playerip || playercid || dbbantype)

		adminckey = ckey(adminckey)
		playerckey = ckey(playerckey)
		playerip = sql_sanitize_text(playerip)
		playercid = sql_sanitize_text(playercid)

		if(adminckey || playerckey || playerip || playercid || dbbantype)

			var/blcolor = "#ffeeee" //banned light
			var/bdcolor = "#ffdddd" //banned dark
			var/ulcolor = "#eeffee" //unbanned light
			var/udcolor = "#ddffdd" //unbanned dark
			var/alcolor = "#eeeeff" // auto-unbanned light
			var/adcolor = "#ddddff" // auto-unbanned dark

			output += "<table width='90%' bgcolor='#e3e3e3' cellpadding='5' cellspacing='0' align='center'>"
			output += "<tr>"
			output += "<th width='25%'><b>TYPE</b></th>"
			output += "<th width='20%'><b>CKEY</b></th>"
			output += "<th width='20%'><b>TIME APPLIED</b></th>"
			output += "<th width='20%'><b>ADMIN</b></th>"
			output += "<th width='15%'><b>OPTIONS</b></th>"
			output += "</tr>"

			var/player_id
			var/DBQuery/query = dbcon.NewQuery("SELECT id, FROM players WHERE ckey='[playerckey]'")
			query.Execute()
			if(query.NextRow())
				player_id = query.item[1]

			var/admin_id
			query = dbcon.NewQuery("SELECT id FROM players WHERE ckey='[adminckey]'")
			query.Execute()
			if(query.NextRow())
				admin_id = query.item[1]

			var/adminsearch = ""
			var/playersearch = ""
			var/ipsearch = ""
			var/cidsearch = ""
			var/bantypesearch = ""

			if(!match)
				if(adminckey)
					adminsearch = "AND banned_by_id = [admin_id] "
				if(playerckey)
					playersearch = "AND target_id = [player_id] "
				if(playerip)
					ipsearch  = "AND ip = '[playerip]' "
				if(playercid)
					cidsearch  = "AND cid = '[playercid]' "
			else
				if(adminckey && lentext(adminckey) >= 3)
					adminsearch = "AND banned_by_id = [admin_id] "
				if(playerckey && lentext(playerckey) >= 3)
					playersearch = "AND target_id = [player_id] "
				if(playerip && lentext(playerip) >= 3)
					ipsearch  = "AND ip LIKE '[playerip]%' "
				if(playercid && lentext(playercid) >= 7)
					cidsearch  = "AND cid LIKE '[playercid]%' "

			if(dbbantype)
				bantypesearch = "AND type = "

				switch(dbbantype)
					if(BANTYPE_TEMP)
						bantypesearch += "'TEMPBAN' "
					if(BANTYPE_JOB_PERMA)
						bantypesearch += "'JOB_PERMABAN' "
					if(BANTYPE_JOB_TEMP)
						bantypesearch += "'JOB_TEMPBAN' "
					else
						bantypesearch += "'PERMABAN' "


			var/DBQuery/select_query = dbcon.NewQuery("SELECT id, time, type, reason, job, duration, expiration_time, target_id, banned_by_id, unbanned, unbanned_by_id, unbanned_time, ip, cid FROM bans WHERE 1 [playersearch] [adminsearch] [ipsearch] [cidsearch] [bantypesearch] ORDER BY time DESC LIMIT 100")
			select_query.Execute()

			var/now = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss") // MUST BE the same format as SQL gives us the dates in, and MUST be least to most specific (i.e. year, month, day not day, month, year)

			while(select_query.NextRow())
				var/banid = select_query.item[1]
				var/bantime = select_query.item[2]
				var/bantype  = select_query.item[3]
				var/reason = select_query.item[4]
				var/job = select_query.item[5]
				var/duration = select_query.item[6]
				var/expiration = select_query.item[7]
				var/target_id = select_query.item[8]
				var/banned_by_id = select_query.item[9]
				var/unbanned = select_query.item[10]
				var/unbanned_by_id = select_query.item[11]
				var/unbantime = select_query.item[12]
				var/edits = select_query.item[13]
				var/ip = select_query.item[14]
				var/cid = select_query.item[15]
				var/target_ckey
				var/banned_by_ckey
				var/unbanned_by_ckey

				query = dbcon.NewQuery("SELECT ckey FROM players WHERE id = [target_id]")
				query.Execute()
				if(query.NextRow())
					target_ckey = query.item[1]

				query = dbcon.NewQuery("SELECT ckey FROM players WHERE id = [banned_by_id]")
				query.Execute()
				if(query.NextRow())
					banned_by_ckey = query.item[1]

				query = dbcon.NewQuery("SELECT ckey FROM players WHERE id = [unbanned_by_id]")
				query.Execute()
				if(query.NextRow())
					unbanned_by_ckey = query.item[1]

				// true if this ban has expired
				var/auto = (bantype in list("TEMPBAN", "JOB_TEMPBAN")) && now > expiration // oh how I love ISO 8601 (ish) date strings

				var/lcolor = blcolor
				var/dcolor = bdcolor
				if(unbanned)
					lcolor = ulcolor
					dcolor = udcolor
				else if(auto)
					lcolor = alcolor
					dcolor = adcolor

				var/typedesc =""
				switch(bantype)
					if("PERMABAN")
						typedesc = "<font color='red'><b>PERMABAN</b></font>"
					if("TEMPBAN")
						typedesc = "<b>TEMPBAN</b><br><font size='2'>([duration] minutes) [(unbanned || auto) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=duration;dbbanid=[banid]\">Edit</a>)"]<br>Expires [expiration]</font>"
					if("JOB_PERMABAN")
						typedesc = "<b>JOBBAN</b><br><font size='2'>([job])</font>"
					if("JOB_TEMPBAN")
						typedesc = "<b>TEMP JOBBAN</b><br><font size='2'>([job])<br>([duration] minutes<br>Expires [expiration]</font>"

				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center'>[typedesc]</td>"
				output += "<td align='center'><b>[target_ckey]</b></td>"
				output += "<td align='center'>[bantime]</td>"
				output += "<td align='center'><b>[banned_by_ckey]</b></td>"
				output += "<td align='center'>[(unbanned || auto) ? "" : "<b><a href=\"byond://?src=\ref[src];dbbanedit=unban;dbbanid=[banid]\">Unban</a></b>"]</td>"
				output += "</tr>"
				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center' colspan='2' bgcolor=''><b>IP:</b> [ip]</td>"
				output += "<td align='center' colspan='3' bgcolor=''><b>CIP:</b> [cid]</td>"
				output += "</tr>"
				output += "<tr bgcolor='[lcolor]'>"
				output += "<td align='center' colspan='5'><b>Reason: [(unbanned || auto) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=reason;dbbanid=[banid]\">Edit</a>)"]</b> <cite>\"[reason]\"</cite></td>"
				output += "</tr>"
				if(edits)
					output += "<tr bgcolor='[dcolor]'>"
					output += "<td align='center' colspan='5'><b>EDITS</b></td>"
					output += "</tr>"
					output += "<tr bgcolor='[lcolor]'>"
					output += "<td align='center' colspan='5'><font size='2'>[edits]</font></td>"
					output += "</tr>"
				if(unbanned)
					output += "<tr bgcolor='[dcolor]'>"
					output += "<td align='center' colspan='5' bgcolor=''><b>UNBANNED by admin [unbanned_by_ckey] on [unbantime]</b></td>"
					output += "</tr>"
				else if(auto)
					output += "<tr bgcolor='[dcolor]'>"
					output += "<td align='center' colspan='5' bgcolor=''><b>EXPIRED at [expiration]</b></td>"
					output += "</tr>"
				output += "<tr>"
				output += "<td colspan='5' bgcolor='white'>&nbsp</td>"
				output += "</tr>"

			output += "</table></div>"

	usr << browse(output,"window=lookupbans;size=900x700")
