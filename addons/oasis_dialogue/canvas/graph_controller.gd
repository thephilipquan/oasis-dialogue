extends RefCounted

var duration: float = 0.5:
	set(value):
		duration = max(value, 0.1)
var _tween: Tween = null
## [code]func(): -> Tween[/code]
var _create_tween := Callable()


func init(create_tween: Callable) -> void:
	_create_tween = create_tween


func disable_unused_slots(graph: GraphEdit) -> void:
	var nodes: Array[GraphNode] = []
	nodes.assign(
		graph.get_children().filter(
			func(n: Node): return is_instance_of(n, GraphNode)
		)
	)
	var from_connections: Array[String] = []
	from_connections.assign(graph.connections.map(func(d: Dictionary): return d["from_node"]))
	var to_connections: Array[String] = []
	to_connections.assign(graph.connections.map(func(d: Dictionary): return d["to_node"]))

	for node in nodes:
		if not node.name in from_connections:
			node.set_slot_enabled_right(0, false)
		if not node.name in to_connections:
			node.set_slot_enabled_left(0, false)


## Arranges the orphans below the left-most node.
func arrange_orphans(graph: GraphEdit) -> void:
	var nodes: Array[GraphNode] = []
	nodes.assign(
		graph.get_children().filter(
			func(n: Node): return is_instance_of(n, GraphNode)
		)
	)
	var from_connections: Array[String] = []
	from_connections.assign(graph.connections.map(func(d: Dictionary): return d["from_node"]))
	var to_connections: Array[String] = []
	to_connections.assign(graph.connections.map(func(d: Dictionary): return d["to_node"]))

	var anchor: GraphNode = null
	var orphans: Array[GraphNode] = []
	for node in nodes:
		if not (node.name in from_connections or node.name in to_connections):
			orphans.push_back(node)
		elif not anchor:
			anchor = node
		elif node.position_offset.x < anchor.position_offset.x:
			anchor = node
		elif (
			node.position_offset.x <= anchor.position_offset.x
			and node.position_offset.y < anchor.position_offset.y
		):
			anchor = node

	if not (anchor and orphans):
		return

	arrange_nodes_around_anchor(anchor, orphans, graph)


func arrange_nodes_around_anchor(anchor: GraphNode, to_arrange: Array, graph: GraphEdit) -> void:
	var all_nodes: Array[GraphNode] = []
	all_nodes.assign(graph.get_children().filter(func(n: Node): return is_instance_of(n, GraphNode)))
	var selected_nodes := all_nodes.filter(func(n: GraphNode): return n.selected)
	selected_nodes.map(func(n: GraphNode): n.selected = false)

	var nodes: Array[GraphNode] = []
	nodes.assign(to_arrange)
	nodes.push_back(anchor)
	var original := nodes.map(func(n: GraphNode): return n.position_offset)

	nodes.map(func(n: GraphNode): n.selected = true)
	graph.arrange_nodes()
	nodes.map(func(n: GraphNode): n.selected = false)

	var final := nodes.map(func(n: GraphNode): return n.position_offset)
	var final_anchor := anchor.position_offset
	for i in nodes.size():
		nodes[i].position_offset = original[i]

	_setup_tween()

	for i in nodes.size() - 1:
		var node: GraphNode = nodes[i]
		if node in to_arrange:
			var offset: Vector2 = final[i] - final_anchor
			_tween.tween_property(node, "position_offset", anchor.position_offset + offset, duration)

	selected_nodes.map(func(n: GraphNode): n.selected = true)


func center_node_in_graph(node: GraphNode, graph: GraphEdit) -> void:
	node.position_offset = (graph.size / 2 + graph.scroll_offset) / graph.zoom - node.size / 2


func _setup_tween() -> void:
	if not _tween:
		_tween = _create_tween.call()
	elif _tween and not _tween.is_valid():
		_tween.kill()
		_tween = _create_tween.call()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_parallel()
