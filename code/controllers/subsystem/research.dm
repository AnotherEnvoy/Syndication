
SUBSYSTEM_DEF(research)
	name = "Research"
	priority = FIRE_PRIORITY_RESEARCH
	wait = 10
	init_order = INIT_ORDER_RESEARCH
	//TECHWEB STATIC
	var/list/techweb_nodes = list()				//associative id = node datum
	var/list/techweb_designs = list()			//associative id = node datum
	var/list/datum/techweb/techwebs = list()
	var/datum/techweb/science/science_tech
	var/datum/techweb/admin/admin_tech
	var/datum/techweb_node/error_node/error_node	//These two are what you get if a node/design is deleted and somehow still stored in a console.
	var/datum/design/error_design/error_design

	//ERROR LOGGING
	var/list/invalid_design_ids = list()		//associative id = number of times
	var/list/invalid_node_ids = list()			//associative id = number of times
	var/list/invalid_node_boost = list()		//associative id = error message

	var/list/obj/machinery/rnd/server/servers = list()

	var/list/techweb_nodes_starting = list()	//associative id = TRUE
	var/list/techweb_categories = list()		//category name = list(node.id = TRUE)
	var/list/techweb_boost_items = list()		//associative double-layer path = list(id = list(point_type = point_discount))
	var/list/techweb_nodes_hidden = list()		//Node ids that should be hidden by default.
	var/list/techweb_nodes_experimental = list()	//Node ids that are exclusive to the BEPIS.

	//SKYRAT CHANGE
	//PROBLEM COMPUTER CHARGES
	var/problem_computer_max_charges = 5
	var/problem_computer_charges = 5
	var/problem_computer_charge_time = 90 SECONDS
	var/problem_computer_next_charge_time = 0

	var/list/techweb_point_items = list(		//path = list(point type = value)
	/obj/item/assembly/signaler/anomaly            = 10000,
	//   -   Slime Extracts!   - Basics
	/obj/item/slime_extract/grey                   = 500,
	/obj/item/slime_extract/metal                  = 750,
	/obj/item/slime_extract/purple                 = 750,
	/obj/item/slime_extract/orange                 = 750,
	/obj/item/slime_extract/blue                   = 750,
	/obj/item/slime_extract/yellow                 = 1000,
	/obj/item/slime_extract/silver                 = 1000,
	/obj/item/slime_extract/darkblue               = 1000,
	/obj/item/slime_extract/darkpurple             = 1000,
	/obj/item/slime_extract/bluespace              = 1250,
	/obj/item/slime_extract/sepia                  = 1250,
	/obj/item/slime_extract/cerulean               = 1250,
	/obj/item/slime_extract/pyrite                 = 1250,
	/obj/item/slime_extract/red                    = 1250,
	/obj/item/slime_extract/green                  = 1250,
	/obj/item/slime_extract/pink                   = 1250,
	/obj/item/slime_extract/gold                   = 1250,
	/obj/item/slime_extract/black                  = 1500,
	/obj/item/slime_extract/adamantine             = 1500,
	/obj/item/slime_extract/oil                    = 1500,
	/obj/item/slime_extract/lightpink              = 1500,
	/obj/item/slime_extract/rainbow                = 2500,
		//  Reproductive -    Crossbreading Cores!    - (Grey Cores)
	/obj/item/slimecross/reproductive/grey         = 1000,
	/obj/item/slimecross/reproductive/orange       = 1500,
	/obj/item/slimecross/reproductive/purple       = 1500,
	/obj/item/slimecross/reproductive/blue         = 1500,
	/obj/item/slimecross/reproductive/metal        = 1500,
	/obj/item/slimecross/reproductive/yellow       = 1750,
	/obj/item/slimecross/reproductive/darkpurple   = 1750,
	/obj/item/slimecross/reproductive/darkblue     = 1750,
	/obj/item/slimecross/reproductive/silver       = 1750,
	/obj/item/slimecross/reproductive/bluespace    = 2000,
	/obj/item/slimecross/reproductive/sepia        = 2000,
	/obj/item/slimecross/reproductive/cerulean     = 2000,
	/obj/item/slimecross/reproductive/pyrite       = 2000,
	/obj/item/slimecross/reproductive/red          = 2250,
	/obj/item/slimecross/reproductive/green        = 2250,
	/obj/item/slimecross/reproductive/pink         = 2250,
	/obj/item/slimecross/reproductive/gold         = 2250,
	/obj/item/slimecross/reproductive/oil          = 2500,
	/obj/item/slimecross/reproductive/black        = 2500,
	/obj/item/slimecross/reproductive/lightpink    = 2500,
	/obj/item/slimecross/reproductive/adamantine   = 2500,
	/obj/item/slimecross/reproductive/rainbow      = 2750,
	//  Burning -    Crossbreading Cores!    - (Orange Cores)
	/obj/item/slimecross/burning/grey              = 2000,
	/obj/item/slimecross/burning/orange            = 2500,
	/obj/item/slimecross/burning/purple            = 2500,
	/obj/item/slimecross/burning/blue              = 2500,
	/obj/item/slimecross/burning/metal             = 2500,
	/obj/item/slimecross/burning/yellow            = 2750,
	/obj/item/slimecross/burning/darkpurple        = 2750,
	/obj/item/slimecross/burning/darkblue          = 2750,
	/obj/item/slimecross/burning/silver            = 2750,
	/obj/item/slimecross/burning/bluespace         = 3000,
	/obj/item/slimecross/burning/sepia             = 3000,
	/obj/item/slimecross/burning/cerulean          = 3000,
	/obj/item/slimecross/burning/pyrite            = 3000,
	/obj/item/slimecross/burning/red               = 3250,
	/obj/item/slimecross/burning/green             = 3250,
	/obj/item/slimecross/burning/pink              = 3250,
	/obj/item/slimecross/burning/gold              = 3250,
	/obj/item/slimecross/burning/oil               = 3500,
	/obj/item/slimecross/burning/black             = 3500,
	/obj/item/slimecross/burning/lightpink         = 3500,
	/obj/item/slimecross/burning/adamantine        = 3500,
	/obj/item/slimecross/burning/rainbow           = 3750,
		//  Regenerative -    Crossbreading Cores!    - (Purple Cores)
	/obj/item/slimecross/regenerative/grey         = 2000,
	/obj/item/slimecross/regenerative/orange       = 2500,
	/obj/item/slimecross/regenerative/purple       = 2500,
	/obj/item/slimecross/regenerative/blue         = 2500,
	/obj/item/slimecross/regenerative/metal        = 2500,
	/obj/item/slimecross/regenerative/yellow       = 2750,
	/obj/item/slimecross/regenerative/darkpurple   = 2750,
	/obj/item/slimecross/regenerative/darkblue     = 2750,
	/obj/item/slimecross/regenerative/silver       = 2750,
	/obj/item/slimecross/regenerative/bluespace    = 3000,
	/obj/item/slimecross/regenerative/sepia        = 3000,
	/obj/item/slimecross/regenerative/cerulean     = 3000,
	/obj/item/slimecross/regenerative/pyrite       = 3000,
	/obj/item/slimecross/regenerative/red          = 3250,
	/obj/item/slimecross/regenerative/green        = 3250,
	/obj/item/slimecross/regenerative/pink         = 3250,
	/obj/item/slimecross/regenerative/gold         = 3250,
	/obj/item/slimecross/regenerative/oil          = 3500,
	/obj/item/slimecross/regenerative/black        = 3500,
	/obj/item/slimecross/regenerative/lightpink    = 3500,
	/obj/item/slimecross/regenerative/adamantine   = 3500,
	/obj/item/slimecross/regenerative/rainbow      = 3750,
		//  Stabilized -    Crossbreading Cores!    - (Blue Cores)
	/obj/item/slimecross/stabilized/grey           = 2000,
	/obj/item/slimecross/stabilized/orange         = 2500,
	/obj/item/slimecross/stabilized/purple         = 2500,
	/obj/item/slimecross/stabilized/blue           = 2500,
	/obj/item/slimecross/stabilized/metal          = 2500,
	/obj/item/slimecross/stabilized/yellow         = 2750,
	/obj/item/slimecross/stabilized/darkpurple     = 2750,
	/obj/item/slimecross/stabilized/darkblue       = 2750,
	/obj/item/slimecross/stabilized/silver         = 2750,
	/obj/item/slimecross/stabilized/bluespace      = 3000,
	/obj/item/slimecross/stabilized/sepia          = 3000,
	/obj/item/slimecross/stabilized/cerulean       = 3000,
	/obj/item/slimecross/stabilized/pyrite         = 3000,
	/obj/item/slimecross/stabilized/red            = 3250,
	/obj/item/slimecross/stabilized/green          = 3250,
	/obj/item/slimecross/stabilized/pink           = 3250,
	/obj/item/slimecross/stabilized/gold           = 3250,
	/obj/item/slimecross/stabilized/oil            = 3500,
	/obj/item/slimecross/stabilized/black          = 3500,
	/obj/item/slimecross/stabilized/lightpink      = 3500,
	/obj/item/slimecross/stabilized/adamantine     = 3500,
	/obj/item/slimecross/stabilized/rainbow        = 3750,
		//  Industrial -    Crossbreading Cores!    - (Metal Cores)
	/obj/item/slimecross/industrial/grey           = 2000,
	/obj/item/slimecross/industrial/orange         = 2500,
	/obj/item/slimecross/industrial/purple         = 2500,
	/obj/item/slimecross/industrial/blue           = 2500,
	/obj/item/slimecross/industrial/metal          = 2500,
	/obj/item/slimecross/industrial/yellow         = 2750,
	/obj/item/slimecross/industrial/darkpurple     = 2750,
	/obj/item/slimecross/industrial/darkblue       = 2750,
	/obj/item/slimecross/industrial/silver         = 2750,
	/obj/item/slimecross/industrial/bluespace      = 3000,
	/obj/item/slimecross/industrial/sepia          = 3000,
	/obj/item/slimecross/industrial/cerulean       = 3000,
	/obj/item/slimecross/industrial/pyrite         = 3000,
	/obj/item/slimecross/industrial/red            = 3250,
	/obj/item/slimecross/industrial/green          = 3250,
	/obj/item/slimecross/industrial/pink           = 3250,
	/obj/item/slimecross/industrial/gold           = 3250,
	/obj/item/slimecross/industrial/oil            = 3500,
	/obj/item/slimecross/industrial/black          = 3500,
	/obj/item/slimecross/industrial/lightpink      = 3500,
	/obj/item/slimecross/industrial/adamantine     = 3500,
	/obj/item/slimecross/industrial/rainbow        = 3750,
		//  Charged -    Crossbreading Cores!    - (Yellow Cores)
	/obj/item/slimecross/charged/grey              = 2250,
	/obj/item/slimecross/charged/orange            = 2750,
	/obj/item/slimecross/charged/purple            = 2750,
	/obj/item/slimecross/charged/blue              = 2750,
	/obj/item/slimecross/charged/metal             = 2750,
	/obj/item/slimecross/charged/yellow            = 3000,
	/obj/item/slimecross/charged/darkpurple        = 3000,
	/obj/item/slimecross/charged/darkblue          = 3000,
	/obj/item/slimecross/charged/silver            = 3000,
	/obj/item/slimecross/charged/bluespace         = 3250,
	/obj/item/slimecross/charged/sepia             = 3250,
	/obj/item/slimecross/charged/cerulean          = 3250,
	/obj/item/slimecross/charged/pyrite            = 3250,
	/obj/item/slimecross/charged/red               = 3500,
	/obj/item/slimecross/charged/green             = 3500,
	/obj/item/slimecross/charged/pink              = 3500,
	/obj/item/slimecross/charged/gold              = 3500,
	/obj/item/slimecross/charged/oil               = 3750,
	/obj/item/slimecross/charged/black             = 3750,
	/obj/item/slimecross/charged/lightpink         = 3750,
	/obj/item/slimecross/charged/adamantine        = 3750,
	/obj/item/slimecross/charged/rainbow           = 4000,
			//  Selfsustaining -    Crossbreading Cores!    - (Dark Purple Cores)
	/obj/item/slimecross/selfsustaining/grey       = 2250,
	/obj/item/slimecross/selfsustaining/orange     = 2750,
	/obj/item/slimecross/selfsustaining/purple     = 2750,
	/obj/item/slimecross/selfsustaining/blue       = 2750,
	/obj/item/slimecross/selfsustaining/metal      = 2750,
	/obj/item/slimecross/selfsustaining/yellow     = 3000,
	/obj/item/slimecross/selfsustaining/darkpurple = 3000,
	/obj/item/slimecross/selfsustaining/darkblue   = 3000,
	/obj/item/slimecross/selfsustaining/silver     = 3000,
	/obj/item/slimecross/selfsustaining/bluespace  = 3250,
	/obj/item/slimecross/selfsustaining/sepia      = 3250,
	/obj/item/slimecross/selfsustaining/cerulean   = 3250,
	/obj/item/slimecross/selfsustaining/pyrite     = 3250,
	/obj/item/slimecross/selfsustaining/red        = 3500,
	/obj/item/slimecross/selfsustaining/green      = 3500,
	/obj/item/slimecross/selfsustaining/pink       = 3500,
	/obj/item/slimecross/selfsustaining/gold       = 3500,
	/obj/item/slimecross/selfsustaining/oil        = 3750,
	/obj/item/slimecross/selfsustaining/black      = 3750,
	/obj/item/slimecross/selfsustaining/lightpink  = 3750,
	/obj/item/slimecross/selfsustaining/adamantine = 3750,
	/obj/item/slimecross/selfsustaining/rainbow    = 4000,
			//  Consuming -    Crossbreading Cores!    - (Sliver Cores)
	/obj/item/slimecross/consuming/grey            = 2250,
	/obj/item/slimecross/consuming/orange          = 2750,
	/obj/item/slimecross/consuming/purple          = 2750,
	/obj/item/slimecross/consuming/blue            = 2750,
	/obj/item/slimecross/consuming/metal           = 2750,
	/obj/item/slimecross/consuming/yellow          = 3000,
	/obj/item/slimecross/consuming/darkpurple      = 3000,
	/obj/item/slimecross/consuming/darkblue        = 3000,
	/obj/item/slimecross/consuming/silver          = 3000,
	/obj/item/slimecross/consuming/bluespace       = 3250,
	/obj/item/slimecross/consuming/sepia           = 3250,
	/obj/item/slimecross/consuming/cerulean        = 3250,
	/obj/item/slimecross/consuming/pyrite          = 3250,
	/obj/item/slimecross/consuming/red             = 3500,
	/obj/item/slimecross/consuming/green           = 3500,
	/obj/item/slimecross/consuming/pink            = 3500,
	/obj/item/slimecross/consuming/gold            = 3500,
	/obj/item/slimecross/consuming/oil             = 3750,
	/obj/item/slimecross/consuming/black           = 3750,
	/obj/item/slimecross/consuming/lightpink       = 3750,
	/obj/item/slimecross/consuming/adamantine      = 3750,
	/obj/item/slimecross/consuming/rainbow         = 4000,
		//  Prismatic -    Crossbreading Cores!    - (Pyrite Cores)
	/obj/item/slimecross/prismatic/grey            = 2500,
	/obj/item/slimecross/prismatic/orange          = 3000,
	/obj/item/slimecross/prismatic/purple          = 3000,
	/obj/item/slimecross/prismatic/blue            = 3000,
	/obj/item/slimecross/prismatic/metal           = 3000,
	/obj/item/slimecross/prismatic/yellow          = 3250,
	/obj/item/slimecross/prismatic/darkpurple      = 3250,
	/obj/item/slimecross/prismatic/darkblue        = 3250,
	/obj/item/slimecross/prismatic/silver          = 3250,
	/obj/item/slimecross/prismatic/bluespace       = 3500,
	/obj/item/slimecross/prismatic/sepia           = 3500,
	/obj/item/slimecross/prismatic/cerulean        = 3500,
	/obj/item/slimecross/prismatic/pyrite          = 3500,
	/obj/item/slimecross/prismatic/red             = 3750,
	/obj/item/slimecross/prismatic/green           = 3750,
	/obj/item/slimecross/prismatic/pink            = 3750,
	/obj/item/slimecross/prismatic/gold            = 3750,
	/obj/item/slimecross/prismatic/oil             = 4000,
	/obj/item/slimecross/prismatic/black           = 4000,
	/obj/item/slimecross/prismatic/lightpink       = 4000,
	/obj/item/slimecross/prismatic/adamantine      = 4000,
	/obj/item/slimecross/prismatic/rainbow         = 4250,
		//  Recurring -    Crossbreading Cores!    - (Cerulean Cores)
	/obj/item/slimecross/recurring/grey            = 2500,
	/obj/item/slimecross/recurring/orange          = 3000,
	/obj/item/slimecross/recurring/purple          = 3000,
	/obj/item/slimecross/recurring/blue            = 3000,
	/obj/item/slimecross/recurring/metal           = 3000,
	/obj/item/slimecross/recurring/yellow          = 3250,
	/obj/item/slimecross/recurring/darkpurple      = 3250,
	/obj/item/slimecross/recurring/darkblue        = 3250,
	/obj/item/slimecross/recurring/silver          = 3250,
	/obj/item/slimecross/recurring/bluespace       = 3500,
	/obj/item/slimecross/recurring/sepia           = 3500,
	/obj/item/slimecross/recurring/cerulean        = 3500,
	/obj/item/slimecross/recurring/pyrite          = 3500,
	/obj/item/slimecross/recurring/red             = 3750,
	/obj/item/slimecross/recurring/green           = 3750,
	/obj/item/slimecross/recurring/pink            = 3750,
	/obj/item/slimecross/recurring/gold            = 3750,
	/obj/item/slimecross/recurring/oil             = 4000,
	/obj/item/slimecross/recurring/black           = 4000,
	/obj/item/slimecross/recurring/lightpink       = 4000,
	/obj/item/slimecross/recurring/adamantine      = 4000,
	/obj/item/slimecross/recurring/rainbow         = 4250
	)
	var/list/errored_datums = list()
	//----------------------------------------------
	var/list/single_server_income = 35	//citadel edit - techwebs nerf
	var/multiserver_calculation = FALSE
	var/last_income
	//^^^^^^^^ ALL OF THESE ARE PER SECOND! ^^^^^^^^

	//Aiming for 1.5 hours to max R&D
	//[88nodes * 5000points/node] / [1.5hr * 90min/hr * 60s/min]
	//Around 450000 points max???

	/// The global list of raw anomaly types that have been refined, for hard limits.
	var/list/created_anomaly_types = list()
	/// The hard limits of cores created for each anomaly type. For faster code lookup without switch statements.
	var/list/anomaly_hard_limit_by_type = list(
	ANOMALY_CORE_BLUESPACE = MAX_CORES_BLUESPACE,
	ANOMALY_CORE_PYRO = MAX_CORES_PYRO,
	ANOMALY_CORE_GRAVITATIONAL = MAX_CORES_GRAVITATIONAL,
	ANOMALY_CORE_VORTEX = MAX_CORES_VORTEX,
	ANOMALY_CORE_FLUX = MAX_CORES_FLUX
	)

