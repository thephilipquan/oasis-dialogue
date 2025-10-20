extends RefCounted

var _data := {}


func load(path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return FileAccess.get_open_error()
	var contents := file.get_as_text()
	file.close()
	parse(contents)
	return Error.OK


func get_keys() -> Array[String]:
	var keys: Array[String] = []
	keys.assign(_data.keys())
	return keys


func has_key(key: String) -> bool:
	return key in _data


func set_value(key: String, value) -> void:
	_data[key] = value


func get_value(key: String, default = null):
	return _data.get(key, default)


func save(path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	file.store_string(encode_to_text())
	return Error.OK


## Parses and appends the text as formatted as a [b].oasis[/b] file.
## [br][br]
##
func parse(text: String) -> Error:
	var new_data := {}
	var lines := text.split("\n")
	var i := 0
	var key := ""
	var value_start := -1
	while i < lines.size():
		var line := lines[i]
		# missing closing bracket
		if line.begins_with("["):
			if not line.ends_with("]"):
				return Error.ERR_FILE_CORRUPT
			var tag := line.substr(1, line.length() - 2) # -2 = [ and ]
			# key is empty.
			if not tag:
				return Error.ERR_FILE_CORRUPT

			if tag == "/":
				# empty value.
				if value_start == -1:
					return Error.ERR_FILE_CORRUPT
				new_data[key] = "\n".join(lines.slice(value_start, i))
				key = ""
				value_start = -1
				# skip newline after terminating tag..
				i += 1
			elif tag in _data or tag in new_data:
				return Error.ERR_FILE_CORRUPT
			# never saw terminating tag.
			elif key != "":
				return Error.ERR_FILE_CORRUPT
			else:
				key = tag
		elif value_start == -1:
			# missing key at beginning of file.
			if not key:
				return Error.ERR_FILE_CORRUPT
			value_start = i
		i += 1

	# no termination tag for last key.
	if value_start != -1:
		return Error.ERR_FILE_CORRUPT

	_data.assign(new_data)
	return Error.OK


func encode_to_text() -> String:
	var lines: Array[String] = []
	for key in _data:
		lines.append("[%s]" % key)
		lines.append(_data[key])
		lines.append("[/]")
		lines.append("")
	if lines:
		lines.pop_back()
	return "\n".join(lines)
