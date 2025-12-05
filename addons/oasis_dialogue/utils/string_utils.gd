extends RefCounted


static func replace_extension(s: String, with: String) -> String:
	if s.get_extension() == with:
		return s

	var result := s.trim_suffix(".%s" % s.get_extension())
	result += ".%s" % with
	return result


static func is_alpha(s: String) -> bool:
	s = s.to_lower()
	var result := true
	for l in s:
		if l < "a" or l > "z":
			result = false
			break
	return result
