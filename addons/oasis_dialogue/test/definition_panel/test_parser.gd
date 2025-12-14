extends GutTest

const AST := preload("res://addons/oasis_dialogue/definition_panel/model/ast.gd")
const Lexer := preload("res://addons/oasis_dialogue/definition_panel/model/lexer.gd")
const Parser := preload("res://addons/oasis_dialogue/definition_panel/model/parser.gd")

var parser: Parser = null
var lexer: Lexer = null


func before_all() -> void:
	parser = Parser.new()
	lexer = Lexer.new()


func test_empty() -> void:
	var source := ""
	var ast := _parse(source)

	assert_eq(ast.children.size(), 0)


func test_id() -> void:
	var source := "a"
	var ast := _parse(source)
	var d: AST.Declaration = ast.children[0]

	assert_eq(d.children.size(), 1)
	assert_is(d.children[0], AST.Identifier)


func test_id_with_annotation() -> void:
	var source := "@a\nb"
	var ast := _parse(source)
	var d: AST.Declaration = ast.children[0]

	assert_eq(d.children.size(), 2)
	assert_is(d.children[0], AST.Annotation)
	assert_is(d.children[1], AST.Identifier)


func test_id_with_multiple_annotations() -> void:
	var source := "@a\n@b\nc"
	var ast := _parse(source)
	var d: AST.Declaration = ast.children[0]

	assert_eq(d.children.size(), 3)
	assert_is(d.children[0], AST.Annotation)
	assert_is(d.children[1], AST.Annotation)
	assert_is(d.children[2], AST.Identifier)


func test_id_with_description() -> void:
	var source := "a: b c d"
	var ast := _parse(source)
	var d: AST.Declaration = ast.children[0]

	assert_eq(d.children.size(), 2)
	assert_is(d.children[0], AST.Identifier)
	assert_is(d.children[1], AST.Description)


func test_annotation_with_missing_name_appends_error() -> void:
	var source := "@\na"
	var ast := _parse(source)

	assert_eq(ast.children.size(), 2)
	assert_is(ast.children[0], AST.Error)
	assert_is(ast.children[1], AST.Declaration)
	assert_is(ast.children[1].children[0], AST.Identifier)


func test_annotation_with_non_id_appends_error() -> void:
	var source := "@?"
	var ast := _parse(source)

	assert_eq(ast.children.size(), 1)
	assert_is(ast.children[0], AST.Error)


func test_non_eol_after_annotation_appends_error() -> void:
	var source := "@a b\nc"
	var ast := _parse(source)
	var d: AST.Declaration = ast.children[0]

	assert_eq(d.children.size(), 3)
	assert_is(d.children[0], AST.Annotation)
	assert_is(d.children[1], AST.Error)
	assert_is(d.children[2], AST.Identifier)


func test_non_colon_after_id_appends_error() -> void:
	var source := "a b"
	var ast := _parse(source)
	var d: AST.Declaration = ast.children[0]

	assert_eq(d.children.size(), 2)
	assert_is(d.children[0], AST.Identifier)
	assert_is(d.children[1], AST.Error)


func test_missing_text_after_colon_appends_error() -> void:
	var source := "a:"
	var ast := _parse(source)
	var d: AST.Declaration = ast.children[0]

	assert_eq(d.children.size(), 2)
	assert_is(d.children[0], AST.Identifier)
	assert_is(d.children[1], AST.Error)


func test_base_error() -> void:
	var source := ": @a\nb"
	var ast := _parse(source)

	assert_eq(ast.children.size(), 2)
	assert_is(ast.children[0], AST.Error)
	assert_is(ast.children[1], AST.Declaration)


func test_line_and_columns() -> void:
	var source := "\n @a b\nc: d"
	var ast := _parse(source)
	var d: AST.Declaration = ast.children[0]
	var expected := [
			[1, 2],
			[1, 4],
			[2, 0],
			[2, 3],
	]
	var got = d.children.map(
			func(l: AST.Leaf) -> Array[int]:
				return [l.line, l.column]
	)
	assert_eq_deep(got, expected)


func test_values() -> void:
	var source := "@a\n@b\nc: d e f\n@g\nh"
	var ast := _parse(source)

	var expected := [
			"a",
			"b",
			"c",
			"d e f",
			"g",
			"h",
	]
	var got: Array[String] = []
	for i in ast.children.size():
		var d: AST.Declaration = ast.children[i]
		for l in d.children:
			got.push_back(l.value)

	assert_eq_deep(got, expected)


func _parse(source: String) -> AST.Program:
	return parser.parse(lexer.tokenize(source))
