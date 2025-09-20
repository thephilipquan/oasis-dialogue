extends RefCounted


static func get_next(sorted: Array[int]) -> int:
	var expected := 0
	for x in sorted:
		if x != expected:
			break
		expected += 1
	return expected
