extends GutTest

const AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const CsvExporter := preload("res://addons/oasis_dialogue/canvas/csv_exporter.gd")
const CsvFile := preload("res://addons/oasis_dialogue/io/csv_file.gd")
const ExportConfig := preload("res://addons/oasis_dialogue/model/export_config.gd")
const OasisFile := preload("res://addons/oasis_dialogue/io/oasis_file.gd")
const Save := preload("res://addons/oasis_dialogue/save.gd")

const BASEDIR := "res://"
var TESTDIR := BASEDIR.path_join("test_csv_exporter")

var sut: CsvExporter = null
var csv: CsvFile = null


func before_all() -> void:
	var dir := DirAccess.open(BASEDIR)
	dir.make_dir(TESTDIR)
	FileAccess.open(TESTDIR.path_join(".gdignore"), FileAccess.WRITE)
	after_each()


func before_each() -> void:
	sut = add_child_autofree(CsvExporter.new())
	sut.init_csv_file_factory(
			func():
				csv = CsvFile.new()
				return csv
	)


func after_each() -> void:
	var dir := DirAccess.open(TESTDIR)
	for file in dir.get_files():
		if file == ".gdignore":
			continue
		dir.remove(file)


func after_all() -> void:
	var dir := DirAccess.open(TESTDIR)
	dir.remove(".gdignore")
	dir = DirAccess.open(BASEDIR)
	dir.remove(TESTDIR)


func test_csv_writes_all_characters() -> void:
	sut.init_parse(
			func _parse(id: int, text: String) -> AST.AST:
				return AST.Prompt.new(-1, [
					AST.StringLiteral.new(text),
				])
	)
	var path := TESTDIR.path_join("dialogue.csv")
	var fred := OasisFile.new()
	fred.set_value(
			Save.Character.DATA,
			Save.Character.Data.DISPLAY_NAME,
			"Fred",
	)
	fred.set_value("0", Save.Character.Branch.VALUE, "a")
	fred.set_value("1", Save.Character.Branch.VALUE, "b")
	var joe := OasisFile.new()
	joe.set_value(
			Save.Character.DATA,
			Save.Character.Data.DISPLAY_NAME,
			"Joe",
	)
	joe.set_value("0", Save.Character.Branch.VALUE, "c")
	joe.set_value("1", Save.Character.Branch.VALUE, "d")
	var characters: Array[OasisFile] = [
			fred,
			joe,
	]
	var config := ExportConfig.new()
	config.path = path
	sut.export(config, characters)

	csv = CsvFile.new()
	csv.load(path)

	assert_eq(csv.get_prompt("Fred", 0, 0), "a")
	assert_eq(csv.get_prompt("Fred", 1, 0), "b")
	assert_eq(csv.get_prompt("Joe", 0, 0), "c")
	assert_eq(csv.get_prompt("Joe", 1, 0), "d")
