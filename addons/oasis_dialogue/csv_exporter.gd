extends Node

const REGISTRY_KEY := "csv_exporter"

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Canvas := preload("res://addons/oasis_dialogue/canvas/canvas.gd")
const _CsvFile := preload("res://addons/oasis_dialogue/io/csv_file.gd")
const _CsvVisitor := preload("res://addons/oasis_dialogue/visitor/csv_visitor.gd")
const _LanguageServer := preload("res://addons/oasis_dialogue/canvas/language_server.gd")
const _OasisFile := preload("res://addons/oasis_dialogue/oasis_file.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _Save := preload("res://addons/oasis_dialogue/save.gd")

signal exported(path: String)


var _csv_file_factory := Callable()
var _parse := Callable()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var project_manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	project_manager.exporting.connect(export)

	var language_server: _LanguageServer = registry.at(_LanguageServer.REGISTRY_KEY)
	init_parse(language_server.parse_branch_text)
	init_csv_file_factory(registry.at(_Canvas.CSV_FILE_FACTORY_REGISTRY_KEY))


func init_csv_file_factory(callback: Callable) -> void:
	_csv_file_factory = callback


func init_parse(callback: Callable) -> void:
	_parse = callback


func export(path: String, characters: Array[_OasisFile]) -> void:
	var csv: _CsvFile = _csv_file_factory.call()
	var csv_visitor := _CsvVisitor.new()
	for character in characters:
		var character_name: String = character.get_value(
				_Save.Character.DATA,
				 _Save.Character.Data.DISPLAY_NAME,
				 "",
		)
		assert(character_name)

		for key in character.get_sections():
			if not character.section_is_branch(key):
				continue

			var id := character.section_to_branch_id(key)
			var value: String = character.get_value(key, _Save.Character.Branch.VALUE, "")
			if not value:
				push_warning("branch %d is empty. skipping" % id)
				continue

			var ast: _AST.AST = _parse.call(id, value)
			var stage := csv.stage(character_name, id)
			csv_visitor.set_stage(stage)
			ast.accept(csv_visitor)
			csv.update(stage)
			csv_visitor.finish()

	if csv.save(path) != Error.OK:
		push_warning("something went wrong with saving %s" % path)
		return
	exported.emit(path)
