extends RefCounted


static func replace_extension(s: String, with: String) -> String:
	if s.get_extension() == with:
		return s

	var result := s.trim_suffix(".%s" % s.get_extension())
	result += ".%s" % with
	return result
