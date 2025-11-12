@tool
extends Node

const REGISTRY_KEY := "json_exporter"

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _CsvFile := preload("res://addons/oasis_dialogue/io/csv_file.gd")
const _ExportConfig := preload("res://addons/oasis_dialogue/model/export_config.gd")
const _JsonFile := preload("res://addons/oasis_dialogue/io/json_file.gd")
const _JsonVisitor := preload("res://addons/oasis_dialogue/visitor/json_visitor.gd")
const _LanguageServer := preload("res://addons/oasis_dialogue/canvas/language_server.gd")
const _Save := preload("res://addons/oasis_dialogue/save.gd")
const _OasisFile := preload("res://addons/oasis_dialogue/io/oasis_file.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

signal exported(path: String)

var _parse := Callable()
var _json_file_factory := Callable()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var project_manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	project_manager.exporting.connect(export)

	var language_server: _LanguageServer = registry.at(_LanguageServer.REGISTRY_KEY)
	init_parse(language_server.parse_branch_text)

	init_json_file_factory(func() -> _JsonFile: return _JsonFile.new())


func init_parse(callback: Callable) -> void:
	_parse = callback


func init_json_file_factory(callback: Callable) -> void:
	_json_file_factory = callback


func export(config: _ExportConfig, files: Array[_OasisFile]) -> void:
	var json_file: _JsonFile = _json_file_factory.call()
	var characters: Dictionary[String, Dictionary] = {}

	for file in files:
		var character_name: String = file.get_value(
			_Save.Character.DATA,
			_Save.Character.Data.DISPLAY_NAME,
			"",
		)
		assert(character_name)
		character_name = character_name.to_lower()

		var character: Dictionary[int, Variant] = {}
		var json_visitor := _JsonVisitor.new(
				character,
				character_name,
				_CsvFile.create_prompt_key,
				_CsvFile.create_response_key,
		)
		for key in file.get_sections():
			if not _OasisFile.section_is_branch(key):
				continue

			var id := _OasisFile.section_to_branch_id(key)
			var value: String = file.get_value(key, _Save.Character.Branch.VALUE, "")
			if not value:
				push_warning("branch %d is empty. skipping" % id)
				continue
			var ast: _AST.AST = _parse.call(id, value)
			ast.accept(json_visitor)
			json_visitor.finish()

		if config.is_directory_export():
			json_file.save(config.path.path_join(character_name), character)
		else:
			characters[character_name] = character

	if config.is_single_file_export():
		json_file.save(config.path, characters)

	exported.emit(config.path)
