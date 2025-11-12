extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ExportConfig := preload("res://addons/oasis_dialogue/model/export_config.gd")
const JsonExporter := preload("res://addons/oasis_dialogue/canvas/json_exporter.gd")
const JsonFile := preload("res://addons/oasis_dialogue/io/json_file.gd")
const Save := preload("res://addons/oasis_dialogue/save.gd")
const OasisFile := preload("res://addons/oasis_dialogue/io/oasis_file.gd")

const BASEDIR := "res://"
var TESTDIR := BASEDIR.path_join("test_oasis_manager")


func before_all() -> void:
	var dir := DirAccess.open(BASEDIR)
	dir.make_dir(TESTDIR)
	after_each()


func after_each() -> void:
	var dir := DirAccess.open(TESTDIR)
	for file in dir.get_files():
		dir.remove(file)


func after_all() -> void:
	var dir := DirAccess.open(BASEDIR)
	dir.remove(TESTDIR)


func test_get_reachable_branches_from_directory() -> void:
	var config := ExportConfig.new()
	config.path = TESTDIR
	_create_json_file_for_tests(config, "Frank")

	var sut := OasisManager.new()
	sut._path = config.path

	var iterator := sut.get_reachable_branches("Frank", 0)
	assert_not_null(iterator)


func test_get_reachable_branches_from_characters_file() -> void:
	var config := ExportConfig.new()
	config.path = TESTDIR.path_join("abc.json")
	_create_json_file_for_tests(config, "Frank")

	var sut := OasisManager.new()
	sut._path = config.path

	var iterator := sut.get_reachable_branches("Frank", 0)
	assert_not_null(iterator)


func test_get_reachable_branches_from_character_file() -> void:
	var config := ExportConfig.new()
	config.path = TESTDIR
	_create_json_file_for_tests(config, "Frank")

	var sut := OasisManager.new()
	sut._path = config.path.path_join("frank.json")

	var iterator := sut.get_reachable_branches("Frank", 0)
	assert_not_null(iterator)


func test_directory_and_character_subpath_not_found_returns_null() -> void:
	var config := ExportConfig.new()
	config.path = TESTDIR
	_create_json_file_for_tests(config, "Frank")

	var sut := OasisManager.new()
	sut._path = config.path

	var iterator := sut.get_reachable_branches("Tom", 0)
	assert_null(iterator)


func test_characters_file_and_character_not_found_returns_null() -> void:
	var config := ExportConfig.new()
	config.path = TESTDIR.path_join("abc.json")
	_create_json_file_for_tests(config, "Frank")

	var sut := OasisManager.new()
	sut._path = config.path

	var iterator := sut.get_reachable_branches("Tom", 0)
	assert_null(iterator)


func test_character_file_and_wrong_character_name_returns_null() -> void:
	var config := ExportConfig.new()
	config.path = TESTDIR
	_create_json_file_for_tests(config, "Frank")

	var sut := OasisManager.new()
	sut._path = config.path.path_join("frank.json")

	var iterator := sut.get_reachable_branches("Tom", 0)
	assert_null(iterator)


func test_character_file_and_branch_id_not_found_returns_null() -> void:
	var config := ExportConfig.new()
	config.path = TESTDIR
	_create_json_file_for_tests(config, "Frank")

	var sut := OasisManager.new()
	sut._path = config.path.path_join("frank.json")

	var iterator := sut.get_reachable_branches("frank", 5)
	assert_null(iterator)


func _create_json_file_for_tests(config: ExportConfig, character: String) -> void:
	var json_exporter: JsonExporter = add_child_autofree(JsonExporter.new())
	json_exporter.init_json_file_factory(func() -> JsonFile: return JsonFile.new())
	json_exporter.init_parse(
			func(id: int, text: String) -> AST.AST:
				var ast: AST.AST = null
				match id:
					0:
						ast = AST.Branch.new(id, [
							AST.Prompt.new(-1, [
									AST.StringLiteral.new(text),
									AST.Action.new("branch", AST.NumberLiteral.new(2))
							]),
						])
					1:
						ast = AST.Branch.new(id, [
							AST.Prompt.new(-1, [
									AST.StringLiteral.new(text),
									AST.Action.new("branch", AST.NumberLiteral.new(3))
							]),
						])
					2:
						ast = AST.Branch.new(id, [
							AST.Prompt.new(-1, [
									AST.StringLiteral.new(text),
							]),
						])
					3:
						ast = AST.Branch.new(id, [
							AST.Prompt.new(-1, [
									AST.StringLiteral.new(text),
							]),
						])
				return ast
	)
	var fred := OasisFile.new()
	fred.set_value(
			Save.Character.DATA,
			Save.Character.Data.DISPLAY_NAME,
			character,
	)
	fred.set_value("0", Save.Character.Branch.VALUE, "a")
	fred.set_value("1", Save.Character.Branch.VALUE, "b")
	fred.set_value("2", Save.Character.Branch.VALUE, "c")
	fred.set_value("3", Save.Character.Branch.VALUE, "d")
	json_exporter.export(config, [fred])