/datum/controller/subsystem/research/Initialize()
	initialize_all_techweb_designs()
	initialize_all_techweb_nodes()
	science_tech = new /datum/techweb/science
	admin_tech = new /datum/techweb/admin
	autosort_categories()
	error_design = new
	error_node = new

	for(var/A in subtypesof(/obj/item/seeds))
		var/obj/item/seeds/S = A
		//First we get are yield and rarity and times it by two
		//Then we subtract production and maturation, making it so faster growing plants are better for RnD
		//Then we add in lifespan and potency,
		//A basic seed can be worth 268 points if its the best it can be.
		techweb_point_items[S] = 50 + initial(S.rarity) * 2 + initial(S.yield) * 2 - initial(S.maturation) - initial(S.production) + initial(S.lifespan) + initial(S.potency)

	return ..()

/datum/controller/subsystem/research/fire()
	var/bitcoins = 0
	if(multiserver_calculation)
		var/eff = calculate_server_coefficient()
		for(var/obj/machinery/rnd/server/miner in servers)
			bitcoins += miner.mine() * eff
	else
		for(var/obj/machinery/rnd/server/miner in servers)
			if(miner.working)
				bitcoins = single_server_income
				break			//Just need one to work.
	if (!isnull(last_income))
		var/income_time_difference = world.time - last_income
		bitcoins *= income_time_difference / 10
		science_tech.modify_points(bitcoins)
		var/income = science_tech.commit_income()
		var/old_weighted = science_tech.last_income * (1 MINUTES - income_time_difference)
		var/new_weighted = income * income_time_difference
		science_tech.last_income = (old_weighted + new_weighted) / (1 MINUTES)
	else
		science_tech.last_income = bitcoins
	last_income = world.time
	// Skyrat change. Handles Problem Computer charges here
	if(problem_computer_charges < problem_computer_max_charges && world.time >= problem_computer_next_charge_time)
		problem_computer_next_charge_time = world.time + problem_computer_charge_time
		problem_computer_charges += 1

