extends Control

const _FileDialogButton := preload("res://addons/oasis_dialogue/project_dialog/file_dialog_button.gd")
const _FileDialog := preload("res://addons/oasis_dialogue/project_dialog/file_dialog.gd")

signal create_project_requested(path: String)
signal load_project_requested(path: String)

func _ready() -> void:
	var load_dialog_factory := func():
		var dialog := _FileDialog.new()
		dialog.init(FileDialog.FILE_MODE_OPEN_DIR)
		get_tree().root.add_child(dialog)
		return dialog

	var new_project: _FileDialogButton = $VBoxContainer/NewProject
	new_project.init(load_dialog_factory)
	new_project.path_selected.connect(create_project_requested.emit)

	var load_project: _FileDialogButton = $VBoxContainer/LoadProject
	load_project.init(load_dialog_factory)
	load_project.path_selected.connect(load_project_requested.emit)
