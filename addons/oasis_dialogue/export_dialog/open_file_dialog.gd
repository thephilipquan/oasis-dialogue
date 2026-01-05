@tool
extends TextureButton

const _FileDialog := preload("res://addons/oasis_dialogue/project_dialog/file_dialog.gd")

signal selected(path: String)

var _last_export_path := ""


func init_last_export_path(path: String) ->void:
	_last_export_path = path


func _on_button_up() -> void:
	var dialog := _FileDialog.new()
	dialog.init_file_mode(FileDialog.FileMode.FILE_MODE_OPEN_ANY)
	dialog.init_default_filename("dialogue")
	add_child(dialog)
	dialog.current_path = ProjectSettings.globalize_path(_last_export_path)

	dialog.canceled.connect(_on_canceled.bind(dialog))
	dialog.selected.connect(_on_selected.bind(dialog))
	dialog.show()


func _on_canceled(dialog: _FileDialog) -> void:
	dialog.get_parent().remove_child(dialog)
	dialog.queue_free()


func _on_selected(path: String, dialog: _FileDialog) -> void:
	selected.emit(path)
	_on_canceled(dialog)
