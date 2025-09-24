extends GutTest

const ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.gd")
const ConfirmDialogScene := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.tscn")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")
const RemoveCharacterButton := preload("res://addons/oasis_dialogue/buttons/remove_character_button.gd")

var sut: RemoveCharacterButton = null
var model: Model = null
var dialog: ConfirmDialog = null
var dialog_factory := Callable()


func before_all() -> void:
	dialog_factory = func():
		dialog = double(ConfirmDialogScene).instantiate()
		add_child(dialog)
		return dialog


func before_each() -> void:
	sut = RemoveCharacterButton.new()
	model = double(Model).new()
	sut._model = model
	sut.init(dialog_factory)

	add_child_autofree(sut)
	add_child_autofree(model)


func test_has_no_branches() -> void:
	watch_signals(sut)
	stub(model.get_branch_count).to_return(0)

	sut._on_button_up()

	assert_signal_emitted(sut.character_removed)


func test_has_branches_confirmed() -> void:
	watch_signals(sut)
	stub(model.get_branch_count).to_return(1)
	stub(model.get_active_character).to_return("")

	sut._on_button_up()
	dialog.confirmed.emit()
	await wait_physics_frames(1)

	assert_signal_emitted(sut.character_removed)


func test_has_branches_canceled() -> void:
	watch_signals(sut)
	stub(model.get_branch_count).to_return(1)
	stub(model.get_active_character).to_return("")

	sut._on_button_up()
	dialog.canceled.emit()
	await wait_physics_frames(1)

	assert_signal_not_emitted(sut.character_removed)
