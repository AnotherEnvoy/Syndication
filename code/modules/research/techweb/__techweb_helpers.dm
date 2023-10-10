/proc/count_unique_techweb_nodes()
	var/static/list/L = typesof(/datum/techweb_node)
	return L.len

/proc/count_unique_techweb_designs()
	var/static/list/L = typesof(/datum/design)
	return L.len

/proc/node_boost_error(id, message)
	WARNING("Invalid boost information for node \[[id]\]: [message]")
	SSresearch.invalid_node_boost[id] = message

/proc/techweb_item_boost_check(obj/item/I)			//Returns an associative list of techweb node datums with values of the boost it gives.	var/list/returned = list()
	if(SSresearch.techweb_boost_items[I.type])
		return SSresearch.techweb_boost_items[I.type]		//It should already be formatted in node datum = list(point type = value)

/proc/techweb_item_point_check(obj/item/I)
	if(SSresearch.techweb_point_items[I.type])
		return SSresearch.techweb_point_items[I.type]

/proc/techweb_point_display_rdconsole(points, last_points)
	return "[points] (+[(last_points) * ((SSresearch.flags & SS_TICKER)? (600 / (world.tick_lag * SSresearch.wait)) : (600 / SSresearch.wait))]/ minute)"
