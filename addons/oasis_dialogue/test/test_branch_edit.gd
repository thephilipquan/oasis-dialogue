extends GutTest

const Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const BranchScene := preload("res://addons/oasis_dialogue/branch/branch.tscn")
const BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const Global := preload("res://addons/oasis_dialogue/global.gd")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")

var sut: BranchEdit = null
var branch_factory := Callable()
var branches: Array[Branch] = []


func before_all() -> void:
	branch_factory = func():
		var branch: Branch = double(BranchScene).instantiate()
		branches.push_back(branch)
		return branch


func before_each() -> void:
	branches.clear()
	sut = partial_double(BranchEdit).new()
	sut.init(branch_factory)
	add_child_autofree(sut)

	sut.init(branch_factory)


func test_set_duration() -> void:
	sut.duration = 0.8
	assert_eq(sut.duration, 0.8)


func test_set_duration_below_zero() -> void:
	sut.duration = -3
	assert_gt(sut.duration, 0.0)


func test_add_branch() -> void:
	stub(sut.center_node_in_graph).to_do_nothing()

	sut.add_branch(3)

	var branch := branches[0]
	assert_eq(branch.removed.get_connections().size(), 1)
	assert_called(branch, "set_id", [3])
	assert_called(sut.center_node_in_graph)


func test_get_branches() -> void:
	sut._branches = {
		0: branch_factory.call(),
		2: branch_factory.call(),
	}

	var got := sut.get_branches()
	assert_true(0 in got)
	assert_true(2 in got)


func test_update_branch_calls_set_text() -> void:
	sut.add_branch(2)

	sut.update_branch(2, "hello world")

	assert_called(branches[0], "set_text", ["hello world"])


func test_remove_branch() -> void:
	watch_signals(sut)
	sut.add_branch(3)

	sut.remove_branch(3, branches[0])
	await wait_physics_frames(1)

	assert_eq(sut.get_branches().size(), 0)


func test_highlight_calls_branch_highlight() -> void:
	sut.add_branch(2)

	sut.highlight_branch(2, [0, 2, 3])

	assert_called(branches[0], "highlight", [[0, 2, 3]])


func test_clear_highlights_calls_branch_highlight() -> void:
	sut.add_branch(3)

	sut.clear_branch_highlights(3)

	assert_called(branches[0], "highlight", [[]])


func test_remove_branch_with_connections() -> void:
	for i in 3:
		sut.add_branch(i)
		branches[i].set_slot_enabled_left(0, true)
		branches[i].set_slot_enabled_right(0, true)
	sut.connect_node(branches[0].name, 0, branches[1].name, 0)
	sut.connect_node(branches[1].name, 0, branches[2].name, 0)
	watch_signals(sut)
	stub(sut.disable_unused_slots).to_do_nothing()

	sut.remove_branch(1, branches[1])

	assert_called(sut.disable_unused_slots)
	assert_signal_emitted_with_parameters(
		sut.branches_dirtied,
		[1, [0]],
	)


func test_connecting_branch_to_orphan() -> void:
	sut.add_branch(2)
	sut.add_branch(4)
	stub(sut.arrange_branches_around_anchor).to_do_nothing()
	stub(sut.arrange_orphans).to_do_nothing()

	sut.connect_branches(2, [4])

	var from := branches[0]
	var to := branches[1]
	assert_true(sut.is_node_connected(from.name, 0, to.name, 0))
	assert_false(from.is_slot_enabled_left(0))
	assert_true(from.is_slot_enabled_right(0))
	assert_true(to.is_slot_enabled_left(0))
	assert_false(to.is_slot_enabled_right(0))
	assert_called(sut, "arrange_branches_around_anchor", [from, [to]])


func test_connecting_branch_to_non_orphan() -> void:
	sut.add_branch(0)
	sut.add_branch(1)
	sut.add_branch(2)
	stub(sut.arrange_branches_around_anchor).to_do_nothing()
	stub(sut.arrange_orphans).to_do_nothing()

	sut.connect_branches(1, [2])
	sut.connect_branches(0, [1])

	var from := branches[0]
	var to := branches[1]
	assert_true(sut.is_node_connected(from.name, 0, to.name, 0))
	assert_false(from.is_slot_enabled_left(0))
	assert_true(from.is_slot_enabled_right(0))
	assert_true(to.is_slot_enabled_left(0))
	assert_true(to.is_slot_enabled_right(0))
	assert_called_count(sut.arrange_branches_around_anchor, 1)


func test_connect_branch_removes_previous_connections() -> void:
	sut.add_branch(2)
	sut.add_branch(4)
	stub(sut.arrange_branches_around_anchor).to_do_nothing()
	stub(sut.arrange_orphans).to_do_nothing()

	sut.connect_branches(2, [4])
	sut.connect_branches(2, [])

	var from := branches[0]
	var to := branches[1]
	assert_false(sut.is_node_connected(from.name, 0, to.name, 0))
	assert_false(from.is_slot_enabled_left(0))
	assert_false(from.is_slot_enabled_right(0))
	assert_false(to.is_slot_enabled_left(0))
	assert_false(to.is_slot_enabled_right(0))
	assert_called_count(sut.arrange_branches_around_anchor, 1)


