@tool
extends Button

const REGISTRY_KEY := "open_project"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _FileDialog := preload("res://addons/oasis_dialogue/project_dialog/file_dialog.gd")
const _UserManager := preload("res://addons/oasis_dialogue/main/user_manager.gd")

signal path_requested(path: String)

var _get_last_open_path := Callable()
var _file_dialog_factory := Callable()


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	button_up.connect(show_file_dialog)


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var user_manager: _UserManager = registry.at(_UserManager.REGISTRY_KEY)
	init_get_last_open_path(user_manager.get_last_open_path)

	init_file_dialog_factory(create_system_dialog)

func create_system_dialog() -> _FileDialog:
	var dialog := _FileDialog.new()
	dialog.init_file_mode(FileDialog.FILE_MODE_OPEN_DIR)
	get_tree().root.add_child(dialog)

	# Have to set after adding to tree.
	dialog.current_dir = _get_last_open_path.call()

	return dialog


func init_get_last_open_path(callback: Callable) -> void:
	_get_last_open_path = callback


func init_file_dialog_factory(callback: Callable) -> void:
	_file_dialog_factory = callback


func show_file_dialog() -> void:
	var dialog: _FileDialog = _file_dialog_factory.call()
	dialog.selected.connect(_on_dialog_selected.bind(dialog))
	dialog.canceled.connect(_on_dialog_canceled.bind(dialog))


func _on_dialog_canceled(dialog: _FileDialog) -> void:
	dialog.get_parent().remove_child(dialog)
	dialog.queue_free()


func _on_dialog_selected(path: String, dialog: _FileDialog) -> void:
	_on_dialog_canceled(dialog)
	path_requested.emit(path)
