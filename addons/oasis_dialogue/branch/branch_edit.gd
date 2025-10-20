@tool
extends GraphEdit

const REGISTRY_KEY := "branch_edit"

const _AddBranch := preload("res://addons/oasis_dialogue/canvas/add_branch_button.gd")
const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _Canvas := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _OasisFile := preload("res://addons/oasis_dialogue/oasis_file.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RemoveCharacter := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")
const _Save := preload("res://addons/oasis_dialogue/save.gd")

signal branch_added(branch: _Branch)
signal branch_removed(id: int)
## Emitted when a branch
signal branches_dirtied(id: int, dirty_ids: Array[int])

var duration: float = 0.5:
	set(value):
		duration = max(value, 0.1)

var _tween: Tween = null
var _branches: Dictionary[int, _Branch] = {}
var _branch_factory := Callable()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var add_branch_button: _AddBranch = registry.at(_AddBranch.REGISTRY_KEY)
	add_branch_button.branch_added.connect(add_branch)

	var remove_character: _RemoveCharacter = registry.at(_RemoveCharacter.REGISTRY_KEY)
	remove_character.character_removed.connect(remove_branches)

	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.saving_character.connect(save_character)
	manager.character_loaded.connect(load_character)
	manager.saving_character_config.connect(save_character_config)
	manager.character_config_loaded.connect(load_character_config)

	init_branch_factory(registry.at(_Canvas.BRANCH_FACTORY_REGISTRY_KEY))


func init_branch_factory(branch_factory: Callable) -> void:
	_branch_factory = branch_factory


func add_branch(id: int) -> void:
	if id in _branches:
		push_warning("branch: %d already exists" % id)
		return

	var branch: _Branch = _branch_factory.call()
	add_child(branch)
	branch.removed.connect(remove_branch)
	branch.set_id(id)
	center_node_in_graph(branch)

	_branches[id] = branch
	branch_added.emit(branch)


func get_branch(id: int) -> _Branch:
	return _branches.get(id, null)


func get_branch_ids() -> Array[int]:
	return _branches.keys()


func get_branch_count() -> int:
	return _branches.size()


func update_branch(id: int, text: String) -> void:
	if not id in _branches:
		push_warning("branch: %d does not exist" % id)
		return
	_branches[id].set_text(text)


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
	arrange_orphans(from)


func remove_branch(id: int) -> void:
	var branch := _branches[id]
	var disconnected_branches: Array[int] = []
	if get_connection_count(branch.name, 0):
		var branch_connections := get_connection_list_from_node(branch.name)
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

	branch_removed.emit(id)
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


func highlight_branch(id: int, lines: Array[int]) -> void:
	_branches[id].highlight(lines)


func clear_branch_highlights(id: int) -> void:
	_branches[id].highlight([])


func disable_unused_slots() -> void:
	for id in _branches:
		var branch := _branches[id]
		if not get_connection_count(branch.name, 0):
			branch.set_slot_enabled_right(0, false)
			branch.set_slot_enabled_left(0, false)
			continue

		var branch_connections := get_connection_list_from_node(branch.name)
		var from_connections: Array[String] = []
		from_connections.assign(branch_connections.map(func(d: Dictionary): return d["from_node"]))
		var to_connections: Array[String] = []
		to_connections.assign(branch_connections.map(func(d: Dictionary): return d["to_node"]))

		if not branch.name in from_connections:
			branch.set_slot_enabled_right(0, false)
		if not branch.name in to_connections:
			branch.set_slot_enabled_left(0, false)


## Arranges the orphans below the left-most node.
func arrange_orphans(ignore: _Branch) -> void:
	var anchor: GraphNode = null
	var orphans: Array[_Branch] = []
	for id in _branches:
		var branch := _branches[id]
		if not get_connection_count(branch.name, 0) and _branches[id] != ignore:
			orphans.push_back(branch)
		elif not anchor:
			anchor = branch
		elif branch.position_offset.x < anchor.position_offset.x:
			anchor = branch
		elif (
			branch.position_offset.x <= anchor.position_offset.x
			and branch.position_offset.y < anchor.position_offset.y
		):
			anchor = branch

	if not (anchor and orphans):
		return

	arrange_branches_around_anchor(anchor, orphans)


func arrange_branches_around_anchor(anchor: GraphNode, to_arrange: Array[_Branch]) -> void:
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


func save_character(file: _OasisFile) -> void:
	for id in _branches:
		var section := str(id)
		var branch := _branches[id]
		file.set_value(section, _Save.Character.Branch.VALUE, branch.get_text())
		file.set_value(section, _Save.Character.Branch.POSITION_OFFSET, branch.position_offset)


func load_character(file: _OasisFile) -> void:
	_stop_tween()
	remove_branches()

	for key in file.get_sections():
		if not key.is_valid_int():
			continue

		var id := key.to_int()
		add_branch(id, true)

		var branch = _branches[id]
		branch.set_text(file.get_value(key, _Save.Character.Branch.VALUE, ""))
		branch.position_offset = file.get_value(
				key,
				_Save.Character.Branch.POSITION_OFFSET,
				Vector2.ZERO
		)


func save_character_config(config: ConfigFile) -> void:
	const section := "graph"
	config.set_value(
			_Save.Character.Config.GRAPH,
			_Save.Character.Config.Graph.ZOOM,
			snappedf(zoom, 0.01),
	)
	config.set_value(
			_Save.Character.Config.GRAPH,
			_Save.Character.Config.Graph.SCROLL_OFFSET,
			scroll_offset,
	)


func load_character_config(config: ConfigFile) -> void:
	zoom = config.get_value(
			_Save.Character.Config.GRAPH,
			_Save.Character.Config.Graph.ZOOM,
			zoom,
	)
	scroll_offset = config.get_value(
			_Save.Character.Config.GRAPH,
			_Save.Character.Config.Graph.SCROLL_OFFSET,
			scroll_offset,
	)


func _setup_tween() -> void:
	if not _tween:
		_tween = get_tree().create_tween()
	elif _tween and not _tween.is_valid():
		_tween.kill()
		_tween = get_tree().create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_parallel()


func _stop_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
		_tween = null
