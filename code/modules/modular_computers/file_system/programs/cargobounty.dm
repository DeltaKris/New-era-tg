/datum/computer_file/program/bounty
	filename = "bounty"
	filedesc = "Nanotrasen Bounty Hunter"
	program_icon_state = "bounty"
	extended_desc = "A basic interface for supply personnel to check and claim bounties."
	requires_ntnet = TRUE
	transfer_access = ACCESS_CARGO
	size = 10
	tgui_id = "NtosBountyConsole"
	///cooldown var for printing paper sheets.
	COOLDOWN_DECLARE(printer_cooldown)
	///The cargo account for grabbing the cargo account's credits.
	var/static/datum/bank_account/cargocash

/datum/computer_file/program/bounty/proc/print_paper()
	new /obj/item/paper/bounty_printout(get_turf(computer))

/datum/computer_file/program/bounty/ui_interact(mob/user, datum/tgui/ui)	//Cashes in the bounty if valid
	if(!GLOB.bounties_list.len)
		setup_bounties()
	cargocash = SSeconomy.get_dep_account(ACCOUNT_CAR)
	. = ..()

/datum/computer_file/program/bounty/ui_data(mob/user)		//Gets all bounties and displays them
	var/list/data = get_header_data()
	var/list/bountyinfo = list()
	for(var/datum/bounty/B in GLOB.bounties_list)
		bountyinfo += list(list("name" = B.name, "description" = B.description, "reward_string" = B.reward_string(), "completion_string" = B.completion_string() , "claimed" = B.claimed, "can_claim" = B.can_claim(), "priority" = B.high_priority, "bounty_ref" = REF(B)))
	data["stored_cash"] = cargocash.account_balance
	data["bountydata"] = bountyinfo
	return data

/datum/computer_file/program/bounty/ui_act(action,params)	//When a button is clicked (claim or Print bounties)
	. = ..()
	if(.)
		return
	switch(action)
		if("ClaimBounty")
			var/datum/bounty/cashmoney = locate(params["bounty"]) in GLOB.bounties_list
			if(cashmoney)
				cashmoney.claim()
			return TRUE
		if("Print")
			if(COOLDOWN_FINISHED(src, printer_cooldown))
				COOLDOWN_START(src, printer_cooldown, PRINTER_TIMEOUT)
				print_paper()
				return
			else
				to_chat(computer.loc, "<span class='warning'>The printer is not ready to print yet!</span>")
