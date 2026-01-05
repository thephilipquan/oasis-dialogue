@tool
extends Control

const _DefaultAnnotationData := preload("res://addons/oasis_dialogue/export_dialog/model/default_annotation_data.gd")
const _ExportConfig := preload("res://addons/oasis_dialogue/model/export_config.gd")
const _OpenFileDialog := preload("res://addons/oasis_dialogue/export_dialog/open_file_dialog.gd")
const _Status := preload("res://addons/oasis_dialogue/export_dialog/status.gd")
const _ToggleButton := preload("res://addons/oasis_dialogue/controls/toggle_button/toggle_button.gd")

signal canceled
signal finished(data: _ExportConfig)

var _data := _ExportConfig.new()

@export_group("Private")
@export
var _toggle_button: _ToggleButton = null
@export
var _default_annotation: OptionButton = null
@export
var _language: LineEdit = null
@export
var _path: LineEdit = null
@export
var _file_system_button: _OpenFileDialog = null
@export
var _status: _Status = null
@export
var _export: Button = null


enum _StatusKey {
	DEFAULT_ANNOTATION,
	LANGUAGE,
	PATH,
}

func init_default_annotation_data(data: _DefaultAnnotationData) -> void:
	_default_annotation.clear()
	if data.default:
		_default_annotation.add_item(data.default)
		_default_annotation.select(0)
		_default_annotation.disabled = true
	elif data.options:
		for option in data.options:
			_default_annotation.add_item(option)
	else:
		_invalidate(_default_annotation, "normal")
		_status.queue(
				_StatusKey.DEFAULT_ANNOTATION,
				"No annotations available. Add exclusive annotations to definitions",
		)


func init_last_export(last_export: _ExportConfig) -> void:
	_data.copy_from(last_export)
	_toggle_button.selected = _data.is_directory_export

	_data.default_annotation = last_export.default_annotation

	# Will be disabled if there is a default annotation.
	if not _default_annotation.disabled:
		_select_default_annotation_item(_data.default_annotation)

	_language.text = _data.language
	_path.text = _data.path
	_file_system_button.init_last_export_path(_data.path)
	_update_export_button()


func set_single_export() -> void:
	_data.is_directory_export = false


func set_directory_export()  -> void:
	_data.is_directory_export = true


func set_default_annotation(annotation: String) -> void:
	_data.default_annotation = annotation
	if _data.default_annotation:
		_validate(_default_annotation, "normal")
		_status.resolve(_StatusKey.DEFAULT_ANNOTATION)
	else:
		_invalidate(_default_annotation, "normal")
		_status.queue(_StatusKey.DEFAULT_ANNOTATION, "The default annotation cannot be empty")
	_update_export_button()


func set_language(code: String) -> void:
	_data.language = code
	if _data.language:
		_validate(_language, "normal")
		_status.resolve(_StatusKey.LANGUAGE)
	else:
		_invalidate(_language, "normal")
		_status.queue(_StatusKey.LANGUAGE, "The language cannot be empty")
	_update_export_button()


func set_path(path: String) -> void:
	_data.path = path
	if _data.path:
		_validate(_path, "normal")
		_status.resolve(_StatusKey.PATH)
	else:
		_invalidate(_path, "normal")
		_status.queue(_StatusKey.PATH, "The path cannot be empty")
	_update_export_button()


func export() -> void:
	finished.emit(_data)


func _select_default_annotation_item(with_text: String) -> void:
	var index := -1
	for i in _default_annotation.item_count:
		if _default_annotation.get_item_text(i) == with_text:
			index = i
	_default_annotation.select(index)


func _invalidate(control: Control, style_name: String) -> void:
	var style: StyleBoxFlat = control.get_theme_stylebox(style_name).duplicate()
	style.set_border_width_all(2)
	style.border_color = get_theme_color("invalid_color", "Project")
	control.add_theme_stylebox_override(style_name, style)


func _validate(control: Control, style_name: String) -> void:
	control.remove_theme_stylebox_override(style_name)


func _update_export_button() -> void:
	_export.disabled = not (
			_data.default_annotation
			and _data.language
			and _data.path
	)


func close() -> void:
	canceled.emit()
