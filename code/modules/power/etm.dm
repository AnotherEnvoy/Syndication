// ETM
// Sells power to Centcom

/obj/machinery/power/etm
	name = "electricity transfer machine"
	desc = "Transmits power over bluespace pathways for sale"
	icon_state = "etm"
	density = TRUE
	use_power = NO_POWER_USE

	var/requested_transmit = 0
	var/max_transmit = 50000
	var/last_transmitted = 0
	var/price_per_watt = 20 / 50000
	var/datum/bank_account/account = null

/obj/machinery/power/etm/Initialize(mapload)
	. = ..()
	connect_to_network()
	account = SSeconomy.get_dep_account(ACCOUNT_ENG)

/obj/machinery/power/etm/process()
	if((stat & BROKEN) || panel_open)
		last_transmitted = 0
		return
	last_transmitted = min(surplus(), requested_transmit)
	add_load(last_transmitted)
	account.adjust_money(price_per_watt * last_transmitted)

/obj/machinery/power/etm/attackby(obj/item/I, mob/user, params)
	//open panel
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_icon()
		return
	//deconstruct
	if(default_deconstruction_crowbar(I))
		return
	//set account
	var/obj/item/card/id/id_card = I.GetID()
	if(panel_open && id_card && user.a_intent == INTENT_HELP)
		if(id_card.bank_support != ID_FREE_BANK_ACCOUNT || !id_card.registered_account)
			say("ERROR: Invalid account")
			return
		user.visible_message(span_notice("[user] begins setting \the [src] to use \the [id_card]."), span_notice("[user] begins setting \the [src] to use \the [id_card]."))
		balloon_alert(user, "Configuring new account...")
		if(!do_after(user, 5 SECONDS, src))
			user.visible_message(span_warning("[user] fails to link \the [src] to a new account!"), span_warning("You fail to link \the [src] to a new account!"))
			balloon_alert(user, "Configuration failed!")
			return
		to_chat(user, span_notice("You link \the [id_card] to \the [src]."))
		var/old_account = account
		account = id_card.registered_account
		say("Now using [account.account_holder ? "[account.account_holder]s" : span_boldwarning("ERROR")] account.")
		log_game("[user] set \the [src] in [get_area(src)] to pay into their personal account. Previous account was [old_account].")
		return
	return ..()

/obj/machinery/power/etm/RefreshParts()
	var/rating = 0
	for(var/obj/item/stock_parts/capacitor/cap in component_parts)
		rating += cap.rating
	//absolute minimum, with 3 tier 1 capacitors, is 50kW max. Maximum is 100MW, with 3 tier 6 capacitors. Interpolates with a cubic.
	max_transmit = ceil((799600 / 27 * ((rating - 3) ** 3) + 50000) / 1000) * 1000
	//handle decrease in part rating
	requested_transmit = clamp(requested_transmit, 0, max_transmit)

/obj/machinery/power/etm/ui_data(mob/user)
	var/list/data = list()
	data["requested"] = requested_transmit
	data["max_transmit"] = max_transmit
	data["transmitted"] = last_transmitted
	data["price"] = price_per_watt
	data["account_holder"] = account.account_holder
	return data

/obj/machinery/power/etm/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Etm", name)
		ui.open()

/obj/machinery/power/etm/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("target")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = max_transmit
				. = TRUE
			else if(adjust)
				target = requested_transmit + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				requested_transmit = clamp(target, 0, max_transmit)
		if("reset_account")
			. = TRUE
			var/mob/user = usr
			user.visible_message(span_warning("[user] begins resetting \the [src]."), span_warning("You begin resetting \the [src]."))
			balloon_alert(user, "Resetting account...")
			if(!do_after(user, 5 SECONDS, src))
				user.visible_message(span_warning("[user] fails to reset \the [src]."), span_warning("You fail to reset \the [src]."))
				balloon_alert(user, "Reset failed!")
				return
			var/old_account = account
			account = SSeconomy.get_dep_account(ACCOUNT_ENG)
			say("Now using [account.account_holder]s account.")
			log_game("[user] reset the \the [src] in [get_area(src)] to pay Engineering's departmental account. Previous account was [old_account]")
