extends GutTest

const AddBranchButton := preload("res://addons/oasis_dialogue/canvas/add_branch_button.gd")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")

var sut: AddBranchButton = null
var model: Model = null


func before_each() -> void:
	sut = AddBranchButton.new()
	model = double(Model).new()
	sut.init(model)
	add_child_autofree(sut)


func test_emits_branch_added() -> void:
	stub(model.get_branch_ids).to_call(
		func():
			var ids: Array[int] = [0, 1]
			return ids
	)
	watch_signals(sut)

	sut._on_button_up()

	assert_signal_emitted(sut, "branch_added", [2])
