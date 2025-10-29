@tool
extends Node

const REGISTRY_KEY := "project_manager"
const EXTENSION := "oasis"

const _AddCharacterButton := preload("res://addons/oasis_dialogue/canvas/add_character_button.gd")
const _CharacterTree := preload("res://addons/oasis_dialogue/canvas/character_tree.gd")
const _ExportButton := preload("res://addons/oasis_dialogue/canvas/export_button.gd")
const _Graph := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _OasisFile := preload("res://addons/oasis_dialogue/oasis_file.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _RemoveCharacterButton := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")
const _RenameCharacterHandler := preload("res://addons/oasis_dialogue/canvas/rename_character_handler.gd")
const _Save := preload("res://addons/oasis_dialogue/save.gd")

const _SETTINGS_DIR := ".oasis/"
const _USER_SETTINGS := "user"
const _ACTIONS := "actions"
const _CONDITIONS := "conditions"

signal saving_character(file: _OasisFile)
signal character_loaded(file: _OasisFile)
signal character_saved(name: String)

signal saving_character_config(file: ConfigFile)
signal character_config_loaded(file: ConfigFile)

signal saving_actions(file: _OasisFile)
signal actions_loaded(file: _OasisFile)

signal saving_conditions(file: _OasisFile)
signal conditions_loaded(file: _OasisFile)

signal saving_settings(file: ConfigFile)
signal settings_loaded(file: ConfigFile)

signal project_loaded
signal exporting(path: String, characters: Array[_OasisFile])

var _directory := ""
var _active := ""
var _is_dirty := false
var _dirty_characters: Array[String] = []


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var add_character_button: _AddCharacterButton = registry.at(_AddCharacterButton.REGISTRY_KEY)
	add_character_button.character_added.connect(add_character)

	var remove_character_button: _RemoveCharacterButton = registry.at(_RemoveCharacterButton.REGISTRY_KEY)
	remove_character_button.character_removed.connect(remove_active_character)

	var export_button: _ExportButton = registry.at(_ExportButton.REGISTRY_KEY)
	export_button.export_requested.connect(export)

	var tree: _CharacterTree = registry.at(_CharacterTree.REGISTRY_KEY)
	tree.character_selected.connect(load_character)

	var rename_character_handler: _RenameCharacterHandler = registry.at(_RenameCharacterHandler.REGISTRY_KEY)
	rename_character_handler.character_renamed.connect(rename_active_character)

	var graph: _Graph = registry.at(_Graph.REGISTRY_KEY)
	graph.dirtied.connect(mark_active_character_dirty)


func can_rename_active_to(character: String) -> bool:
	var path := _character_to_path(character)
	var active_path := _character_to_path(_active)
	if path == active_path:
		return true

	return (
			not FileAccess.file_exists(path)
			and character != "conditions"
			and character != "actions"
	)


func get_active_character() -> String:
	return _active


func character_exists(character: String) -> bool:
	if character == "conditions" or character == "actions":
		return true
	var path := _character_to_path(character)
	return FileAccess.file_exists(path)


func mark_active_character_dirty() -> void:
	_is_dirty = true


func active_is_dirty() -> bool:
	return _is_dirty


func quit() -> void:
	var dir := DirAccess.open(_directory.path_join(_SETTINGS_DIR))
	for character in _dirty_characters:
		var temp_path := _character_to_temp_path(character)
		dir.remove(temp_path)


func open_project(path: String) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		push_warning("trying to load a project at a path that does not exist")
		return

	_directory = path
	_active = ""
	_is_dirty = false

	if not dir.dir_exists(_SETTINGS_DIR):
		dir.make_dir(_SETTINGS_DIR)

	var characters: Array[String] = []
	for f in dir.get_files():
		if not f.get_extension() == EXTENSION:
			continue

		var filename := f.get_basename()
		var file := _OasisFile.new()
		file.load(_directory.path_join(f))

		if filename == _ACTIONS:
			actions_loaded.emit(file)
		elif filename == _CONDITIONS:
			conditions_loaded.emit(file)
		else:
			var character: String = file.get_value(
					_Save.Character.DATA,
					_Save.Character.Data.DISPLAY_NAME,
					filename
			)
			characters.push_back(character)
			var temp_path := _character_to_temp_path(character)
			if dir.file_exists(temp_path):
				_dirty_characters.push_back(character)

	var settings := ConfigFile.new()
	if dir.file_exists(_get_user_settings_path()):
		var file := FileAccess.open(_get_user_settings_path(), FileAccess.READ)
		settings.parse(file.get_as_text())
		file.close()
	settings.set_value(_Save.Project.CHARACTERS, _Save.DUMMY, characters)
	settings_loaded.emit(settings)
	project_loaded.emit()


func save_project() -> void:
	assert(_directory)

	if _is_dirty:
		save_active_character()
	if _active:
		save_active_character_config()
	for character in _dirty_characters:
		replace_save_with_temp(character)

	var settings := ConfigFile.new()
	saving_settings.emit(settings)
	settings.set_value(
			_Save.Project.SESSION,
			_Save.Project.Session.ACTIVE,
			_active,
	)
	settings.save(_get_user_settings_path())

	var actions := _OasisFile.new()
	saving_actions.emit(actions)
	actions.save(_get_actions_path())

	var conditions := _OasisFile.new()
	saving_conditions.emit(conditions)
	conditions.save(_get_conditions_path())


