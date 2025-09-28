@tool
extends GraphEdit

const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _Global := preload("res://addons/oasis_dialogue/global.gd")
const _Vector2Utils := preload("res://addons/oasis_dialogue/utils/vector2_utils.gd")

const SAVE_POSITION_OFFSET_KEY := "branch_position_offsets"

signal branch_added(id: int, branch: _Branch)
## Emitted when a branch
signal branches_dirtied(id: int, dirty_ids: Array[int])
## Emitted when a branch is loaded from file and needs to be unparsed.
signal branch_restored(branch: _Branch)

var duration: float = 0.5:
	set(value):
		duration = max(value, 0.1)

var _tween: Tween = null
var _branches: Dictionary[int, _Branch] = {}
var _branch_factory := Callable()


func init(branch_factory: Callable) -> void:
	_branch_factory = branch_factory


func add_branch(id: int) -> void:
	var branch: _Branch = _branch_factory.call()
	add_child(branch)
	branch.removed.connect(remove_branch)
	branch.set_id(id)
	center_node_in_graph(branch)

	_branches[id] = branch
	branch_added.emit(id, branch)


func get_branch(id: int) -> _Branch:
	return _branches[id]


func get_branches() -> Dictionary[int, _Branch]:
	return _branches.duplicate()


func connect_branches(from_id: int, to_ids: Array[int]) -> void:
	var to_arrange: Array[_Branch] = []
	var from := _branches[from_id]
	from.set_slot_enabled_right(0, to_ids.size())
	for other in _branches.keys():
		var to := _branches[other]
		var is_in := to_ids.has(other)
		var is_connected := is_node_connected(from.name, 0, to.name, 0)

		if is_in and not is_connected:
			if not to.is_slot_enabled_left(0):
				to.set_slot_enabled_left(0, true)
				if not to.is_slot_enabled_right(0):
					to_arrange.push_back(to)
			connect_node(from.name, 0, to.name, 0)
		elif not is_in and is_connected:
			disconnect_node(from.name, 0, to.name, 0)

	disable_unused_slots()
	if to_arrange:
		arrange_branches_around_anchor(from, to_arrange)
	arrange_orphans()


func remove_branch(id: int, branch: _Branch) -> void:
	var branch_connections := get_connection_list_from_node(branch.name)

	var disconnected_branches: Array[int] = []
	if branch_connections:
		var from_connections: Array[String] = []
		from_connections.assign(branch_connections.map(func(d: Dictionary): return d["from_node"]))
		var to_connections: Array[String] = []
		to_connections.assign(branch_connections.map(func(d: Dictionary): return d["to_node"]))

		for other_id in _branches:
			var other := _branches[other_id]
			if other == branch:
				continue
			if other.name in from_connections:
				disconnect_node(other.name, 0, branch.name, 0)
				disconnected_branches.push_back(other_id)
			if other.name in to_connections:
				disconnect_node(branch.name, 0, other.name, 0)

	if disconnected_branches:
		branches_dirtied.emit(id, disconnected_branches)
	disable_unused_slots()
	_branches.erase(id)
	remove_child(branch)
	branch.queue_free()


func remove_branches() -> void:
	for branch in _branches.values():
		remove_child(branch)
		branch.queue_free()
	_branches.clear()


func disable_unused_slots() -> void:
	var nodes: Array[GraphNode] = []
	nodes.assign(
		get_children().filter(
			func(n: Node): return is_instance_of(n, GraphNode)
		)
	)
	var from_connections: Array[String] = []
	from_connections.assign(connections.map(func(d: Dictionary): return d["from_node"]))
	var to_connections: Array[String] = []
	to_connections.assign(connections.map(func(d: Dictionary): return d["to_node"]))

	for node in nodes:
		if not node.name in from_connections:
			node.set_slot_enabled_right(0, false)
		if not node.name in to_connections:
			node.set_slot_enabled_left(0, false)


## Arranges the orphans below the left-most node.
func arrange_orphans() -> void:
	var nodes: Array[GraphNode] = []
	nodes.assign(
		get_children().filter(
			func(n: Node): return is_instance_of(n, GraphNode)
		)
	)
	var from_connections: Array[String] = []
	from_connections.assign(connections.map(func(d: Dictionary): return d["from_node"]))
	var to_connections: Array[String] = []
	to_connections.assign(connections.map(func(d: Dictionary): return d["to_node"]))

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

	arrange_branches_around_anchor(anchor, orphans)


func arrange_branches_around_anchor(anchor: GraphNode, to_arrange: Array) -> void:
	var all_nodes: Array[GraphNode] = []
	all_nodes.assign(get_children().filter(func(n: Node): return is_instance_of(n, GraphNode)))
	var selected_nodes := all_nodes.filter(func(n: GraphNode): return n.selected)
	selected_nodes.map(func(n: GraphNode): n.selected = false)

	var nodes: Array[GraphNode] = []
	nodes.assign(to_arrange)
	nodes.push_back(anchor)
	var original := nodes.map(func(n: GraphNode): return n.position_offset)

	nodes.map(func(n: GraphNode): n.selected = true)
	arrange_nodes()
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


func center_node_in_graph(node: GraphNode) -> void:
	node.position_offset = (size / 2 + scroll_offset) / zoom - node.size / 2


func load_character(data: Dictionary) -> void:
	for id in _branches:
		_branches[id].queue_free()
		remove_child(_branches[id])
	_branches.clear()

	var position_offsets := data.get(_Global.FILE_BRANCH_POSITION_OFFSETS, {})
	for key in position_offsets:
		var id: int = key
		add_branch(id)
		var offset := _Vector2Utils.from_json(position_offsets.get(key, {}))
		_branches[id].position_offset = offset

		branch_restored.emit(_branches[id])


func save_character(data: Dictionary) -> void:
	var position_offsets := {}
	for id in _branches:
		position_offsets[id] = _branches[id].position_offset
	data[_Global.FILE_BRANCH_POSITION_OFFSETS] = position_offsets


func _setup_tween() -> void:
	if not _tween:
		_tween = get_tree().create_tween()
	elif _tween and not _tween.is_valid():
		_tween.kill()
		_tween = get_tree().create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_parallel()
