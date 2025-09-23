extends GutTest

const GraphController := preload("res://addons/oasis_dialogue/canvas/graph_controller.gd")

var sut: GraphController = null
var graph: GraphEdit = null
var tween_ref: WeakRef = null


func before_each() -> void:
	graph = GraphEdit.new()
	add_child_autofree(graph)
	sut = GraphController.new()
	sut.init(
		func():
			var tween := graph.get_tree().create_tween()
			tween_ref = weakref(tween)
			return tween
	)


func test_set_value() -> void:
	sut.duration = 0.8
	assert_eq(sut.duration, 0.8)


func test_set_value_below_zero() -> void:
	sut.duration = -3
	assert_gt(sut.duration, 0.0)


func test_disable_orphan_slots() -> void:
	var nodes := _create_graph_nodes(3)
	for node in nodes:
		node.set_slot_enabled_left(0, true)
		node.set_slot_enabled_right(0, true)
		graph.add_child(node)
	graph.connect_node(nodes[1].name, 0, nodes[2].name, 0)

	sut.disable_unused_slots(graph)
	assert_false(nodes[0].is_slot_enabled_left(0))
	assert_false(nodes[0].is_slot_enabled_right(0))
	assert_false(nodes[1].is_slot_enabled_left(0))
	assert_true(nodes[1].is_slot_enabled_right(0))
	assert_true(nodes[2].is_slot_enabled_left(0))
	assert_false(nodes[2].is_slot_enabled_right(0))


func test_arrange_nodes_around_anchor() -> void:
	var nodes := _create_graph_nodes(3)
	nodes[0].position_offset = Vector2(200, 300)
	nodes[1].position_offset = Vector2(0, 0)
	nodes[2].position_offset = Vector2(0, 0)
	for node in nodes:
		node.set_slot_enabled_left(0, true)
		node.set_slot_enabled_right(0, true)
		graph.add_child(node)
	graph.connect_node(nodes[0].name, 0, nodes[1].name, 0)

	sut.arrange_nodes_around_anchor(nodes[0], [nodes[1]], graph)
	var tween: Tween = tween_ref.get_ref()

	if not tween:
		fail_test("")
		return

	await tween.finished

	assert_eq(nodes[0].position_offset, Vector2(200, 300))
	assert_gt(nodes[1].position_offset.x, 200.0)
	assert_eq(nodes[2].position_offset, Vector2(0, 0))


func test_arrange_nodes_around_anchor_ignore_selected() -> void:
	var nodes := _create_graph_nodes(3)
	nodes[0].position_offset = Vector2(200, 300)
	nodes[1].position_offset = Vector2(0, 0)
	nodes[2].position_offset = Vector2(0, 0)
	for node in nodes:
		node.set_slot_enabled_left(0, true)
		node.set_slot_enabled_right(0, true)
		graph.add_child(node)
	graph.connect_node(nodes[0].name, 0, nodes[1].name, 0)
	nodes[2].selected = true

	sut.arrange_nodes_around_anchor(nodes[0], [nodes[1]], graph)
	var tween: Tween = tween_ref.get_ref()

	if not tween:
		fail_test("")
		return

	await tween.finished

	assert_eq(nodes[0].position_offset, Vector2(200, 300))
	assert_gt(nodes[1].position_offset.x, 200.0)
	assert_eq(nodes[2].position_offset, Vector2(0, 0))


func test_arrange_orphans() -> void:
	var nodes := _create_graph_nodes(3)
	nodes[0].position_offset = Vector2(0, 0)
	nodes[1].position_offset = Vector2(200, 200)
	nodes[2].position_offset = Vector2(300, 300)
	for node in nodes:
		node.set_slot_enabled_left(0, true)
		node.set_slot_enabled_right(0, true)
		graph.add_child(node)
	graph.connect_node(nodes[0].name, 0, nodes[1].name, 0)

	sut.arrange_orphans(graph)
	var tween: Tween = tween_ref.get_ref()

	if not tween:
		fail_test("")
		return

	await tween.finished

	assert_eq(nodes[0].position_offset, Vector2(0, 0))
	assert_eq(nodes[1].position_offset, Vector2(200, 200))
	assert_eq(nodes[2].position_offset.x, 0.0)
	assert_gt(nodes[2].position_offset.y, 0.0)


func _create_graph_nodes(count: int) -> Array[GraphNode]:
	var nodes: Array[GraphNode] = []
	for i in count:
		nodes.push_back(GraphNode.new())
		nodes[i].add_child(LineEdit.new())
	return nodes