func export(path: String) -> void:
	if _is_dirty:
		save_active_character()

	var characters: Array[_OasisFile] = []
	var dir := DirAccess.open(_directory)
	if not dir:
		push_warning("todo: opening dir at %s failed" % _directory)
		return
	for filename in dir.get_files():
		var basename := filename.get_basename()
		if (
			filename.get_extension() != EXTENSION
			or basename == _ACTIONS
			or basename == _CONDITIONS
		):
			continue

		var filepath := _directory.path_join(filename)
		var file := _OasisFile.new()
		if file.load(filepath) != Error.OK:
			push_warning("todo: couldn't open %s. exiting" % filepath)
			return
		characters.push_back(file)

	exporting.emit(path, characters)


func add_character(character: String) -> void:
	assert(_directory)

	var path := _character_to_path(character)
	if FileAccess.file_exists(path):
		return

	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_warning("todo: error adding character: %s" % character)


func load_character(character: String) -> void:
	assert(_directory)
	if character == _active:
		return

	var path := _character_to_path(character)
	if not FileAccess.file_exists(path):
		push_warning("todo: active: %s doesn't exist" % character)
		return

	if _is_dirty:
		save_active_character_temp()
		_dirty_characters.push_back(_active)

	# When loading the first character.
	if _active:
		save_active_character_config()

	_active = character
	_is_dirty = _active in _dirty_characters

	if _is_dirty:
		var temp_path := _character_to_temp_path(_active)
		if FileAccess.file_exists(temp_path):
			path = temp_path
		else:
			push_warning("%s marked as dirty but no temp file found." % _active)

	var file := _OasisFile.new()
	file.load(path)
	character_loaded.emit(file)

	var config := ConfigFile.new()
	config.load(_character_to_config_path(character))
	character_config_loaded.emit(config)


func remove_active_character() -> void:
	assert(_directory)
	assert(_active)

	var dir := DirAccess.open(_directory)
	var path := _character_to_path(_active)
	if dir.file_exists(path):
		dir.remove(path)
	else:
		push_warning("remove active character at %s not found")

	var config_path := _character_to_config_path(_active)
	if dir.file_exists(config_path):
		dir.remove(config_path)

	var temp_path := _character_to_temp_path(_active)
	if dir.file_exists(temp_path):
		dir.remove(temp_path)

	_dirty_characters.erase(_active)
	_active = ""
	_is_dirty = false


func rename_active_character(to_name: String) -> void:
	assert(_directory)
	assert(_active)
	if _active == to_name:
		return

	var filename := _character_to_file(_active)
	var to_filename := _character_to_file(to_name)

	var to_path := _character_to_path(to_filename)
	var dir := DirAccess.open(_directory)
	if filename != to_filename and dir.file_exists(to_path):
		push_warning("% already exists. Call character_exists to check if the character exists" % to_name)
		return

	var old_active := _active
	_active = to_name
	save_active_character()
	save_active_character_config()

	var old_active_path := _character_to_path(old_active)
	if dir.file_exists(old_active_path):
		dir.remove(old_active_path)

	var old_active_config_path := _character_to_config_path(old_active)
	if dir.file_exists(old_active_config_path):
		dir.remove(old_active_config_path)

	var old_active_temp_path := _character_to_temp_path(old_active)
	if dir.file_exists(old_active_temp_path):
		dir.remove(old_active_temp_path)


func save_active_character() -> void:
	assert(_active)
	_save_character(_active, _character_to_path(_active))

	var dir := DirAccess.open(_directory)
	var temp_path := _character_to_temp_path(_active)
	if dir.file_exists(temp_path):
		dir.remove(temp_path)

	_is_dirty = false
	_erase_dirty_character(_active)
	character_saved.emit(_active)


func save_active_character_temp() -> void:
	assert(_active)
	_save_character(_active, _character_to_temp_path(_active))


func save_active_character_config() -> void:
	assert(_active)
	var config := ConfigFile.new()
	saving_character_config.emit(config)
	config.save(_character_to_config_path(_active))


func replace_save_with_temp(character: String) -> void:
	var temp_path := _character_to_temp_path(character)
	var path := _character_to_path(character)

	var file := _OasisFile.new()
	var status := file.load(temp_path)
	if status != Error.OK:
		push_warning("todo: failed to load temp file at %s" % temp_path)
		return
	status = file.save(path)
	if status != Error.OK:
		push_warning("todo: failed to save file at %s" % path)
		return

	DirAccess.open(_directory).remove(temp_path)
	_erase_dirty_character(character)
	character_saved.emit(character)


func _format_character_filename(character: String) -> String:
	return character.to_lower()


func _character_to_file(character: String) -> String:
	var filename := "%s.%s" % [_format_character_filename(character), EXTENSION]
	return filename


func _character_to_path(character: String) -> String:
	return _directory.path_join(_character_to_file(character))


func _character_to_temp_path(character: String) -> String:
	return (
			_directory
			.path_join(_SETTINGS_DIR)
			.path_join("temp_%s" % _character_to_file(character))
	)


func _character_to_config_path(character: String) -> String:
	return (
			_directory
			.path_join(_SETTINGS_DIR)
			.path_join("%s.cfg" % _format_character_filename(character))
	)


func _get_actions_path() -> String:
	return _directory.path_join("%s.%s" % [_ACTIONS, EXTENSION])


func _get_conditions_path() -> String:
	return _directory.path_join("%s.%s" % [_CONDITIONS, EXTENSION])


func _get_user_settings_path() -> String:
	return (
			_directory
			.path_join(_SETTINGS_DIR)
			.path_join("%s.cfg" % _USER_SETTINGS)
	)


func _erase_dirty_character(character: String) -> void:
	_dirty_characters.erase(character)


func _save_character(character: String, path: String) -> void:
	var file := _OasisFile.new()
	saving_character.emit(file)
	file.set_value(
			_Save.Character.DATA,
			_Save.Character.Data.DISPLAY_NAME,
			character,
	)
	file.save(path)
