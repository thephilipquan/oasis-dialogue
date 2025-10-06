extends GutTest

const RenameCharacterHandler := preload("res://addons/oasis_dialogue/canvas/rename_character_handler.gd")
const InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")
const InputDialogScene := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.tscn")

var sut: RenameCharacterHandler = null
var dialog: InputDialog = null
var dialog_factory := Callable()


func before_all() -> void:
	dialog_factory = func():
		dialog = double(InputDialogScene).instantiate()
		add_child(dialog)
		return dialog


func before_each() -> void:
	sut = RenameCharacterHandler.new()
	sut.input_dialog_factory = dialog_factory


func test_validate_new_name() -> void:
	sut.can_rename_to = func(s: String): return true

	assert_eq(sut._validate("fred"), "")


func test_validate_existing() -> void:
	sut.can_rename_to = func(s: String): return false

	assert_ne(sut._validate("fred"), "")


func test_rename_confirmed() -> void:
	sut.get_active_character = func(): return "fred"
	watch_signals(sut)

	sut.rename()
	dialog.confirmed.emit("tom")

	assert_signal_emitted(sut.character_renamed, ["tom"])


func test_rename_canceled() -> void:
	sut.get_active_character = func(): return "fred"
	watch_signals(sut)

	sut.rename()
	dialog.canceled.emit()

	assert_signal_not_emitted(sut.character_renamed)
