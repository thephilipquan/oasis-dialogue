extends RefCounted

const _Global := preload("res://addons/oasis_dialogue/global.gd")
const _JsonUtils := preload("res://addons/oasis_dialogue/utils/json_utils.gd")

const SETTINGS := ".oasis"
const EXTENSION := "oasis"

signal file_loaded(data: Dictionary)
signal project_loaded(data: Dictionary)
signal saving_file(data: Dictionary)
signal saving_project(data: Dictionary)

var _directory := ""
var _active := ""
var _display_to_filename: Dictionary[String, String] = {}


func get_settings_path() -> String:
	return _directory.path_join(SETTINGS)


func get_subfile_path(filename: String) -> String:
	return _directory.path_join(filename + "." + EXTENSION)


func can_rename_active_to(display_name: String) -> bool:
	var filename := _format_filename(display_name)
	if filename == _display_to_filename[_active]:
		return true

	var path := get_subfile_path(filename)
	return not FileAccess.file_exists(path)


func subfile_exists(display_name: String) -> bool:
	var filename := _format_filename(display_name)
	var path := get_subfile_path(filename)
	return FileAccess.file_exists(path)


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
	_active = ""
	_display_to_filename.clear()

	var settings := FileAccess.open(get_settings_path(), FileAccess.READ)
	var content := settings.get_as_text()
	settings.close()

	var data := {}
	if content:
		data.assign(JSON.parse_string(content))

	var characters: Array[String] = []
	for f in dir.get_files():
		if f == SETTINGS or f.get_extension() != EXTENSION:
			continue

		var file := FileAccess.open(_directory.path_join(f), FileAccess.READ)
		var contents := file.get_as_text()
		file.close()

		var filename := f.get_slice(".", 0)
		var display_name = filename
		if contents:
			var json := JSON.parse_string(contents)
			display_name = _JsonUtils.safe_get(
					json,
					_Global.FILE_DISPLAY_NAME,
					display_name
			)

		_display_to_filename[display_name] = filename
		characters.push_back(display_name)

	if characters:
		data[_Global.LOAD_PROJECT_CHARACTERS] = characters

	project_loaded.emit(data)

	if _JsonUtils.safe_get(data, _Global.PROJECT_ACTIVE, "") != "":
		load_subfile(data[_Global.PROJECT_ACTIVE])


func save_project() -> void:
	if not _directory:
		return
	var data := {}
	saving_project.emit(data)
	data[_Global.PROJECT_ACTIVE] = _active
	var settings := FileAccess.open(get_settings_path(), FileAccess.WRITE)
	settings.store_string(JSON.stringify(data, "\t"))


func add_subfile(display_name: String) -> void:
	if not _directory:
		return

	var filename := _format_filename(display_name)
	_display_to_filename[display_name] = filename

	var dir := DirAccess.open(_directory)
	var path := get_subfile_path(filename)
	if dir.file_exists(path):
		return

	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		print("ERROR: ", FileAccess.get_open_error())


func load_subfile(display_name: String) -> void:
	if not (
		_directory
		and display_name != _active
		and display_name in _display_to_filename
	):
		return

	var filename := _display_to_filename[display_name]

	var dir := DirAccess.open(_directory)
	var path := get_subfile_path(filename)
	if not dir.file_exists(path):
		return

	if _active:
		save_active_subfile()

	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var data := {}
	if content:
		data.assign(JSON.parse_string(content))

	data[_Global.LOAD_FILE_NAME] = display_name

	_active = display_name
	file_loaded.emit(data)


func remove_active_subfile() -> void:
	if not _directory or not _active:
		return

	var filename := _display_to_filename[_active]
	var path := get_subfile_path(filename)
	var dir := DirAccess.open(_directory)
	if not dir.file_exists(path):
		return

	dir.remove(path)
	_active = ""


func rename_active_subfile(to_display_name: String) -> void:
	if (
		not _directory
		or not _active
		or _active == to_display_name
	):
		return

	var filename := _display_to_filename[_active]
	var to_filename := _format_filename(to_display_name)

	var to_path := get_subfile_path(to_filename)
	var dir := DirAccess.open(_directory)
	if filename != to_filename and dir.file_exists(to_path):
		return

	var old_active = _active
	_active = to_display_name
	_display_to_filename[to_display_name] = to_filename
	save_active_subfile()

	dir.remove(get_subfile_path(_display_to_filename[old_active]))
	_display_to_filename.erase(old_active)


func save_active_subfile() -> void:
	var data := {}
	saving_file.emit(data)

	data[_Global.FILE_DISPLAY_NAME] = _active

	var file := FileAccess.open(get_subfile_path(_active), FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))


func _format_filename(value: String) -> String:
	return value.to_lower()
