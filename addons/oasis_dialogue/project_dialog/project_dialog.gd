@tool
extends Control

const _FileDialogButton := preload("res://addons/oasis_dialogue/project_dialog/file_dialog_button.gd")
const _FileDialog := preload("res://addons/oasis_dialogue/project_dialog/file_dialog.gd")

signal path_requested(path: String)

func _ready() -> void:
	var system_dialog_factory := func():
		var dialog := _FileDialog.new()
		dialog.init_file_mode(FileDialog.FILE_MODE_OPEN_DIR)
		get_tree().root.add_child(dialog)
		return dialog

	var open_button: _FileDialogButton = $VBoxContainer/OpenProject
	open_button.init(system_dialog_factory)
	open_button.path_selected.connect(path_requested.emit)
