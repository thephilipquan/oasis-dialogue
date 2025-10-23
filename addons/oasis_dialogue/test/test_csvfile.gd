extends GutTest

const CSV := preload("res://addons/oasis_dialogue/io/csvfile.gd")

const TESTDIR := "res://"
const TESTPATH := "test_csvfile.csv"

var sut: CSV = null


func before_all() -> void:
	after_each()


func before_each() -> void:
	sut = CSV.new()


func after_each() -> void:
	var dir := DirAccess.open(TESTDIR)
	if dir.file_exists(TESTPATH):
		dir.remove(TESTPATH)


func test_set_headers_overwrites() -> void:
	sut.set_headers("a")
	sut.set_headers("b", "c")
	assert_eq_deep(sut.get_headers(), ["b", "c"])


func test_has_character() -> void:
	sut.set_headers("a")
	var stage := sut.stage("fred", 0)
	stage.add_prompt("a")
	sut.update(stage)

	assert_true(sut.has_character("fred"))
	assert_false(sut.has_character("tom"))


func test_get_prompt() -> void:
	sut.set_headers("a", "b")
	var stage := sut.stage("fred", 0)
	stage.add_prompt("a")
	sut.update(stage)

	assert_eq(sut.get_prompt("fred", 0, 0), "a")


func test_get_prompt_for_non_existing_branch_returns_empty() -> void:
	sut.set_headers("a", "b")
	var stage := sut.stage("fred", 0)
	stage.add_prompt("a")
	sut.update(stage)

	assert_eq(sut.get_prompt("fred", 1, 0), "")


func test_get_prompt_for_non_existing_prompt_returns_empty() -> void:
	sut.set_headers("a", "b")
	var stage := sut.stage("fred", 0)
	stage.add_prompt("a")
	sut.update(stage)

	assert_eq(sut.get_prompt("fred", 0, 1), "")


func test_get_prompt_for_non_existing_column_returns_empty() -> void:
	sut.set_headers("a")
	var stage := sut.stage("fred", 0)
	stage.add_prompt("a")
	sut.update(stage)

	assert_eq(sut.get_prompt("fred", 0, 1, 1), "")


func test_get_response() -> void:
	sut.set_headers("a", "b")
	var stage := sut.stage("fred", 0)
	stage.add_response("a")
	sut.update(stage)

	assert_eq(sut.get_response("fred", 0, 0), "a")


func test_get_response_for_non_existing_branch_returns_empty() -> void:
	sut.set_headers("a", "b")
	var stage := sut.stage("fred", 0)
	stage.add_response("a")
	sut.update(stage)

	assert_eq(sut.get_response("fred", 1, 0), "")


func test_get_response_for_non_existing_response_returns_empty() -> void:
	sut.set_headers("a")
	var stage := sut.stage("fred", 0)
	stage.add_response("a")
	sut.update(stage)

	assert_eq(sut.get_response("fred", 0, 1), "")


func test_get_response_for_non_existing_column_returns_empty() -> void:
	sut.set_headers("a")
	var stage := sut.stage("fred", 0)
	stage.add_response("a")
	sut.update(stage)

	assert_eq(sut.get_response("fred", 0, 1, 1), "")


func test_load_restores_saved_data() -> void:
	sut.set_headers("a", "b")
	var stage := sut.stage("fred", 0)
	stage.add_prompt("a")
	stage.add_prompt("b")
	stage.add_response("c")
	stage.add_response("d")
	sut.update(stage)

	sut.save(TESTPATH)

	before_each()
	sut.load(TESTPATH)

	assert_eq_deep(sut.get_headers(), ["a", "b"])
	assert_eq(sut.get_character_count(), 1)
	assert_eq(sut.get_prompt_count("fred", 0), 2)
	assert_eq(sut.get_response_count("fred", 0), 2)

	assert_eq(sut.get_prompt("fred", 0, 0), "a")
	assert_eq(sut.get_prompt("fred", 0, 1), "b")
	assert_eq(sut.get_response("fred", 0, 0), "c")
	assert_eq(sut.get_response("fred", 0, 1), "d")
