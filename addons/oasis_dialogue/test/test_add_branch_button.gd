extends GutTest

const AddBranchButton := preload("res://addons/oasis_dialogue/canvas/add_branch_button.gd")

var sut: AddBranchButton = null


func before_each() -> void:
	sut = AddBranchButton.new()
	add_child_autofree(sut)


func test_emits_branch_added() -> void:
	sut.init_get_branch_ids(func() -> Array[int]: return [0, 1])
	watch_signals(sut)

	sut._on_button_up()

	assert_signal_emitted(sut, "branch_added", [2])
