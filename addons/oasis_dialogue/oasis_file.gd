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


func get_sections() -> Array[String]:
	var keys: Array[String] = []
	keys.assign(_data.keys())
	return keys


func get_section_keys(section: String) -> Array[String]:
	if not has_section(section):
		push_warning("%s does not exist" % section)
		return []
	var inner: Dictionary = _data[section]
	var keys: Array[String] = []
	keys.assign(inner.keys())
	return keys


func has_section(section: String) -> bool:
	return section in _data


func has_section_key(section: String, key: String) -> bool:
	if not has_section(section):
		return false
	var inner: Dictionary = _data[section]
	return key in inner


func set_value(section: String, key: String, value) -> void:
	if not has_section(section):
		_data[section] = {}
	var inner: Dictionary = _data[section]
	inner[key] = value


func get_value(section: String, key: String, default = null):
	# if not has_section(section):
		# push_warning("%s does not exist" % section)
		# return
	return _data.get(section, {}).get(key, default)
	# var inner: Dictionary = _data[section]
	# return key in inner


func save(path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	file.store_string(encode_to_text())
	return Error.OK


## Parses and appends the text as formatted as a [b].oasis[/b] file.
## [br][br]
func parse(text: String) -> Error:
	if not text.strip_edges().length():
		return Error.OK

	var lines := text.split("\n")
	var i := 0

	var new_data := {}
	var inner := {}

	var section := ""
	var key := ""
	var value_start := -1
	while i < lines.size():
		var line := lines[i]
		# missing closing bracket
		if line.begins_with("[["):
			if not line.ends_with("]]"):
				return Error.ERR_FILE_CORRUPT
			var tag := line.substr(2, line.length() - 4) # -4 = [[ and ]]
			if not tag:
				return Error.ERR_FILE_CORRUPT
			if tag in _data:
				push_warning("overwriting existing section %s" % tag)
			if tag in new_data:
				push_warning("overwriting new section %s" % tag)
			if key:
				# Empty value.
				if value_start >= i - 1:
					return Error.ERR_FILE_CORRUPT
				var value = _parse_value("\n".join(lines.slice(value_start, i - 1)))
				inner[key] = value
				value_start = -1
			section = tag
			inner = {}
			new_data[section] = inner
		elif line.begins_with("["):
			if not line.ends_with("]"):
				return Error.ERR_FILE_CORRUPT
			var tag := line.substr(1, line.length() - 2) # -2 = [ and ]
			if not tag:
				return Error.ERR_FILE_CORRUPT
			if not section:
				return Error.ERR_FILE_CORRUPT
			if tag in inner:
				push_warning("overwriting section key %s: %s" % [section, tag])
			if value_start != -1:
				inner[key] = _parse_value("\n".join(lines.slice(value_start, i)))
			key = tag
			value_start = i + 1
		i += 1

	# Should always end with a key value to be stored.
	if key == "" or value_start >= i:
		return Error.ERR_FILE_CORRUPT
	inner[key] = _parse_value("\n".join(lines.slice(value_start, i)))

	_data.assign(new_data)
	return Error.OK


func _parse_value(value: String):
	if value.contains("\n"):
		return value
	if value.to_lower() == "true":
		return true
	elif value.to_lower() == "false":
		return false

	var regex := RegEx.create_from_string(r"Vector2\(([\d\.-]+),[ ]*([\d\.-]+)\)")
	var m := regex.search(value)
	if m:
		var x := m.strings[1].to_float()
		var y := m.strings[2].to_float()
		return Vector2(x, y)

	return value


func encode_to_text() -> String:
	var lines: Array[String] = []
	for section in _data:
		var inner: Dictionary = _data[section]
		lines.append("[[%s]]" % section)
		for key in inner:
			lines.append("[%s]" % key)
			lines.append("%s" % _encode_value(inner[key]))
		lines.append("")
	if lines:
		lines.pop_back()
	return "\n".join(lines)


func _encode_value(value):
	if value is Vector2:
		return "Vector2%s" % value
	return value
