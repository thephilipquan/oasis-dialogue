extends GutTest

const FileDialogButtonn := preload("res://addons/oasis_dialogue/project_dialog/file_dialog_button.gd")
const _FileDialog := preload("res://addons/oasis_dialogue/project_dialog/file_dialog.gd")

var sut: FileDialogButtonn = null
var dialog_factory := Callable()
var dialog: _FileDialog = null


func before_all() -> void:
	dialog_factory = func():
		dialog = double(_FileDialog).new()
		add_child(dialog)
		return dialog


func before_each() -> void:
	sut = FileDialogButtonn.new()
	sut.init(dialog_factory)

	add_child_autofree(sut)


func test_cancel() -> void:
	watch_signals(sut)

	sut._on_button_up()
	dialog.canceled.emit()
	await wait_physics_frames(1)

	assert_signal_not_emitted(sut.path_selected)


func test_selected() -> void:
	watch_signals(sut)

	sut._on_button_up()
	dialog.selected.emit("some/path")
	await wait_physics_frames(1)

	assert_signal_emitted_with_parameters(sut.path_selected, ["some/path"])
