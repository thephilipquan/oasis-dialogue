extends RefCounted


static func disable_slots_of_non_connecting(nodes: Array, graph: GraphEdit) -> void:
	var from_connections: Array[String] = []
	from_connections.assign(graph.connections.map(func(d: Dictionary): return d["from_node"]))
	var to_connections: Array[String] = []
	to_connections.assign(graph.connections.map(func(d: Dictionary): return d["to_node"]))

	for node in nodes:
		if not node.name in from_connections:
			node.set_slot_enabled_right(0, false)
		if not node.name in to_connections:
			node.set_slot_enabled_left(0, false)


static func disable_left_with_no_connections(nodes: Array, graph: GraphEdit) -> void:
	var existing_to_connections: Array[String] = []
	existing_to_connections.assign(
		graph.connections.map(func(d: Dictionary): return d["to_node"])
	)
	for node in nodes:
		if not node.name in existing_to_connections:
			node.set_slot_enabled_left(0, false)


static func arrange_nodes(nodes: Array, graph: GraphEdit) -> void:
	nodes.map(func(n: GraphNode): n.selected = true)
	graph.arrange_nodes()
	nodes.map(func(n: GraphNode): n.selected = false)
