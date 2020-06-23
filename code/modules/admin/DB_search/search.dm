ADMIN_VERB_ADD(/datum/DB_search/verb/new_search, R_ADMIN, FALSE)
/datum/DB_search
	var/datum/browser/panel


/datum/DB_search/verb/new_search()
	set category = "Admin"
	set name = "Search Panel"
	set desc = "Search players in the DB"
	db_search.DB_players_search()



/datum/DB_search/proc/DB_players_search()

	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "\red Failed to establish database connection")
		return

	var/output = {"
<div align='center'>
	<form action='byond://'><table width='60%'><td colspan='3' align='center'>
		<input type='hidden' name='src' value='\ref[src]'>
		<b>Search:</b>
		<table width='90%'>
			<tr>
			<td align='right'><b>Ckey:</b> <input type='text' name='dbsearchckey_search'></td>
			<td align='right'><b>IP:</b> <input type='text' name='dbsearchip_search'></td>
			<td align='right'><b>CID:</b> <input type='text' name='dbsearchcid_search'></td></tr>
			<br>
				<input type='submit' value='search'>
			<br>
		<table>
		<hr>
	</form>
	<table border='1'>
	<tr>
		<th>CKey</th>
		<th>IP</th>
		<th>CID</th>
		<th>last online</th>
	</tr>"}

	panel = new(usr, "Search","Search", 500, 650)
	panel.set_content(output)
	panel.open()

/datum/DB_search/Topic(href, href_list[])
	. = ..()
	var/datum/DB_search/hsrc = locate(href_list["src"])
	var/dbsearchckey_search = lowertext(href_list["dbsearchckey_search"])
	var/dbsearchip_search = href_list["dbsearchip_search"]
	var/dbsearchcid_search = href_list["dbsearchcid_search"]
	var/output
	if(dbsearchckey_search || dbsearchip_search || dbsearchcid_search)
		var/DBQuery/search_query = dbcon.NewQuery("SELECT ckey, ip, cid, last_seen FROM players WHERE ckey = '[dbsearchckey_search]' OR ip = '[dbsearchip_search]' OR cid = '[dbsearchcid_search]'")
		search_query.Execute()
		while(search_query.NextRow())
			output = "<tr><th>[search_query.item[1]]</th><th>[search_query.item[2]]</th><th>[search_query.item[3]]</th><th>[search_query.item[4]]</th></tr>"
			hsrc.panel.add_content(output)
		hsrc.panel.open()
	return