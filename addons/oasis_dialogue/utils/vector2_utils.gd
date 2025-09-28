extends RefCounted


static func from_json(json: Dictionary) -> Vector2:
	var x = json.get("x", 0)
	var y = json.get("y", 0)
	if not (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT):
		x = 0
	if not (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT):
		y = 0
	return Vector2(x, y)


static func to_json(v: Vector2) -> Dictionary:
	var vi := Vector2i(v.round())
	return {
		"x": vi.x,
		"y": vi.y,
	}