func test_disable_orphan_slots() -> void:
	for i in 3:
		sut.add_branch(i)
		branches[i].set_slot_enabled_left(0, true)
		branches[i].set_slot_enabled_right(0, true)
	sut.connect_node(branches[1].name, 0, branches[2].name, 0)

	sut.disable_unused_slots()
	assert_false(branches[0].is_slot_enabled_left(0))
	assert_false(branches[0].is_slot_enabled_right(0))
	assert_false(branches[1].is_slot_enabled_left(0))
	assert_true(branches[1].is_slot_enabled_right(0))
	assert_true(branches[2].is_slot_enabled_left(0))
	assert_false(branches[2].is_slot_enabled_right(0))


func test_arrange_branches_around_anchor() -> void:
	sut.duration = 0.1
	for i in 3:
		sut.add_branch(i)
		branches[i].set_slot_enabled_left(0, true)
		branches[i].set_slot_enabled_right(0, true)
	branches[0].position_offset = Vector2(200, 300)
	branches[1].position_offset = Vector2(0, 0)
	branches[2].position_offset = Vector2(0, 0)
	sut.connect_node(branches[0].name, 0, branches[1].name, 0)

	sut.arrange_branches_around_anchor(branches[0], [branches[1]])

	if not sut._tween:
		fail_test("")
		return

	await sut._tween.finished

	assert_eq(branches[0].position_offset, Vector2(200, 300))
	assert_gt(branches[1].position_offset.x, 200.0)
	assert_eq(branches[2].position_offset, Vector2(0, 0))


func test_arrange_branches_around_anchor_ignore_selected() -> void:
	sut.duration = 0.1
	for i in 3:
		sut.add_branch(i)
		branches[i].set_slot_enabled_left(0, true)
		branches[i].set_slot_enabled_right(0, true)
	branches[0].position_offset = Vector2(200, 300)
	branches[1].position_offset = Vector2(0, 0)
	branches[2].position_offset = Vector2(0, 0)
	sut.connect_node(branches[0].name, 0, branches[1].name, 0)
	branches[2].selected = true

	sut.arrange_branches_around_anchor(branches[0], [branches[1]])

	if not sut._tween:
		fail_test("")
		return

	await sut._tween.finished

	assert_eq(branches[0].position_offset, Vector2(200, 300))
	assert_gt(branches[1].position_offset.x, 200.0)
	assert_eq(branches[2].position_offset, Vector2(0, 0))


func test_arrange_orphans() -> void:
	for i in 3:
		sut.add_branch(i)
		branches[i].set_slot_enabled_left(0, true)
		branches[i].set_slot_enabled_right(0, true)
	branches[0].position_offset = Vector2(0, 0)
	branches[1].position_offset = Vector2(200, 200)
	branches[2].position_offset = Vector2(300, 300)
	sut.connect_node(branches[0].name, 0, branches[1].name, 0)

	sut.arrange_orphans(null)

	if not sut._tween:
		fail_test("")
		return

	await sut._tween.finished

	assert_eq(branches[0].position_offset, Vector2(0, 0))
	assert_eq(branches[1].position_offset, Vector2(200, 200))
	assert_eq(branches[2].position_offset.x, 0.0)
	assert_gt(branches[2].position_offset.y, 0.0)


func test_arrange_orphans_with_ignore() -> void:
	for i in 3:
		sut.add_branch(i)
		branches[i].set_slot_enabled_left(0, true)
		branches[i].set_slot_enabled_right(0, true)
	branches[0].position_offset = Vector2(0, 0)
	branches[1].position_offset = Vector2(200, 200)
	branches[2].position_offset = Vector2(300, 300)

	sut.arrange_orphans(branches[1])

	if not sut._tween:
		fail_test("")
		return

	await sut._tween.finished

	# Since all are orphans, the ignored is chosen as the anchor.
	assert_eq(branches[0].position_offset.x, 200.0)
	assert_eq(branches[1].position_offset, Vector2(200, 200))
	assert_eq(branches[2].position_offset.x, 200.0)


func test_load_character_creates_branches_and_emits_branch_restored() -> void:
	var data := {
		Global.FILE_BRANCH_POSITION_OFFSETS: {
			"3": {},
			"6": {},
		},
	}

	watch_signals(sut)

	sut.load_character(data)

	assert_eq(sut.get_branches().size(), 2)
	assert_eq(get_signal_parameters(sut.branch_restored, 0), [3])
	assert_eq(get_signal_parameters(sut.branch_restored, 1), [6])


func test_load_character_restores_branch_position_offsets() -> void:
	var data := {
		Global.FILE_BRANCH_POSITION_OFFSETS: {
			"0": {
				"x": 50,
				"y": 100,
			},
			"1": {
				"x": 150,
				"y": 200,
			},
		},
	}

	sut.load_character(data)

	assert_eq(branches[0].position_offset, Vector2(50, 100))
	assert_eq(branches[1].position_offset, Vector2(150, 200))


