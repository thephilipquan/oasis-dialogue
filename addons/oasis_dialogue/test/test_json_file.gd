extends GutTest

const JsonFile := preload("res://addons/oasis_dialogue/io/json_file.gd")

const BASEDIR := "res://"
var TESTDIR := BASEDIR.path_join("test_json_file")

var sut: JsonFile = null


func before_all() -> void:
	var dir := DirAccess.open(BASEDIR)
	dir.make_dir(TESTDIR)


func after_all() -> void:
	var dir := DirAccess.open(BASEDIR)
	dir.remove(TESTDIR)


func before_each() -> void:
	sut = JsonFile.new()


func after_each() -> void:
	var dir := DirAccess.open(TESTDIR)
	for file in dir.get_files():
		dir.remove(TESTDIR.path_join(file))


func test_load_returns_saved_data() -> void:
	var path := TESTDIR.path_join("abc.json")

	var data := {}
	data.a = "b"
	data.c = "d"
	sut.save(path, data)

	before_each()
	sut.load(path)
	data = sut.get_loaded_data()

	assert_eq(data.a, "b")
	assert_eq(data.c, "d")