/datum/controller/subsystem/research/proc/calculate_server_coefficient()	//Diminishing returns.
	var/amt = servers.len
	if(!amt)
		return FALSE
	var/coeff = 100
	coeff = sqrt(coeff / amt)
	return coeff

/datum/controller/subsystem/research/proc/autosort_categories()
	for(var/i in techweb_nodes)
		var/datum/techweb_node/I = techweb_nodes[i]
		if(techweb_categories[I.category])
			techweb_categories[I.category][I.id] = TRUE
		else
			techweb_categories[I.category] = list(I.id = TRUE)

/datum/controller/subsystem/research/proc/techweb_node_by_id(id)
	if(techweb_nodes[id])
		return techweb_nodes[id]
	stack_trace("Attempted to access node ID [id] which didn't exist")
	return error_node

/datum/controller/subsystem/research/proc/techweb_design_by_id(id)
	if(techweb_designs[id])
		return techweb_designs[id]
	stack_trace("Attempted to access design ID [id] which didn't exist")
	return error_design

/datum/controller/subsystem/research/proc/on_design_deletion(datum/design/D)
	for(var/i in techweb_nodes)
		var/datum/techweb_node/TN = techwebs[i]
		TN.on_design_deletion(TN)
	for(var/i in techwebs)
		var/datum/techweb/T = i
		T.recalculate_nodes(TRUE)