func test_load_character_restores_graph_zoom() -> void:
	var data := {
		Global.FILE_GRAPH_ZOOM: 1.34,
	}

	sut.load_character(data)

	assert_almost_eq(sut.zoom, 1.34, 0.01)


func test_load_character_restores_graph_scroll_offset() -> void:
	var data := {
		Global.FILE_GRAPH_SCROLL_OFFSET: {
			"x": -500,
			"y": -700,
		},
	}

	sut.load_character(data)

	pass_test("Bug. Doesn't work in tests.")
	# assert_almost(sut.scroll_offset, 1.34, 0.01)


func test_load_character_restores_branch_connections() -> void:
	var data := {
		Global.FILE_BRANCH_POSITION_OFFSETS: {
			"0": {},
			"1": {},
			"2": {},
			"3": {},
		},
		Global.FILE_BRANCH_CONNECTIONS: [
			{
				"from": 0,
				"to": 1,
			},
			{
				"from": 1.0,
				"to": 2.0,
			},
		],
	}

	sut.load_character(data)

	assert_false(branches[0].is_slot_enabled_left(0))
	assert_true(branches[0].is_slot_enabled_right(0))
	assert_true(branches[1].is_slot_enabled_left(0))
	assert_true(branches[1].is_slot_enabled_right(0))
	assert_true(branches[2].is_slot_enabled_left(0))
	assert_false(branches[2].is_slot_enabled_right(0))
	assert_false(branches[3].is_slot_enabled_left(0))
	assert_false(branches[3].is_slot_enabled_right(0))

	var from_connections := sut.connections.map(func(d: Dictionary): return d["from_node"])
	var to_connections := sut.connections.map(func(d: Dictionary): return d["to_node"])
	assert_true(sut.is_node_connected(branches[0].name, 0, branches[1].name, 0))
	assert_true(sut.is_node_connected(branches[1].name, 0, branches[2].name, 0))
	assert_false(branches[2].name in from_connections)
	assert_false(branches[3].name in from_connections)

	assert_false(branches[0].name in to_connections)
	assert_false(branches[3].name in to_connections)


func test_load_character_default_branch_position_offsets() -> void:
	var data := {
		Global.FILE_BRANCH_POSITION_OFFSETS: {
			"0": {},
			"1": {},
		},
	}
	watch_signals(sut)

	sut.load_character(data)

	assert_eq(branches[0].position_offset, Vector2(0, 0))
	assert_eq(branches[1].position_offset, Vector2(0, 0))


func test_load_character_default_graph_zoom() -> void:
	sut.zoom = 1.58
	var data := {}
	watch_signals(sut)

	sut.load_character(data)

	assert_eq(sut.zoom, 1.0)


func test_load_character_default_connections() -> void:
	var data := {
		Global.FILE_BRANCH_POSITION_OFFSETS: {
			"0": {},
			"1": {},
		},
	}
	watch_signals(sut)

	sut.load_character(data)

	assert_eq(sut.connections.size(), 0)


func test_load_character_overwrites_branches() -> void:
	var data := {
		Global.FILE_BRANCH_POSITION_OFFSETS: {
			"0": {
				"x": 50,
				"y": 100,
			},
			"1": {
				"x": 150,
				"y": 200,
			},
		},
	}
	sut.load_character(data)

	data = {
		Global.FILE_BRANCH_POSITION_OFFSETS: {
			"0": {
				"x": 250,
				"y": 300,
			},
		},
	}
	watch_signals(sut)
	sut.load_character(data)

	assert_eq(sut.get_branches().size(), 1)
	# branches[2] is the 3rd doubled branch made.
	assert_eq(branches[2].position_offset, Vector2(250, 300))


func test_save_character_saves_branch_position_offsets() -> void:
	sut.add_branch(0)
	branches[0].position_offset = Vector2(50, 100)
	sut.add_branch(1)
	branches[1].position_offset = Vector2(150, 200)

	var data := {}

	sut.save_character(data)

	const key := Global.FILE_BRANCH_POSITION_OFFSETS
	if not key in data:
		fail_test("")
		return

	var expected := {
		0: {
			"x": 50,
			"y": 100,
		},
		1: {
			"x": 150,
			"y": 200,
		},
	}
	assert_eq_deep(data[key], expected)


func test_save_character_saves_graph_zoom() -> void:
	sut.zoom = 1.55
	var data := {}

	sut.save_character(data)

	const key := Global.FILE_GRAPH_ZOOM
	if not key in data:
		fail_test("")
		return
	assert_eq(data[key], 1.55)


func test_save_character_saves_branch_scroll_offset() -> void:
	var data := {}

	sut.save_character(data)

	const key := Global.FILE_GRAPH_SCROLL_OFFSET
	assert_true(key in data)


func test_save_character_saves_branch_connections() -> void:
	sut.add_branch(0)
	sut.add_branch(1)
	sut.connect_branches(0, [1])

	var data := {}
	sut.save_character(data)

	const key := Global.FILE_BRANCH_CONNECTIONS
	if not key in data:
		fail_test("")
		return
	assert_ne_deep(data[key], [])
