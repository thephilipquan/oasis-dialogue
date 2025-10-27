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


func test_get_returns_set_value() -> void:
	sut.set_value("a", "b")
	assert_eq(sut.get_value("a"), "b")


func test_load_returns_saved_data() -> void:
	var path := TESTDIR.path_join("abc.json")

	sut.set_value("a", "b")
	sut.set_value("c", "d")
	sut.save(path)

	before_each()
	sut.load(path)

	assert_eq(sut.get_value("a"), "b")
	assert_eq(sut.get_value("c"), "d")