/datum/controller/subsystem/research/proc/on_node_deletion(datum/techweb_node/TN)
	for(var/i in techweb_nodes)
		var/datum/techweb_node/TN2 = techwebs[i]
		TN2.on_node_deletion(TN)
	for(var/i in techwebs)
		var/datum/techweb/T = i
		T.recalculate_nodes(TRUE)

/datum/controller/subsystem/research/proc/initialize_all_techweb_nodes(clearall = FALSE)
	if(islist(techweb_nodes) && clearall)
		QDEL_LIST(techweb_nodes)
	if(islist(techweb_nodes_starting && clearall))
		techweb_nodes_starting.Cut()
	var/list/returned = list()
	for(var/path in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/TN = path
		if(isnull(initial(TN.id)))
			continue
		TN = new path
		if(returned[initial(TN.id)])
			stack_trace("WARNING: Techweb node ID clash with ID [initial(TN.id)] detected! Path: [path]")
			errored_datums[TN] = initial(TN.id)
			continue
		returned[initial(TN.id)] = TN
		if(TN.starting_node)
			techweb_nodes_starting[TN.id] = TRUE
	for(var/id in techweb_nodes)
		var/datum/techweb_node/TN = techweb_nodes[id]
		TN.Initialize()
	techweb_nodes = returned
	verify_techweb_nodes()
	calculate_techweb_nodes()
	calculate_techweb_boost_list()
	if (!verify_techweb_nodes())		//Verify nodes and designs have been crosslinked properly.
		CRASH("Invalid techweb nodes detected")

/datum/controller/subsystem/research/proc/initialize_all_techweb_designs(clearall = FALSE)
	if(islist(techweb_designs) && clearall)
		QDEL_LIST(techweb_designs)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/design))
		var/datum/design/DN = path
		if(isnull(initial(DN.id)))
			stack_trace("WARNING: Design with null ID detected. Build path: [initial(DN.build_path)]")
			continue
		else if(initial(DN.id) == DESIGN_ID_IGNORE)
			continue
		DN = new path
		if(returned[initial(DN.id)])
			stack_trace("WARNING: Design ID clash with ID [initial(DN.id)] detected! Path: [path]")
			errored_datums[DN] = initial(DN.id)
			continue
		DN.InitializeMaterials() //Initialize the materials in the design
		returned[initial(DN.id)] = DN
	techweb_designs = returned
	verify_techweb_designs()

