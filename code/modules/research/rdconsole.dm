
/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter. (not anymore)

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The only thing that requires toxins access is locking and unlocking the console on the settings menu.
Nothing else in the console has ID requirements.

*/
/obj/machinery/computer/rdconsole
	name = "Research Trading Console"
	desc = "A console used to interface with R&D tools."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	var/datum/techweb/stored_research					//Reference to global science techweb.
	var/obj/item/disk/tech_disk/t_disk	//Stores the technology disk.
	var/obj/item/disk/design_disk/d_disk	//Stores the design disk.
	circuit = /obj/item/circuitboard/computer/rdconsole

	var/obj/machinery/rnd/destructive_analyzer/linked_destroy	//Linked Destructive Analyzer
	var/obj/machinery/rnd/production/protolathe/linked_lathe				//Linked Protolathe
	var/obj/machinery/rnd/production/circuit_imprinter/linked_imprinter	//Linked Circuit Imprinter

	req_access = list(ACCESS_TOX)	//lA AND SETTING MANIPULATION REQUIRES SCIENTIST ACCESS.

	var/research_control = TRUE

	/// Long action cooldown to prevent spam
	var/last_long_action = 0

/obj/machinery/computer/rdconsole/ui_static_data(mob/user)
	var/list/data = list()
	var/list/nodes = list()
	for(var/id in SSresearch.techweb_nodes)
		var/list/nodedata = list()
		var/datum/techweb_node/node = SSresearch.techweb_nodes[id]
		nodedata["name"] = node.display_name
		nodedata["description"] = node.description
		nodedata["prereq_ids"] = node.prereq_ids
		nodedata["design_ids"] = node.design_ids
		nodedata["unlock_ids"] = node.unlock_ids
		nodedata["category"] = node.category
		nodedata["cost"] = node.research_costs
		nodes[id] = nodedata
	data["nodes"] = nodes
	var/list/designs = list()
	var/datum/asset/spritesheet/icons = get_asset_datum(/datum/asset/spritesheet/research_designs)
	for(var/id in SSresearch.techweb_designs)
		var/list/designdata = list()
		var/datum/design/design = SSresearch.techweb_designs[id]
		designdata["name"] = design.name
		designdata["icon"] = icons.icon_class_name(id)
		designs[id] = designdata
	data["designs"] = designs
	return data

/obj/machinery/computer/rdconsole/ui_data(mob/user)
	var/list/data = list()
	data["credits"] = stored_research.budget.account_balance
	data["visible_nodes"] = stored_research.visible_nodes
	data["researched_nodes"] = stored_research.researched_nodes
	data["available_nodes"] = stored_research.available_nodes
	data["has_destroy"] = linked_destroy != null
	data["has_lathe"] = linked_lathe != null
	data["has_imprinter"] = linked_imprinter != null
	data["research_logs"] = stored_research.research_logs
	return data

/obj/machinery/computer/rdconsole/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "research")
		research_node(params["nodeID"], usr)
	if(action == "sync")
		SyncRDevices()
		say("Resynced with nearby devices.")
	if(action == "disconnect")
		switch(params["device"])
			if("destroy")
				if(QDELETED(linked_destroy))
					say("No Destructive Analyzer Linked!")
					return
				linked_destroy.linked_console = null
				linked_destroy = null
			if("lathe")
				if(QDELETED(linked_lathe))
					say("No Protolathe Linked!")
					return
				linked_lathe.linked_console = null
				linked_lathe = null
			if("imprinter")
				if(QDELETED(linked_imprinter))
					say("No Circuit Imprinter Linked!")
					return
				linked_imprinter.linked_console = null
				linked_imprinter = null
	return TRUE

/obj/machinery/computer/rdconsole/production
	circuit = /obj/item/circuitboard/computer/rdconsole/production
	research_control = FALSE

/proc/CallMaterialName(ID)
	if (istype(ID, /datum/material))
		var/datum/material/material = ID
		return material.name

	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return ID

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/rnd/D in oview(3,src))
		if(D.linked_console != null || D.disabled || D.panel_open)
			continue
		if(istype(D, /obj/machinery/rnd/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/production/protolathe))
			if(linked_lathe == null)
				var/obj/machinery/rnd/production/protolathe/P = D
				if(!P.console_link)
					continue
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/production/circuit_imprinter))
			if(linked_imprinter == null)
				var/obj/machinery/rnd/production/circuit_imprinter/C = D
				if(!C.console_link)
					continue
				linked_imprinter = D
				D.linked_console = src

/obj/machinery/computer/rdconsole/Initialize(mapload)
	. = ..()
	stored_research = SSresearch.science_tech
	stored_research.consoles_accessing[src] = TRUE
	SyncRDevices()

