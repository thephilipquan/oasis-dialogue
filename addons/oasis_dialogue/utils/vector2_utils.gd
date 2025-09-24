extends RefCounted


static func from_json(json: Dictionary) -> Vector2:
	return Vector2(
		json.get("x", 0),
		json.get("y", 0),
	)
