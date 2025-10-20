extends GutTest

const OasisFile := preload("res://addons/oasis_dialogue/oasis_file.gd")

const BASE := "res://"
var TESTDIR := BASE.path_join("test_oasis_file")

var sut: OasisFile = null


func before_all() -> void:
	var dir := DirAccess.open(BASE)
	dir.make_dir(TESTDIR)
	after_each()


func after_all() -> void:
	var dir := DirAccess.open(BASE)
	dir.remove(TESTDIR)


func before_each() -> void:
	sut = OasisFile.new()


func after_each() -> void:
	var dir := DirAccess.open(TESTDIR)
	for file in dir.get_files():
		dir.remove(TESTDIR.path_join(file))


func test_has_key() -> void:
	sut.set_value("a", "b")
	assert_true(sut.has_key("a"))
	assert_false(sut.has_key("b"))


func test_get_returns_set_value() -> void:
	sut.set_value("c", "d")
	assert_eq(sut.get_value("c"), "d")


func test_get_keys_returns_set_keys() -> void:
	sut.set_value("a", "x")
	sut.set_value("b", "y")
	sut.set_value("c", "z")

	assert_eq_deep(sut.get_keys(), ["a", "b", "c"])


func get_returns_default_if_key_not_exists() -> void:
	assert_eq(sut.get_value("e", "f"), "f")


func test_parsing_encoded_text() -> void:
	sut.set_value("a", "b")
	var text := sut.encode_to_text()

	sut = OasisFile.new()
	sut.parse(text)
	assert_eq(sut.get_value("a", ""), "b")


func test_parsing_multiple_values() -> void:
	sut.set_value("a", "b")
	sut.set_value("c", "d")
	var text := sut.encode_to_text()

	sut = OasisFile.new()
	sut.parse(text)
	assert_eq(sut.get_value("a", ""), "b")
	assert_eq(sut.get_value("c", ""), "d")


func test_parse_no_closing_bracket_returns_error() -> void:
	assert_ne(sut.parse("[a\nb"), Error.OK)


func test_parse_sequential_keys_returns_error() -> void:
	assert_ne(sut.parse("[a]\n[b]"), Error.OK)


func test_empty_key_returns_error() -> void:
	assert_ne(sut.parse("[]b"), Error.OK)


func test_parse_empty_value_returns_error() -> void:
	assert_ne(sut.parse("[a]\n[/]"), Error.OK)


func test_duplicate_key_returns_error() -> void:
	assert_ne(sut.parse("[a]\nb\n[/]\n\n[a]\nc[/]"), Error.OK)


func test_missing_key_at_beginning_of_file_returns_error() -> void:
	assert_ne(sut.parse("b"), Error.OK)


func test_empty_value_returns_error() -> void:
	assert_ne(sut.parse("[a]\n[/]"), Error.OK)


func test_missing_value_end_returns_error() -> void:
	assert_ne(sut.parse("[a]\nb"), Error.OK)


func test_load_recovers_saved_data() -> void:
	sut.set_value("g", "h")
	sut.save("test.oasis")
	sut = OasisFile.new()
	sut.load("test.oasis")
	assert_eq(sut.get_value("g"), "h")
