extends RefCounted


static func get_next_int(sorted_sequence: Array[int]) -> int:
	var expected := 0
	for x in sorted_sequence:
		if x != expected:
			break
		expected += 1
	return expected

