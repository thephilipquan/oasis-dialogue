extends RefCounted

const _Global := preload("res://addons/oasis_dialogue/global.gd")

const SETTINGS := ".oasis"
const EXTENSION := "oasis"

signal file_loaded(data: Dictionary)
signal project_loaded(data: Dictionary)
signal saving_file(data: Dictionary)
signal saving_project(data: Dictionary)

var _directory := ""
var _active := ""


func get_settings_path() -> String:
	return _directory.path_join(SETTINGS)


func get_subfile_path(filename: String) -> String:
	filename = _format_param(filename)
	return _directory.path_join(filename + "." + EXTENSION)


func new_project(path: String) -> void:
	_directory = path
	var file := FileAccess.open(get_settings_path(), FileAccess.WRITE)
	if not file:
		print("ERROR: ", FileAccess.get_open_error())
		return


func load_project(path: String) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
	if not dir.file_exists(path.path_join(SETTINGS)):
		return
	_directory = path

	var settings := FileAccess.open(get_settings_path(), FileAccess.READ)
	var content := settings.get_as_text()
	settings.close()

	var data := {}
	if content:
		data.assign(JSON.parse_string(content))

	var characters: Array[String] = []
	for file in dir.get_files():
		var name := file.get_slice(".", 0)
		if name:
			characters.push_back(name)
	if characters:
		data[_Global.LOAD_PROJECT_CHARACTERS] = characters

	project_loaded.emit(data)

	if (
		_Global.PROJECT_ACTIVE in data
		and data[_Global.PROJECT_ACTIVE] != ""
	):
		load_subfile(data[_Global.PROJECT_ACTIVE])


func save_project() -> void:
	if not _directory:
		return
	var data := {}
	saving_project.emit(data)

	var settings := FileAccess.open(get_settings_path(), FileAccess.WRITE)
	settings.store_string(JSON.stringify(data))


func add_subfile(filename: String) -> void:
	filename = _format_param(filename)
	if not _directory:
		return
	var dir := DirAccess.open(_directory)
	var path := get_subfile_path(filename)
	if dir.file_exists(path):
		return

	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		print("ERROR: ", FileAccess.get_open_error())


func load_subfile(filename: String) -> void:
	filename = _format_param(filename)
	if not _directory or filename == _active:
		return

	var dir := DirAccess.open(_directory)
	if not dir.file_exists(get_subfile_path(filename)):
		return

	if _active:
		_save_active()

	var file := FileAccess.open(get_subfile_path(filename), FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var data := {}
	if content:
		data.assign(JSON.parse_string(content))

	_active = filename
	file_loaded.emit(data)


func remove_active_subfile() -> void:
	if not _directory or not _active:
		return

	var path := get_subfile_path(_active)
	var dir := DirAccess.open(_directory)
	if not dir.file_exists(path):
		return

	dir.remove(path)
	_active = ""


func rename_active_subfile(to_name: String) -> void:
	to_name = _format_param(to_name)
	if not _directory or not _active:
		return

	var to_path := get_subfile_path(to_name)
	var dir := DirAccess.open(_directory)
	if dir.file_exists(to_path):
		return

	var data := {}
	saving_file.emit(data)

	var file := FileAccess.open(to_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

	dir.remove(get_subfile_path(_active))
	_active = to_name


func _save_active() -> void:
	var data := {}
	saving_file.emit(data)
	var file := FileAccess.open(get_subfile_path(_active), FileAccess.WRITE)
	file.store_string(JSON.stringify(data))


func _format_param(value: String) -> String:
	return value.to_lower()
