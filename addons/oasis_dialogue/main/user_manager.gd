extends Node

const REGISTRY_KEY := "user_manager"

const _ExportButton := preload("res://addons/oasis_dialogue/canvas/export_button.gd")
const _ProjectDialog := preload("res://addons/oasis_dialogue/project_dialog/project_dialog.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

const _USER := "user://"
const _DIR := "oasis_dialogue"
const _CACHE := "cache.cfg"
var _cache_path := _USER.path_join(_DIR).path_join(_CACHE)

var _last_export_path := ""
var _last_open_path := ""
var _dirty := false


func _ready() -> void:
	var dir := DirAccess.open(_USER)
	if not dir.dir_exists(_DIR):
		dir.make_dir(_DIR)

	if dir.file_exists(_cache_path):
		var cache := ConfigFile.new()
		cache.load(_cache_path)
		init_cache(cache)


func _exit_tree() -> void:
	if not _dirty:
		return
	save()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	if registry.has(_ExportButton.REGISTRY_KEY):
		var export_button: _ExportButton = registry.at(_ExportButton.REGISTRY_KEY)
		export_button.export_requested.connect(cache_export_path)

	if registry.has(_ProjectDialog.REGISTRY_KEY):
		var project_dialog: _ProjectDialog = registry.at(_ProjectDialog.REGISTRY_KEY)
		project_dialog.path_requested.connect(cache_open_path)


func init_cache(cache: ConfigFile) -> void:
	_last_export_path = cache.get_value("export", "last_export_path", "")
	_last_open_path = cache.get_value("open", "last_open_path", "")


func save() -> void:
	var cache := ConfigFile.new()
	cache.set_value("export", "last_export_path", _last_export_path)
	cache.set_value("open", "last_open_path", _last_open_path)
	cache.save(_cache_path)


func cache_export_path(path: String) -> void:
	if path == _last_export_path:
		return
	_last_export_path = path
	_dirty = true


func get_last_export_path() -> String:
	return _last_export_path


func cache_open_path(path: String) -> void:
	if path == _last_open_path:
		return
	_last_open_path = path
	_dirty = true


func get_last_open_path() -> String:
	return _last_open_path