/datum/controller/subsystem/research/proc/verify_techweb_nodes()
	. = TRUE
	for(var/n in techweb_nodes)
		var/datum/techweb_node/N = techweb_nodes[n]
		if(!istype(N))
			stack_trace("Invalid research node with ID [n] detected and removed.")
			techweb_nodes -= n
			research_node_id_error(n)
			. = FALSE
		for(var/p in N.prereq_ids)
			var/datum/techweb_node/P = techweb_nodes[p]
			if(!istype(P))
				stack_trace("Invalid research prerequisite node with ID [p] detected in node [N.display_name]\[[N.id]\] removed.")
				N.prereq_ids  -= p
				research_node_id_error(p)
				. = FALSE
		for(var/d in N.design_ids)
			var/datum/design/D = techweb_designs[d]
			if(!istype(D))
				stack_trace("Invalid research design with ID [d] detected in node [N.display_name]\[[N.id]\] removed.")
				N.design_ids -= d
				design_id_error(d)
				. = FALSE
		for(var/u in N.unlock_ids)
			var/datum/techweb_node/U = techweb_nodes[u]
			if(!istype(U))
				stack_trace("Invalid research unlock node with ID [u] detected in node [N.display_name]\[[N.id]\] removed.")
				N.unlock_ids -= u
				research_node_id_error(u)
				. = FALSE
		for(var/p in N.boost_item_paths)
			if(!ispath(p))
				N.boost_item_paths -= p
				stack_trace("[p] is not a valid path.")
				node_boost_error(N.id, "[p] is not a valid path.")
				. = FALSE
			var/list/points = N.boost_item_paths[p]
			if(islist(points))
				for(var/i in points)
					if(!isnum(points[i]))
						stack_trace("[points[i]] is not a valid number.")
						node_boost_error(N.id, "[points[i]] is not a valid number.")
						. = FALSE
			else if(!isnull(points))
				N.boost_item_paths -= p
				node_boost_error(N.id, "No valid list.")
				stack_trace("No valid list.")
				. = FALSE
		CHECK_TICK

