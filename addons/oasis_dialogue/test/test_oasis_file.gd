extends GutTest

const OasisFile := preload("res://addons/oasis_dialogue/io/oasis_file.gd")

const BASEDIR := "res://"
var TESTDIR := BASEDIR.path_join("test_oasis_file")

var sut: OasisFile = null


func before_all() -> void:
	var dir := DirAccess.open(BASEDIR)
	dir.make_dir(TESTDIR)
	after_each()


func after_all() -> void:
	var dir := DirAccess.open(BASEDIR)
	dir.remove(TESTDIR)


func before_each() -> void:
	sut = OasisFile.new()


func after_each() -> void:
	var dir := DirAccess.open(TESTDIR)
	for file in dir.get_files():
		dir.remove(TESTDIR.path_join(file))


func test_has_section() -> void:
	sut.set_value("a", "b", "c")
	assert_true(sut.has_section("a"))
	assert_false(sut.has_section("b"))


func test_get_returns_set_value() -> void:
	sut.set_value("a", "b", "c")
	assert_eq(sut.get_value("a", "b"), "c")


func test_get_sections() -> void:
	sut.set_value("a", "b", "c")
	sut.set_value("d", "e", "f")
	sut.set_value("g", "h", "i")

	assert_eq_deep(sut.get_sections(), ["a", "d", "g"])


func test_get_section_keys() -> void:
	sut.set_value("a", "b", "c")
	sut.set_value("a", "e", "f")
	sut.set_value("g", "h", "i")

	assert_eq_deep(sut.get_section_keys("a"), ["b", "e"])


func get_returns_default_if_key_not_exists() -> void:
	assert_eq(sut.get_value("a", "b", "c"), "c")


func test_parsing_encoded_text() -> void:
	sut.set_value("a", "b", "c")
	var text := sut.encode_to_text()

	sut = OasisFile.new()
	sut.parse(text)
	assert_eq(sut.get_value("a", "b", ""), "c")


func test_parsing_multiple_values() -> void:
	sut.set_value("a", "b", "c")
	sut.set_value("d", "e", "f")
	var text := sut.encode_to_text()

	sut = OasisFile.new()
	sut.parse(text)
	assert_eq(sut.get_value("a", "b", ""), "c")
	assert_eq(sut.get_section_keys("a").size(), 1)
	assert_eq(sut.get_value("d", "e", ""), "f")
	assert_eq(sut.get_section_keys("d").size(), 1)


func test_parsing_bool() -> void:
	sut.set_value("a", "b", true)
	sut.set_value("c", "d", false)
	var text := sut.encode_to_text()

	sut = OasisFile.new()
	sut.parse(text)
	assert_true(sut.get_value("a", "b", false))
	assert_false(sut.get_value("c", "d", true))


func test_parsing_vector2() -> void:
	sut.set_value("a", "b", Vector2(4, -6))
	sut.set_value("c", "d", Vector2(-1.234, 5.678))
	var text := sut.encode_to_text()

	sut = OasisFile.new()
	sut.parse(text)
	assert_eq(sut.get_value("a", "b"), Vector2(4, -6))
	assert_eq(sut.get_value("c", "d"), Vector2(-1.234, 5.678))


func test_parse_empty_string_is_valid() -> void:
	assert_eq(sut.parse(""), Error.OK)


func test_parse_no_closing_section_bracket_returns_error() -> void:
	assert_ne(sut.parse("[[a\nb"), Error.OK)


func test_parse_sequential_sections_returns_error() -> void:
	assert_ne(sut.parse("[[a]]\n[[b]]"), Error.OK)


func test_empty_section_returns_error() -> void:
	assert_ne(sut.parse("[[]]\n[a]\nb"), Error.OK)


func test_parse_no_closing_key_bracket_returns_error() -> void:
	assert_ne(sut.parse("[[a]]\n[b"), Error.OK)


func test_parse_sequential_keys_returns_error() -> void:
	assert_ne(sut.parse("[[a]]\n[b]\n[c]"), Error.OK)


func test_empty_key_returns_error() -> void:
	assert_ne(sut.parse("[[a]]\n[]\nb"), Error.OK)


func test_parse_empty_value_returns_error() -> void:
	assert_ne(sut.parse("[[a]]\n[b]\n[[c]]"), Error.OK)


func test_missing_section_at_beginning_of_file_returns_error() -> void:
	assert_ne(sut.parse("[a]\nb"), Error.OK)


func test_parse_empty_value_at_eof_returns_error() -> void:
	assert_ne(sut.parse("[[a]]\n[b]"), Error.OK)


func test_missing_key_at_eof_returns_error() -> void:
	assert_ne(sut.parse("[[a]]"), Error.OK)


func test_load_recovers_saved_data() -> void:
	sut.set_value("a", "b", "c")
	sut.set_value("d", "e", "f")
	sut.save(TESTDIR.path_join("test.oasis"))

	sut = OasisFile.new()
	sut.load(TESTDIR.path_join("test.oasis"))
	assert_eq(sut.get_value("a", "b"), "c")
	assert_eq(sut.get_value("d", "e"), "f")


func test_load_recovers_saved_data_with_extra_lines_at_end() -> void:
	sut.set_value("a", "b", "c")
	sut.save(TESTDIR.path_join("test.oasis"))

	var file := FileAccess.open(TESTDIR.path_join("test.oasis"), FileAccess.READ_WRITE)
	file.store_string(file.get_as_text() + "\n\n\n")
	file.close()

	sut = OasisFile.new()
	sut.load(TESTDIR.path_join("test.oasis"))
	assert_eq(sut.get_value("a", "b"), "c")
