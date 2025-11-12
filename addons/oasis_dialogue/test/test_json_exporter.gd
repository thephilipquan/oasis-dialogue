extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const ExportConfig := preload("res://addons/oasis_dialogue/model/export_config.gd")
const JsonExporter := preload("res://addons/oasis_dialogue/canvas/json_exporter.gd")
const JsonFile := preload("res://addons/oasis_dialogue/io/json_file.gd")
const OasisFile := preload("res://addons/oasis_dialogue/io/oasis_file.gd")
const Save := preload("res://addons/oasis_dialogue/save.gd")

const BASEDIR := "res://"
var TESTDIR := BASEDIR.path_join("test_json_exporter")


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


func test_export_single_file() -> void:
	var sut: JsonExporter = add_child_autofree(JsonExporter.new())
	sut.init_json_file_factory(func(): return JsonFile.new())
	sut.init_parse(
			func(id: int, text: String) -> AST.AST:
				var ast: AST.AST = null
				if id % 2 == 0:
					ast = AST.Branch.new(id, [
						AST.Prompt.new(-1, [
								AST.StringLiteral.new(text),
						]),
					])
				else:
					ast = AST.Branch.new(id, [
						AST.Response.new(-1, [
							AST.StringLiteral.new(text),
						]),
					])
				return ast
	)

	var fred := OasisFile.new()
	fred.set_value(
			Save.Character.DATA,
			Save.Character.Data.DISPLAY_NAME,
			"Fred",
	)
	fred.set_value("0", Save.Character.Branch.VALUE, "a")
	fred.set_value("1", Save.Character.Branch.VALUE, "b")
	var tim := OasisFile.new()
	tim.set_value(
			Save.Character.DATA,
			Save.Character.Data.DISPLAY_NAME,
			"Tim",
	)
	tim.set_value("0", Save.Character.Branch.VALUE, "c")
	tim.set_value("1", Save.Character.Branch.VALUE, "d")
	var characters: Array[OasisFile] = [
			fred,
			tim,
	]

	var path := TESTDIR.path_join("abc.json")
	var config := ExportConfig.new()
	config.path = path
	sut.export(config, characters)

	var json := JsonFile.new()
	json.load(path)
	var data := json.get_loaded_data()

	assert_ne(data.get("Fred", {}).size(), 0)
	assert_ne(data.get("Tim", {}).size(), 0)


func test_export_directory() -> void:
	var sut: JsonExporter = add_child_autofree(JsonExporter.new())
	sut.init_json_file_factory(func(): return JsonFile.new())
	sut.init_parse(
			func(id: int, text: String) -> AST.AST:
				var ast: AST.AST = null
				if id % 2 == 0:
					ast = AST.Branch.new(id, [
						AST.Prompt.new(-1, [
								AST.StringLiteral.new(text),
						]),
					])
				else:
					ast = AST.Branch.new(id, [
						AST.Response.new(-1, [
							AST.StringLiteral.new(text),
						]),
					])
				return ast
	)

	var fred := OasisFile.new()
	fred.set_value(
			Save.Character.DATA,
			Save.Character.Data.DISPLAY_NAME,
			"Fred",
	)
	fred.set_value("0", Save.Character.Branch.VALUE, "a")
	fred.set_value("1", Save.Character.Branch.VALUE, "b")
	var tim := OasisFile.new()
	tim.set_value(
			Save.Character.DATA,
			Save.Character.Data.DISPLAY_NAME,
			"Tim",
	)
	tim.set_value("0", Save.Character.Branch.VALUE, "c")
	tim.set_value("1", Save.Character.Branch.VALUE, "d")
	var characters: Array[OasisFile] = [
			fred,
			tim,
	]

	var config := ExportConfig.new()
	config.path = TESTDIR
	sut.export(config, characters)

	var json := JsonFile.new()
	var data := {}

	var fred_path := config.path.path_join("fred.json")
	assert_file_exists(fred_path)
	json.load(fred_path)
	data = json.get_loaded_data()
	assert_ne_deep(data.get("0", {}), {})
	assert_ne_deep(data.get("1", {}), {})

	var tim_path := config.path.path_join("tim.json")
	assert_file_exists(tim_path)
	json = JsonFile.new()
	json.load(tim_path)
	data = json.get_loaded_data()
	assert_ne_deep(data.get("0", {}), {})
	assert_ne_deep(data.get("1", {}), {})
