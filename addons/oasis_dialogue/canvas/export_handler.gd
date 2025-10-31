@tool
extends Node

const REGISTRY_KEY := "export_handler"

const _Canvas := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _FileDialog := preload("res://addons/oasis_dialogue/project_dialog/file_dialog.gd")
const _ProjectMenu := preload("res://addons/oasis_dialogue/menu_bar/project.gd")
const _UserManager := preload("res://addons/oasis_dialogue/main/user_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

signal export_requested(path: String)

var _file_dialog_factory := Callable()
var _get_last_export_path := Callable()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	init_file_dialog_factory(registry.at(_Canvas.FILE_DIALOG_FACTORY_REGISTRY_KEY))

	var user_manager: _UserManager = registry.at(_UserManager.REGISTRY_KEY)
	init_get_last_export_path(user_manager.get_last_export_path)

	var project_menu: _ProjectMenu = registry.at(_ProjectMenu.REGISTRY_KEY)
	project_menu.export_requested.connect(show_file_dialog)


func init_file_dialog_factory(callback: Callable) -> void:
	_file_dialog_factory = callback


func init_get_last_export_path(callback: Callable) -> void:
	_get_last_export_path = callback


func show_file_dialog() -> void:
	var dialog: _FileDialog = _file_dialog_factory.call()
	dialog.init_default_filename("dialogue")
	dialog.init_extension("csv")
	dialog.init_file_mode(FileDialog.FILE_MODE_SAVE_FILE)
	dialog.selected.connect(on_dialog_selected.bind(dialog))
	dialog.canceled.connect(on_dialog_canceled.bind(dialog))
	get_tree().root.add_child(dialog)
	# Have to set after adding to tree.
	dialog.current_path = ProjectSettings.globalize_path(_get_last_export_path.call())


func on_dialog_canceled(dialog: _FileDialog) -> void:
	dialog.queue_free()
	dialog.get_parent().remove_child(dialog)


func on_dialog_selected(path: String, dialog: _FileDialog) -> void:
	on_dialog_canceled(dialog)
	export_requested.emit(path)
