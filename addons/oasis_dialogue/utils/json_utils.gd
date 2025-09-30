extends RefCounted

static func is_int(value) -> bool:
	if value is String:
		return value.is_valid_int()
	return value is int or value is float


static func parse_int(value) -> int:
	if value is String:
		return value.to_int()
	return int(value)