/obj/machinery/computer/rdconsole/Destroy()
	if(stored_research)
		stored_research.consoles_accessing -= src
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	if(t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null
	if(d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	return ..()

/obj/machinery/computer/rdconsole/attackby(obj/item/D, mob/user, params)
	//Loading a disk into it.
	if(istype(D, /obj/item/disk))
		if(istype(D, /obj/item/disk/tech_disk))
			if(t_disk)
				to_chat(user, "<span class='danger'>A technology disk is already loaded!</span>")
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, "<span class='danger'>[D] is stuck to your hand!</span>")
				return
			t_disk = D
		else if (istype(D, /obj/item/disk/design_disk))
			if(d_disk)
				to_chat(user, "<span class='danger'>A design disk is already loaded!</span>")
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, "<span class='danger'>[D] is stuck to your hand!</span>")
				return
			d_disk = D
		else
			to_chat(user, "<span class='danger'>Machine cannot accept disks in that format.</span>")
			return
		to_chat(user, "<span class='notice'>You insert [D] into \the [src]!</span>")
	else if(!(linked_destroy && linked_destroy.busy) && !(linked_lathe && linked_lathe.busy) && !(linked_imprinter && linked_imprinter.busy))
		. = ..()

/obj/machinery/computer/rdconsole/proc/research_node(id, mob/user)
	if(!stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		say("Node unlock failed: Either already researched or not available!")
		return FALSE
	var/datum/techweb_node/TN = SSresearch.techweb_node_by_id(id)
	if(!istype(TN))
		say("Node unlock failed: Unknown error.")
		return FALSE
	var/list/price = TN.get_price(stored_research)
	if(stored_research.can_afford(price))
		investigate_log("[key_name(user)] researched [id]([json_encode(price)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
		if(stored_research == SSresearch.science_tech)
			SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("id" = "[id]", "name" = TN.display_name, "price" = "[json_encode(price)]", "time" = SQLtime()))
		if(stored_research.research_node_id(id))
			say("Successfully purchased [TN.display_name].")
			var/logname = "Unknown"
			if(isAI(user))
				logname = "AI: [user.name]"
			else if(iscyborg(user))
				logname = "Cyborg: [user.name]"
			else if(isliving(user))
				var/mob/living/L = user
				logname = L.get_visible_name()
			stored_research.research_logs += "[logname] purchased node id [id] with cost [json_encode(price)] at [COORD(src)]."
			return TRUE
		else
			say("Failed to research node: Internal database error!")
			return FALSE
	say("Not enough credits...")
	return FALSE

/obj/machinery/computer/rdconsole/on_deconstruction()
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	..()

/obj/machinery/computer/rdconsole/emag_act(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='notice'>You disable the security protocols.</span>")
	playsound(src, "sparks", 75, 1)
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/computer/rdconsole/multitool_act(mob/user, obj/item/I)
	if(!I.tool_behaviour == TOOL_MULTITOOL)
		return
	var/lathe = linked_lathe && linked_lathe.multitool_act(user, I)
	var/print = linked_imprinter && linked_imprinter.multitool_act(user, I)
	return lathe || print

/*/obj/machinery/computer/rdconsole/proc/ui_techdisk()		//Legacy code (keeping but commenting for reference when re-making these UIs)
	RDSCREEN_UI_TDISK_CHECK
	var/list/l = list()
	l += "<div class='statusDisplay'>Disk Operations: <A href='?src=[REF(src)];clear_tech=0'>Clear Disk</A>"
	l += "<A href='?src=[REF(src)];eject_tech=1'>Eject Disk</A>"
	l += "<A href='?src=[REF(src)];updt_tech=0'>Upload All</A>"
	l += "<A href='?src=[REF(src)];copy_tech=1'>Load Technology to Disk</A></div>"
	l += "<div class='statusDisplay'><h3>Stored Technology Nodes:</h3>"
	for(var/i in t_disk.stored_research.researched_nodes)
		var/datum/techweb_node/N = SSresearch.techweb_node_by_id(i)
		l += "<A href='?src=[REF(src)];view_node=[i];back_screen=[screen]'>[N.display_name]</A>"
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_designdisk()		//Legacy code
	RDSCREEN_UI_DDISK_CHECK
	var/list/l = list()
	l += "Disk Operations: <A href='?src=[REF(src)];clear_design=0'>Clear Disk</A><A href='?src=[REF(src)];updt_design=0'>Upload All</A><A href='?src=[REF(src)];eject_design=1'>Eject Disk</A>"
	for(var/i in 1 to d_disk.max_blueprints)
		l += "<div class='statusDisplay'>"
		if(d_disk.blueprints[i])
			var/datum/design/D = d_disk.blueprints[i]
			l += "<A href='?src=[REF(src)];view_design=[D.id]'>[D.name]</A>"
			l += "Operations: <A href='?src=[REF(src)];updt_design=[i]'>Upload to database</A> <A href='?src=[REF(src)];clear_design=[i]'>Clear Slot</A>"
		else
			l += "Empty Slot Operations: <A href='?src=[REF(src)];switch_screen=[RDSCREEN_DESIGNDISK_UPLOAD];disk_slot=[i]'>Load Design to Slot</A>"
		l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_designdisk_upload()	//Legacy code
	RDSCREEN_UI_DDISK_CHECK
	var/list/l = list()
	l += "<A href='?src=[REF(src)];switch_screen=[RDSCREEN_DESIGNDISK];back_screen=[screen]'>Return to Disk Operations</A><div class='statusDisplay'>"
	l += "<h3>Load Design to Disk:</h3>"
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		l += "[D.name] "
		l += "<A href='?src=[REF(src)];copy_design=[disk_slot_selected];copy_design_ID=[D.id]'>Copy to Disk</A>"
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_deconstruct()		//Legacy code
	RDSCREEN_UI_DECONSTRUCT_CHECK
	var/list/l = list()
	if(!linked_destroy.loaded_item)
		l += "<div class='statusDisplay'>No item loaded. Standing-by...</div>"
	else
		l += "<div class='statusDisplay'>[RDSCREEN_NOBREAK]"
		l += "<table><tr><td>[icon2html(linked_destroy.loaded_item, usr)]</td><td><b>[linked_destroy.loaded_item.name]</b> <A href='?src=[REF(src)];eject_item=1'>Eject</A></td></tr></table>[RDSCREEN_NOBREAK]"
		l += "Select a node to boost by deconstructing this item. This item can boost:"

		var/list/boostable_nodes = techweb_item_boost_check(linked_destroy.loaded_item)
		for(var/id in boostable_nodes)
			var/worth = boostable_nodes[id]
			var/datum/techweb_node/N = SSresearch.techweb_node_by_id(id)

			l += "<div class='statusDisplay'>[RDSCREEN_NOBREAK]"
			if (stored_research.researched_nodes[N.id])  // already researched
				l += "<span class='linkOff'>[N.display_name]</span>"
				l += "This node has already been researched."
			else if(worth == 0)  // reveal only
				if (stored_research.hidden_nodes[N.id])
					l += "<A href='?src=[REF(src)];deconstruct=[N.id]'>[N.display_name]</A>"
					l += "This node will be revealed."
				else
					l += "<span class='linkOff'>[N.display_name]</span>"
					l += "This node has already been revealed."
			else  // boost by the difference
				var/differences = 0
				var/already_boosted = stored_research.boosted_nodes[N.id]
				var/already_boosted_amount = already_boosted? stored_research.boosted_nodes[N.id] : 0
				var/amt = min(worth, N.research_costs) - already_boosted_amount
				if(amt > 0)
					differences = amt
				if (differences != 0)
					l += "<A href='?src=[REF(src)];deconstruct=[N.id]'>[N.display_name]</A>"
					l += "This node will be boosted with the following:<BR>[differences]"
				else
					l += "<span class='linkOff'>[N.display_name]</span>"
					l += "This node has already been boosted.</span>"
			l += "</div>[RDSCREEN_NOBREAK]"

		// point deconstruction and material reclamation use the same ID to prevent accidentally missing the points
		var/point_value = techweb_item_point_check(linked_destroy.loaded_item)
		if(point_value)
			l += "<div class='statusDisplay'>[RDSCREEN_NOBREAK]"
			if (stored_research.deconstructed_items[linked_destroy.loaded_item.type])
				l += "<span class='linkOff'>Point Deconstruction</span>"
				l += "This item's points have already been claimed."
			else
				l += "<A href='?src=[REF(src)];deconstruct=[RESEARCH_MATERIAL_RECLAMATION_ID]'>Point Deconstruction</A>"
				l += "This item is worth: <BR>[point_value]!"
			l += "</div>[RDSCREEN_NOBREAK]"

		if(!(linked_destroy.loaded_item.resistance_flags & INDESTRUCTIBLE))
			var/list/materials = linked_destroy.loaded_item.custom_materials
			l += "<div class='statusDisplay'><A href='?src=[REF(src)];deconstruct=[RESEARCH_MATERIAL_RECLAMATION_ID]'>[LAZYLEN(materials)? "Material Reclamation" : "Destroy Item"]</A>"
			for (var/M in materials)
				l += "* [CallMaterialName(M)] x [materials[M]]"
			l += "</div>[RDSCREEN_NOBREAK]"

		l += "<div class='statusDisplay'><A href='?src=[REF(src)];deconstruct=[RESEARCH_DEEP_SCAN_ID]'>Nondestructive Deep Scan</A></div>"

		l += "</div>"
	return l
*/

/obj/machinery/computer/rdconsole/ui_interact(mob/user, datum/tgui/ui = null)
	if(research_control)
		ui = SStgui.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "RDConsole")
			ui.open()
			ui.send_asset(get_asset_datum(/datum/asset/spritesheet/research_designs))
	else
		say("Research trading is disabled on this console")

/*/obj/machinery/computer/rdconsole/proc/eject_disk(type)
	if(type == "design")
		d_disk.forceMove(get_turf(src))
		d_disk = null
	if(type == "tech")
		t_disk.forceMove(get_turf(src))
		t_disk = null*/

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics Research Trading Console"
	req_access = null
	req_access_txt = "29"

/obj/machinery/computer/rdconsole/robotics/Initialize(mapload)
	. = ..()
	if(circuit)
		circuit.name = "Research Trading Console - Robotics (Computer Board)"
		circuit.build_path = /obj/machinery/computer/rdconsole/robotics

/obj/machinery/computer/rdconsole/core
	name = "Research Trading Console"

/obj/machinery/computer/rdconsole/experiment
	name = "E.X.P.E.R.I-MENTOR R&D Console"
