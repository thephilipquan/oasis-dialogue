extends RefCounted

const _JsonVisitor := preload("res://addons/oasis_dialogue/visitor/json_visitor.gd")


static func validate_character_json(json: Dictionary) -> bool:
	for key: String in json:
		if not key.is_valid_int():
			push_warning("Expected %s to be a ints" % key)
			return false

		var branch: Dictionary = json[key]
		if not _validate_branch(branch):
			return false
	return true


static func _validate_branch(branch: Variant) -> bool:
	if not branch is Dictionary:
		push_warning("Expected %s to be a Dictionary" % branch)
		return false

	var validate := func(d: Variant) -> bool:
		return _validate_line(d)
	var prompts: Array = branch.get(_JsonVisitor.BRANCH_PROMPTS, [])
	var responses: Array = branch.get(_JsonVisitor.BRANCH_RESPONSES, [])
	return prompts.all(validate) and responses.all(validate)


static func _validate_line(line: Variant) -> bool:
	if not line is Dictionary:
		push_warning("Expected %s to be a Dictionary" % line)
		return false

	var text: Variant = line.get(_JsonVisitor.LINE_KEY, "")
	var warning := ""
	if not text is String:
		warning = "Expected '%s' to be a string in %s" % [_JsonVisitor.LINE_KEY, line]
	elif text == "":
		warning = "Expected '%s' to be non-empty in %s" % [_JsonVisitor.LINE_KEY, line]
	if warning:
		push_warning(warning)
		return false

	var conditions: Array = line.get(_JsonVisitor.LINE_CONDITIONS, [])
	var actions: Array = line.get(_JsonVisitor.LINE_ACTIONS, [])
	var validate := func(d: Variant) -> bool:
		return _validate_key_value(d)
	return conditions.all(validate) and actions.all(validate)


static func _validate_key_value(key_value: Variant) -> bool:
	if not key_value is Dictionary:
		push_warning("Expected %s to be a Dictionary" % key_value)
		return false

	var key: Variant = key_value.get(_JsonVisitor.KEY_VALUE_LEFT, "")
	var value: Variant = key_value.get(_JsonVisitor.KEY_VALUE_RIGHT, -1)
	if value is float:
		value = int(value)
	var warning := ""
	if not key is String:
		warning = "Expected '%s' to be a String in %s" % [_JsonVisitor.KEY_VALUE_LEFT, key_value]
	elif key == "":
		warning = "Expected '%s' to be non-empty in %s" % [_JsonVisitor.KEY_VALUE_LEFT, key_value]
	elif not value is int:
		warning = "Expected '%s' to be an int in %s" % [_JsonVisitor.KEY_VALUE_RIGHT, key_value]
	if warning:
		push_warning(warning)
	return warning == ""
