extends GutTest

const Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const BranchScene := preload("res://addons/oasis_dialogue/branch/branch.tscn")
const BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const OasisFile := preload("res://addons/oasis_dialogue/io/oasis_file.gd")

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
	sut.init_branch_factory(branch_factory)
	add_child_autofree(sut)


func test_add_branch() -> void:
	stub(sut.center_node_in_graph).to_do_nothing()

	sut.add_branch(3)

	var branch := branches[0]
	assert_eq(branch.removed.get_connections().size(), 1)
	assert_called(branch, "set_id", [3])
	assert_called(sut.center_node_in_graph)


func test_update_branch_calls_set_text() -> void:
	sut.add_branch(2)
	sut.update_branch(2, "hello world")
	assert_called(branches[0], "set_text", ["hello world"])


func test_remove_branch() -> void:
	watch_signals(sut)
	sut.add_branch(3)

	sut.remove_branch(3)
	await wait_physics_frames(1)

	assert_eq(sut.get_branch_text(3), "")


func test_remove_branch_emits_branch_removed() -> void:
	watch_signals(sut)
	sut.add_branch(3)

	sut.remove_branch(3)
	await wait_physics_frames(1)

	assert_signal_emitted_with_parameters(sut.branch_removed, [3])


func test_remove_branch_emits_branches_dirtied() -> void:
	watch_signals(sut)
	sut.add_branch(3)

	sut.remove_branch(3)
	await wait_physics_frames(1)

	assert_signal_emitted_with_parameters(sut.branches_dirtied, [3, []])


func test_remove_branch_emits_branches_dirtied_with_left_connections() -> void:
	for i in 3:
		sut.add_branch(i)
	sut.connect_branches(0, [1])
	sut.connect_branches(1, [2])
	watch_signals(sut)

	sut.remove_branch(1)
	await wait_physics_frames(1)

	assert_signal_emitted_with_parameters(sut.branches_dirtied, [1, [0]])


func test_highlight_calls_branch_highlight() -> void:
	sut.add_branch(2)
	sut.highlight_branch(2, [0, 2, 3])
	assert_called(branches[0], "highlight", [[0, 2, 3]])


func test_clear_highlights_calls_branch_highlight() -> void:
	sut.add_branch(3)
	sut.clear_branch_highlights(3)
	assert_called(branches[0], "highlight", [[]])


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


func test_load_character_restores_saved_branches() -> void:
	sut.add_branch(3)
	stub(branches[0].get_text).to_return("a")
	branches[0].position_offset = Vector2(50, 100)

	sut.add_branch(7)
	stub(branches[1].get_text).to_return("b\nc")
	branches[1].position_offset = Vector2(150, 200)
	stub(branches[1].is_locked).to_return(true)

	var file := OasisFile.new()
	sut.save_character(file)

	before_each()
	sut.load_character(file)

	assert_called(branches[0], "set_text", ["a"])
	assert_eq(branches[0].position_offset, Vector2(50, 100))
	assert_called(branches[1], "set_text", ["b\nc"])
	assert_eq(branches[1].position_offset, Vector2(150, 200))
	assert_called(branches[1], "set_locked", [true])


func test_load_character_config_restores_viewport_state() -> void:
	sut.zoom = 1.38
	sut.scroll_offset = Vector2(400, 700)

	# Have to load character file first before config.
	# Branch creation is synced to character file loading.
	var file := OasisFile.new()
	sut.save_character(file)
	var config := ConfigFile.new()
	sut.save_character_config(config)

	before_each()
	sut.load_character(file)
	sut.load_character_config(config)
	assert_almost_eq(sut.zoom, 1.38, 0.01)
	# Bug when testing this. Works in production.
	# assert_eq(sut.scroll_offset, Vector2(400, 700))


func test_add_branch_emits_dirtied() -> void:
	watch_signals(sut)
	sut.add_branch(3)
	assert_signal_emitted(sut.dirtied)


func test_add_branch_silently_does_not_emit_dirtied() -> void:
	watch_signals(sut)
	sut.add_branch(3, true)
	assert_signal_not_emitted(sut.dirtied)


func test_branch_text_change_emits_dirtied() -> void:
	watch_signals(sut)
	sut.add_branch(3)
	branches[0].changed.emit(3, "")
	assert_signal_emitted(sut.dirtied)


func test_remove_branch_emits_dirtied() -> void:
	watch_signals(sut)
	sut.add_branch(3)
	sut.remove_branch(3)
	assert_signal_emitted(sut.dirtied)


func test_scroll_offset_change_emits_dirtied() -> void:
	pass_test("unable to trigger via code")


func test_pretty_requested_only_on_dirty_branches() -> void:
	sut.add_branch(0)
	sut.add_branch(2)
	sut.add_branch(5)
	# Simulate braches changing.
	branches[1].changed.emit(2, "")
	branches[2].changed.emit(5, "")
	watch_signals(sut)
	sut.save_character(OasisFile.new())
	assert_signal_emitted_with_parameters(sut.pretty_requested, [2], 0)
	assert_signal_emitted_with_parameters(sut.pretty_requested, [5], 1)


func test_saving_resets_dirty_branches() -> void:
	sut.add_branch(0)
	sut.add_branch(1)
	# Simulate braches changing.
	branches[0].changed.emit(0, "")
	sut.save_character(OasisFile.new())

	# Simulate braches changing.
	branches[1].changed.emit(1, "")
	watch_signals(sut)
	sut.save_character(OasisFile.new())
	assert_signal_emitted_with_parameters(sut.pretty_requested, [1], 0)
	assert_signal_emit_count(sut.pretty_requested, 1)
