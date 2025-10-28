@tool
extends Control

const REGISTRY_KEY := "project_dialog"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _FileDialogButton := preload("res://addons/oasis_dialogue/project_dialog/file_dialog_button.gd")
const _FileDialog := preload("res://addons/oasis_dialogue/project_dialog/file_dialog.gd")
const _UserManager := preload("res://addons/oasis_dialogue/main/user_manager.gd")

signal path_requested(path: String)

var _get_last_open_path := Callable()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var user_manager: _UserManager = registry.at(_UserManager.REGISTRY_KEY)
	init_get_last_open_path(user_manager.get_last_open_path)


func init_get_last_open_path(callback: Callable) -> void:
	_get_last_open_path = callback


func display() -> void:
	var system_dialog_factory := func create_system_dialog() -> _FileDialog:
		var dialog := _FileDialog.new()
		dialog.init_file_mode(FileDialog.FILE_MODE_OPEN_DIR)
		get_tree().root.add_child(dialog)
		# Have to set after adding to tree.
		dialog.current_dir = _get_last_open_path.call()
		return dialog

	var open_button: _FileDialogButton = $VBoxContainer/OpenProject
	open_button.init(system_dialog_factory)
	open_button.path_selected.connect(path_requested.emit)
