@tool
extends Button

const _FileDialog := preload("res://addons/oasis_dialogue/project_dialog/file_dialog.gd")

signal path_selected(path: String)

var _load_dialog_factory := Callable()


func _ready() -> void:
	button_up.connect(_on_button_up)


func init(load_dialog_factory: Callable) -> void:
	_load_dialog_factory = load_dialog_factory


func _on_button_up() -> void:
	var dialog: _FileDialog = _load_dialog_factory.call()
	dialog.selected.connect(_on_dialog_selected.bind(dialog))
	dialog.canceled.connect(_on_dialog_canceled.bind(dialog))


func _on_dialog_canceled(dialog: _FileDialog) -> void:
	dialog.get_parent().remove_child(dialog)
	dialog.queue_free()


func _on_dialog_selected(path: String, dialog: _FileDialog) -> void:
	_on_dialog_canceled(dialog)
	path_selected.emit(path)
