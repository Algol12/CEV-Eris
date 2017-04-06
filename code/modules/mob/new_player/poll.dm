/datum/poll_option
	var/id
	var/text

/mob/new_player/proc/handle_player_polling()
	establish_db_connection()
	if(dbcon.IsConnected())
		var/DBQuery/select_query = dbcon.NewQuery("SELECT id, question FROM polls WHERE Now() BETWEEN start AND end")
		select_query.Execute()

		var/output = "<div align='center'><B>Player polls</B>"
		output +="<hr>"

		var/poll_id
		var/poll_question

		output += "<table>"
		var/color1 = "#ececec"
		var/color2 = "#e2e2e2"
		var/i = 0

		while(select_query.NextRow())
			poll_id = select_query.item[1]
			poll_question = select_query.item[2]
			output += "<tr bgcolor='[ (i % 2 == 1) ? color1 : color2 ]'><td><a href=\"byond://?src=\ref[src];poll_id=[poll_id]\"><b>[poll_question]</b></a></td></tr>"
			i++

		output += "</table>"

		src << browse(output,"window=playerpolllist;size=500x300")


/mob/new_player/proc/poll_player(var/poll_id = -1)
	if(poll_id == -1)
		return

	establish_db_connection()
	if(dbcon.IsConnected())

		var/DBQuery/select_query = dbcon.NewQuery("SELECT start, end, question, type, FROM polls WHERE id = [poll_id]")
		select_query.Execute()

		var/start_time = ""
		var/end_time = ""
		var/question = ""
		var/type = ""

		if(select_query.NextRow())
			start_time = select_query.item[1]
			end_time = select_query.item[2]
			question = select_query.item[3]
			type = select_query.item[4]
		else
			usr << "<span class='danger'>Poll question details not found.</span>"
			return

		switch(type)
			//Polls that have enumerated options
			if("OPTION")
				var/DBQuery/voted_query = dbcon.NewQuery("SELECT option_id FROM poll_votes WHERE poll_id = [poll_id] AND player_id = [client.id]")
				voted_query.Execute()

				var/voted = FALSE
				var/voted_option_id = 0
				while(voted_query.NextRow())
					voted_option_id = text2num(voted_query.item[1])
					voted = TRUE
					break

				var/list/datum/poll_option/options = list()

				var/DBQuery/options_query = dbcon.NewQuery("SELECT id, text FROM poll_options WHERE poll_id = [poll_id]")
				options_query.Execute()
				while(options_query.NextRow())
					var/datum/poll_option/option = new()
					option.id = text2num(options_query.item[1])
					option.text = options_query.item[2]
					options.Add(option)

				var/output = "<div align='center'><B>Player poll</B>"
				output +="<hr>"
				output += "<b>Question: [question]</b><br>"
				output += "<font size='2'>Poll runs from <b>[start_time]</b> until <b>[end_time]</b></font><p>"

				if(!voted)	//Only make this a form if we have not voted yet
					output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
					output += "<input type='hidden' name='src' value='\ref[src]'>"
					output += "<input type='hidden' name='poll_id' value='[poll_id]'>"
					output += "<input type='hidden' name='type' value='OPTION'>"

				output += "<table><tr><td>"
				for(var/datum/poll_option/option in options)
					if(option.id && option.text)
						if(voted)
							if(voted_option_id == option.id)
								output += "<b>[option.text]</b><br>"
							else
								output += "[option.text]<br>"
						else
							output += "<input type='radio' name='vote_option_id' value='[option.id]'> [option.text]<br>"
				output += "</td></tr></table>"

				if(!voted)	//Only make this a form if we have not voted yet
					output += "<p><input type='submit' value='Vote'>"
					output += "</form>"

				output += "</div>"

				src << browse(output,"window=playerpoll;size=500x250")

			//Polls with a text input
			if("TEXT")
				var/DBQuery/voted_query = dbcon.NewQuery("SELECT text FROM poll_text_replies WHERE poll_id = [poll_id] AND player_id = [client.id]")
				voted_query.Execute()

				var/voted = FALSE
				var/vote_text = ""
				while(voted_query.NextRow())
					vote_text = voted_query.item[1]
					voted = TRUE
					break

				var/output = "<div align='center'><B>Player poll</B>"
				output +="<hr>"
				output += "<b>Question: [question]</b><br>"
				output += "<font size='2'>Feedback gathering runs from <b>[start_time]</b> until <b>[end_time]</b></font><p>"

				if(!voted)	//Only make this a form if we have not voted yet
					output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
					output += "<input type='hidden' name='src' value='\ref[src]'>"
					output += "<input type='hidden' name='vote_on_poll' value='[poll_id]'>"
					output += "<input type='hidden' name='vote_type' value='TEXT'>"

					output += "<font size='2'>Please provide feedback below. You can use any letters of the English alphabet, numbers and the symbols: . , ! ? : ; -</font><br>"
					output += "<textarea name='reply_text' cols='50' rows='14'></textarea>"

					output += "<p><input type='submit' value='Submit'>"
					output += "</form>"

					output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
					output += "<input type='hidden' name='src' value='\ref[src]'>"
					output += "<input type='hidden' name='vote_on_poll' value='[poll_id]'>"
					output += "<input type='hidden' name='vote_type' value='TEXT'>"
					output += "<input type='hidden' name='reply_text' value='ABSTAIN'>"
					output += "<input type='submit' value='Abstain'>"
					output += "</form>"
				else
					output += "[vote_text]"

				src << browse(output,"window=playerpoll;size=500x500")


