extends GutTest

const AddBranchButton := preload("res://addons/oasis_dialogue/buttons/add_branch_button.gd")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")

var sut: AddBranchButton = null
var model: Model = null


func before_each() -> void:
	sut = AddBranchButton.new()
	model = double(Model).new()
	sut._model = model
	add_child_autofree(sut)
	add_child_autofree(model)


func test_emits_next_id_is_sart() -> void:
	stub(model.get_character_count).to_return(1)
	stub(model.get_active_character).to_return("fred")
	stub(model.get_branch_ids).to_call(
		func():
			var ids: Array[int] = [1, 3, 4]
			return ids
	)
	watch_signals(sut)

	sut._on_button_up()

	assert_signal_emitted_with_parameters(sut.branch_added, [0])


func test_next_id_is_middle() -> void:
	stub(model.get_character_count).to_return(1)
	stub(model.get_active_character).to_return("fred")
	stub(model.get_branch_ids).to_call(
		func():
			var ids: Array[int] = [0, 1, 4]
			return ids
	)
	watch_signals(sut)

	sut._on_button_up()

	assert_signal_emitted_with_parameters(sut.branch_added, [2])


func test_next_id_in_end() -> void:
	stub(model.get_character_count).to_return(1)
	stub(model.get_active_character).to_return("fred")
	stub(model.get_branch_ids).to_call(
		func():
			var ids: Array[int] = [0, 1, 2, 3]
			return ids
	)
	watch_signals(sut)

	sut._on_button_up()

	assert_signal_emitted_with_parameters(sut.branch_added, [4])


func test_no_characters() -> void:
	watch_signals(sut)

	sut._on_button_up()

	assert_signal_not_emitted(sut.branch_added)


func test_no_active_character() -> void:
	stub(model.get_character_count).to_return(1)
	stub(model.get_active_character).to_return("")
	watch_signals(sut)

	sut._on_button_up()

	assert_signal_not_emitted(sut.branch_added)
