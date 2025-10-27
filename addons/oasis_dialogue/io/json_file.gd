extends RefCounted


var _data := {}


func load(path: String) -> Error:
	path = _format_path(path)
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return FileAccess.get_open_error()
	var contents := file.get_as_text()
	file.close()
	_data = JSON.parse_string(contents)
	return Error.OK


func save(path: String) -> Error:
	path = _format_path(path)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(_data, "\t"))
	return Error.OK


func set_value(key: String, value) -> void:
	_data[key] = value


func get_value(key: String, default: Variant = null):
	return _data.get(key, default)


func _format_path(path: String) -> String:
	var result := path
	if result.get_extension() != "json":
		result += ".json"
	return result
