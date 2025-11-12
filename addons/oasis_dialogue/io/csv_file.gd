extends RefCounted

const _StringUtils := preload("res://addons/oasis_dialogue/utils/string_utils.gd")

signal saved(path: String)

var _headers: Array[String] = []
var _data: Dictionary[String, String] = {}


static func create_prompt_key(character: String, branch: int, index: int) -> String:
	return "%s_%dp%d" % [character.to_lower(), branch, index]


static func create_response_key(character: String, branch: int, index: int) -> String:
	return "%s_%dr%d" % [character.to_lower(), branch, index]


func set_headers(...headers: Array) -> void:
	_headers.clear()
	var to_remove: Array[int] = []
	for i in headers.size():
		if not headers[i] is String:
			push_warning("Tried to add non-string header (%s)" % headers[i])
			to_remove.push_back(i)
	for i in to_remove:
		headers.pop_at(i)
	_headers.assign(headers)


func get_headers() -> Array[String]:
	return _headers


func has_character(character: String) -> bool:
	for key in _data:
		if key.begins_with(character):
			return true
	return false


func get_character_count() -> int:
	var seen := {}
	for key in _data:
		var character := key.get_slice("_", 0)
		if not character in seen:
			seen[character] = true
	return seen.size()


func get_prompt_count(character: String, branch: int) -> int:
	var key := _format_prompts_key(character, branch)
	return _get_partial_key_count(key)


func get_prompt(character: String, branch: int, prompt_index: int, column_index := 0) -> String:
	assert(branch > -1)
	assert(prompt_index > -1)
	assert(column_index > -1)
	var key := create_prompt_key(character, branch, prompt_index)
	return _get_value_slice(key, column_index)


func get_prompt_translation_count(character: String, branch: int, prompt_index: int) -> int:
	var key := create_prompt_key(character, branch, prompt_index)
	return _get_value_column_count(key)


func get_response_count(character: String, branch: int) -> int:
	var key := _format_responses_key(character, branch)
	return _get_partial_key_count(key)


func get_response(character: String, branch: int, response_index: int, column_index := 0) -> String:
	assert(branch > -1)
	assert(response_index > -1)
	assert(column_index > -1)
	var key := create_response_key(character, branch, response_index)
	return _get_value_slice(key, column_index)


func get_response_translation_count(character: String, branch: int, response_index: int) -> int:
	var key := create_response_key(character, branch, response_index)
	return _get_value_column_count(key)


func stage(character: String, branch: int, column := 0) -> Stage:
	return Stage.new(character, branch, column)


func update(staged: Stage) -> void:
	var old_branch_keys := _get_partial_matches(
			_format_branch_key(staged.character, staged.branch)
	)
	for key in old_branch_keys:
		_data.erase(key)

	var prompts := staged.get_prompts()
	for i in prompts.size():
		var key := create_prompt_key(staged.character, staged.branch, i)
		_data[key] = prompts[i]

	var responses := staged.get_responses()
	for i in responses.size():
		var key := create_response_key(staged.character, staged.branch, i)
		_data[key] = responses[i]


func save(path: String) -> Error:
	path = _format_path(path)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	var contents := encode_to_string()
	file.store_string(contents)
	file.close()
	saved.emit(path)
	return Error.OK


func load(path: String) -> Error:
	path = _format_path(path)
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return FileAccess.get_open_error()
	var contents := file.get_as_text()
	file.close()
	parse(contents)
	return Error.OK


func encode_to_string() -> String:
	var text: Array[String] = []
	text.push_back(",".join(_headers))
	for key in _data:
		text.push_back("%s,%s" % [key, _data[key]])
	return "\n".join(text)


func parse(text: String) -> void:
	var lines := text.split("\n")
	_headers.assign(lines[0].split(","))
	for i in range(1, lines.size()):
		var split := lines[i].split(",")
		var key := split[0]
		var value := split.slice(1)
		_data[key] = ",".join(value)


func _format_branch_key(character: String, branch: int) -> String:
	return "%s_%d" % [character, branch]


func _format_prompts_key(character: String, branch: int) -> String:
	return "%s_%dp" % [character, branch]


func _format_responses_key(character: String, branch: int) -> String:
	return "%s_%dr" % [character, branch]


func _get_partial_matches(partial_key: String) -> Dictionary[String, String]:
	var matches: Dictionary[String, String] = {}
	for key in _data:
		if key.begins_with(partial_key):
			matches[key] = _data[key]
	return matches


func _get_partial_key_count(partial_key: String) -> int:
	var count := 0
	for key in _data:
		if key.begins_with(partial_key):
			count += 1
	return count


func _get_value_slice(key: String, slice: int) -> String:
	var value: String = _data.get(key, "")

	var column_count := value.count(",") + 1
	if slice >= column_count:
		return ""

	return value.get_slice(",", slice)


func _get_value_column_count(key: String) -> int:
	var value: String = _data.get(key, "")
	var count := value.count(",") + 1
	return count


func _format_path(path: String) -> String:
	return _StringUtils.replace_extension(path, "csv")


class Stage:
	extends RefCounted

	var character := ""
	var branch := -1
	var column_index := -1

	var _prompts: Array[String] = []
	var _responses: Array[String] = []


	@warning_ignore("shadowed_variable")
	func _init(character: String, branch: int, column_index: int) -> void:
		self.character = character
		self.branch = branch
		self.column_index = column_index


	func get_prompts() -> Array[String]:
		return _prompts


	func add_prompt(value: String)-> void:
		_prompts.push_back(value)


	func get_responses() -> Array[String]:
		return _responses


	func add_response(value: String) -> void:
		_responses.push_back(value)