/mob/new_player/proc/vote_on_poll(var/poll_id = -1, var/option_id = -1)
	if(poll_id == -1 || option_id == -1)
		return

	if(!isnum(poll_id) || !isnum(option_id))
		return

	establish_db_connection()
	if(dbcon.IsConnected())

		var/DBQuery/select_query = dbcon.NewQuery("SELECT start, end, question, type, FROM polls WHERE id = [poll_id] AND Now() BETWEEN start AND end")
		select_query.Execute()

		if(select_query.NextRow())
			if(select_query.item[4] != "OPTION")
				usr << "<span class='danger'>Invalid poll type.</span>"
				return
		else
			usr << "<span class='danger'>Poll not found.</span>"
			return

		var/DBQuery/select_query2 = dbcon.NewQuery("SELECT id FROM poll_options WHERE id = [option_id] AND poll_id = [poll_id]")
		select_query2.Execute()

		if(!select_query2.NextRow())
			usr << "<span class='warning'>Invalid poll options.</span>"
			return

		var/DBQuery/voted_query = dbcon.NewQuery("SELECT id FROM poll_votes WHERE poll_id = [poll_id] AND player_id = [client.id]")
		voted_query.Execute()

		if(voted_query.NextRow())
			usr << "<span class='warning'>You already voted in this poll.</span>"
			return

		var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO poll_votes (time, option_id, poll_id, player_id) VALUES (Now(), [option_id], [poll_id], [client.id])")
		insert_query.Execute()

		usr << "<span class='notice'>Vote successful.</span>"
		usr << browse(null,"window=playerpoll")


/mob/new_player/proc/log_text_poll_reply(var/poll_id = -1, var/reply_text = "")
	if(poll_id == -1 || reply_text == "")
		return

	if(!isnum(poll_id) || !istext(reply_text))
		return
	establish_db_connection()
	if(dbcon.IsConnected())

		var/DBQuery/select_query = dbcon.NewQuery("SELECT start, end, question, type FROM polls WHERE id = [poll_id] AND Now() BETWEEN start AND end")
		select_query.Execute()

		if(select_query.NextRow() && select_query.item[4] != "TEXT")
			usr << "<span class='warning'>Invalid poll type.</span>"
			return

		var/DBQuery/voted_query = dbcon.NewQuery("SELECT id FROM poll_text_replies WHERE poll_id = [poll_id] AND player_ckey = '[usr.ckey]'")
		voted_query.Execute()

		if(voted_query.NextRow())
			usr << "<span class='warning'>You already sent your feedback for this poll.</span>"
			return

		reply_text = replacetext(reply_text, "%BR%", "")
		reply_text = replacetext(reply_text, "\n", "%BR%")
		var/text_pass = reject_bad_text(reply_text,8000)
		reply_text = replacetext(reply_text, "%BR%", "<BR>")

		if(!text_pass)
			usr << "<span class='warning'>The text you entered was blank, contained illegal characters or was too long. Please correct the text and submit again.</span>"
			return

		var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO poll_text_replies (time, poll_id, player_id, text) VALUES (Now(), [poll_id], [client.id], '[reply_text]')")
		insert_query.Execute()

		usr << "<span class='notice'>Vote successful.</span>"
		usr << browse(null,"window=playerpoll")