/datum/controller/subsystem/research/proc/verify_techweb_designs()
	for(var/d in techweb_designs)
		var/datum/design/D = techweb_designs[d]
		if(!istype(D))
			stack_trace("WARNING: Invalid research design with ID [d] detected and removed.")
			techweb_designs -= d
		CHECK_TICK

/datum/controller/subsystem/research/proc/research_node_id_error(id)
	if(invalid_node_ids[id])
		invalid_node_ids[id]++
	else
		invalid_node_ids[id] = 1

/datum/controller/subsystem/research/proc/design_id_error(id)
	if(invalid_design_ids[id])
		invalid_design_ids[id]++
	else
		invalid_design_ids[id] = 1

/datum/controller/subsystem/research/proc/calculate_techweb_nodes()
	for(var/design_id in techweb_designs)
		var/datum/design/D = techweb_designs[design_id]
		D.unlocked_by.Cut()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		node.unlock_ids = list()
		for(var/i in node.design_ids)
			var/datum/design/D = techweb_designs[i]
			node.design_ids[i] = TRUE
			D.unlocked_by += node.id
		if(node.hidden)
			techweb_nodes_hidden[node.id] = TRUE
		if(node.experimental)
			techweb_nodes_experimental[node.id] = TRUE
		CHECK_TICK
	generate_techweb_unlock_linking()

/datum/controller/subsystem/research/proc/generate_techweb_unlock_linking()
	for(var/node_id in techweb_nodes)						//Clear all unlock links to avoid duplication.
		var/datum/techweb_node/node = techweb_nodes[node_id]
		node.unlock_ids = list()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		for(var/prereq_id in node.prereq_ids)
			var/datum/techweb_node/prereq_node = techweb_node_by_id(prereq_id)
			prereq_node.unlock_ids[node.id] = node

/datum/controller/subsystem/research/proc/calculate_techweb_boost_list(clearall = FALSE)
	if(clearall)
		techweb_boost_items = list()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		for(var/path in node.boost_item_paths)
			if(!ispath(path))
				continue
			if(length(techweb_boost_items[path]))
				techweb_boost_items[path][node.id] = node.boost_item_paths[path]
			else
				techweb_boost_items[path] = list(node.id = node.boost_item_paths[path])
		CHECK_TICK
