extends RefCounted

var path := ""
var is_directory_export := false
var default_annotation := ""
var language := ""


func copy_from(other: RefCounted) -> void:
	path = other.path
	is_directory_export = other.is_directory_export
	default_annotation = other.default_annotation
	language = other.language


func save_to_config(config: ConfigFile, header: String) -> void:
	config.set_value(header, "path", path)
	config.set_value(header, "default_annotation", default_annotation)
	config.set_value(header, "language", language)

	var type = "directory" if is_directory_export else "single"
	config.set_value(header, "type", type)


func load_from_config(config: ConfigFile, header: String) -> void:
	path = config.get_value(header, "path", "")
	default_annotation = config.get_value(header, "default_annotation", "")
	language = config.get_value(header, "language", "")

	var type: String = config.get_value(header, "type", "")
	is_directory_export = type == "directory"
