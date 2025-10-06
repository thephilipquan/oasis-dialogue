extends GutTest

const ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.gd")
const ConfirmDialogScene := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.tscn")
const RemoveCharacterButton := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")

var sut: RemoveCharacterButton = null
var dialog: ConfirmDialog = null
var dialog_factory := Callable()


func before_all() -> void:
	dialog_factory = func():
		dialog = double(ConfirmDialogScene).instantiate()
		add_child(dialog)
		return dialog


func before_each() -> void:
	sut = RemoveCharacterButton.new()
	sut.init_confirm_dialog_factory(dialog_factory)

	add_child_autofree(sut)


func test_has_no_branches() -> void:
	watch_signals(sut)
	sut.init_get_branch_count(func(): return 0)

	sut._on_button_up()

	assert_signal_emitted(sut.character_removed)


func test_has_branches_confirmed() -> void:
	watch_signals(sut)
	sut.init_get_branch_count(func(): return 1)
	sut.init_get_active_character(func(): return "")

	sut._on_button_up()
	dialog.confirmed.emit()
	await wait_physics_frames(1)

	assert_signal_emitted(sut.character_removed)


func test_has_branches_canceled() -> void:
	watch_signals(sut)
	sut.init_get_branch_count(func(): return 1)
	sut.init_get_active_character(func(): return "")

	sut._on_button_up()
	dialog.canceled.emit()
	await wait_physics_frames(1)

	assert_signal_not_emitted(sut.character_removed)
