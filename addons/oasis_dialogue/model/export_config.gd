extends RefCounted

var path := ""


func is_directory_export() -> bool:
	return not is_single_file_export()


func is_single_file_export() -> bool:
	return path.get_extension() != ""
