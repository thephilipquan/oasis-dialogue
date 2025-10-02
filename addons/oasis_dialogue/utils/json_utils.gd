extends RefCounted


static func is_int(value) -> bool:
	if value is String:
		return value.is_valid_int()
	return value is int or value is float


static func parse_int(value) -> int:
	if value is String:
		return value.to_int()
	return int(value)


static func safe_get_int(json: Dictionary, key: String, default: int) -> int:
	var value := json.get(key, default)
	if is_int(value):
		return parse_int(value)
	return default


static func get_vector2(json: Dictionary, key: String, default: Vector2) -> Vector2:
	var type := json.get(key, {})

	if not type is Dictionary:
		return default
	var v: Dictionary = type

	var x := v.get("x", default.x)
	if is_int(x):
		x = parse_int(x)
	else:
		x = default.x

	var y := v.get("y", default.y)
	if is_int(y):
		y = parse_int(y)
	else:
		y = default.y

	return Vector2(x, y)


static func vector2_to_json(v: Vector2) -> Dictionary:
	var vi := Vector2i(v.round())
	return {
		"x": vi.x,
		"y": vi.y,
	}


static func safe_get(json: Dictionary, key: String, default):
	var value := json.get(key, default)
	if typeof(value) == typeof(default):
		return value
	return default


static func is_typeof(json: Dictionary, key: String, type: Variant.Type) -> bool:
	if not key in json:
		return false
	return typeof(json[key]) == type
