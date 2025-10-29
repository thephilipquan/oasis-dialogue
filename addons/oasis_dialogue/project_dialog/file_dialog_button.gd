@tool
extends Button

const _FileDialog := preload("res://addons/oasis_dialogue/project_dialog/file_dialog.gd")

signal path_selected(path: String)

var _system_dialog_factory := Callable()


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	button_up.connect(_on_button_up)


func init(system_dialog_factory: Callable) -> void:
	_system_dialog_factory = system_dialog_factory


func _on_button_up() -> void:
	var dialog: _FileDialog = _system_dialog_factory.call()
	dialog.selected.connect(_on_dialog_selected.bind(dialog))
	dialog.canceled.connect(_on_dialog_canceled.bind(dialog))


func _on_dialog_canceled(dialog: _FileDialog) -> void:
	dialog.get_parent().remove_child(dialog)
	dialog.queue_free()


func _on_dialog_selected(path: String, dialog: _FileDialog) -> void:
	_on_dialog_canceled(dialog)
	path_selected.emit(path)
