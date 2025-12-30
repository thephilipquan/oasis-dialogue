extends RefCounted


static func get_next_int(unordered: Array[int]) -> int:
	var sorted := unordered.duplicate()
	sorted.sort()
	var expected := 0
	for x in sorted:
		if x != expected:
			break
		expected += 1
	return expected

