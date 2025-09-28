extends GutTest

const AddCharacterButton := preload("res://addons/oasis_dialogue/buttons/add_character_button.gd")
const InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.gd")
const InputDialogScene := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.tscn")
const Model := preload("res://addons/oasis_dialogue/model/model.gd")

var sut: AddCharacterButton = null
var model: Model = null
var dialog: InputDialog = null
var dialog_factory := Callable()


func before_all() -> void:
	dialog_factory = func():
		dialog = double(InputDialogScene).instantiate()
		add_child(dialog)
		return dialog


func before_each() -> void:
	sut = AddCharacterButton.new()
	model = double(Model).new()
	sut.init(model, dialog_factory)

	add_child_autofree(sut)


func test_dialog_done() -> void:
	watch_signals(sut)

	sut._on_button_up()
	dialog.confirmed.emit("fred")
	await wait_physics_frames(1)

	assert_signal_emitted_with_parameters(sut.character_added, ["fred"])


func test_dialog_cancel() -> void:
	watch_signals(sut)

	sut._on_button_up()
	dialog.canceled.emit()
	await wait_physics_frames(1)

	assert_signal_not_emitted(sut.character_added)


func test_validate_new_name() -> void:
	stub(model.has_character).to_return(false)

	var got := sut._validate("fred")

	assert_eq(got, "")


func test_validate_blank() -> void:
	var got := sut._validate("")

	assert_ne(got, "")


func test_validate_existing_name() -> void:
	stub(model.has_character).to_return(true)

	var got := sut._validate("fred")

	assert_ne(got, "")
