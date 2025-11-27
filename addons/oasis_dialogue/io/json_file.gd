extends RefCounted

const _StringUtils := preload("res://addons/oasis_dialogue/utils/string_utils.gd")

signal saved(path: String)

var _loaded_data := {}


func load(path: String) -> Error:
	path = _format_path(path)
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return FileAccess.get_open_error()
	var contents := file.get_as_text()
	file.close()
	_loaded_data = JSON.parse_string(contents)
	return Error.OK


func get_loaded_data() -> Dictionary:
	var data := _loaded_data
	_loaded_data = {}
	return data


func save(path: String, data: Dictionary) -> Error:
	path = _format_path(path)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	file.store_line(JSON.stringify(data, "\t"))
	file.close()
	saved.emit(path)
	return Error.OK


func _format_path(path: String) -> String:
	return _StringUtils.replace_extension(path, "json")
