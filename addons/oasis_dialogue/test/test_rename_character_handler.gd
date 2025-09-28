extends GutTest

const RenameCharacterHandler := preload("res://addons/oasis_dialogue/rename_character_handler.gd")
const InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")
const InputDialogScene := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.tscn")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")

var sut: RenameCharacterHandler = null
var model: Model = null
var dialog: InputDialog = null
var dialog_factory := Callable()


func before_all() -> void:
	dialog_factory = func():
		dialog = double(InputDialogScene).instantiate()
		add_child(dialog)
		return dialog


func before_each() -> void:
	model = double(Model).new()
	sut = RenameCharacterHandler.new(model, dialog_factory)


func test_validate_new_name() -> void:
	stub(model.has_character).to_return(false)

	assert_eq(sut._validate("fred"), "")


func test_validate_existing() -> void:
	stub(model.has_character).to_return(true)

	assert_ne(sut._validate("fred"), "")


func test_rename_confirmed() -> void:
	watch_signals(sut)
	stub(model.get_active_character).to_return("fred")

	sut.rename()
	dialog.confirmed.emit("tom")

	assert_signal_emitted(sut.character_renamed, ["tom"])


func test_rename_canceled() -> void:
	watch_signals(sut)
	stub(model.get_active_character).to_return("fred")

	sut.rename()
	dialog.canceled.emit()

	assert_signal_not_emitted(sut.character_renamed)
