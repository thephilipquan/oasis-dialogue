extends GutTest

const Lexer := preload("res://addons/oasis_dialogue/definitions/model/lexer.gd")
const Token := preload("res://addons/oasis_dialogue/definitions/model/token.gd")

const Type := Token.Type

var sut: Lexer = null


func before_all() -> void:
	sut = Lexer.new()


func test_annotation() -> void:
	var source := "@abc"
	var tokens := sut.tokenize(source)

	var expected_types: Array[Type] = [
			Type.ATSIGN,
			Type.IDENTIFIER,
			Type.EOF
	]
	var types := sut.tokenize(source).map(
			func(t: Token) -> Type:
				return t.type
	)
	assert_eq_deep(types, expected_types)
	assert_eq(tokens[1].value, "abc")


func test_annotation_with_non_identifier() -> void:
	var source := "@:"
	var tokens := sut.tokenize(source)

	var expected_types: Array[Type] = [
			Type.ATSIGN,
			Type.COLON,
			Type.EOF
	]
	var types := sut.tokenize(source).map(
			func(t: Token) -> Type:
				return t.type
	)
	assert_eq_deep(types, expected_types)


func test_identifier() -> void:
	var source := "a_b-c"
	var tokens := sut.tokenize(source)

	var expected_types: Array[Type] = [
			Type.IDENTIFIER,
			Type.EOF
	]
	var types := sut.tokenize(source).map(
			func(t: Token) -> Type:
				return t.type
	)
	assert_eq_deep(types, expected_types)
	assert_eq(tokens[0].value, "a_b-c")


func test_multiple_identifiers() -> void:
	var source := "a b c"
	var tokens := sut.tokenize(source)

	var expected_types: Array[Type] = [
			Type.IDENTIFIER,
			Type.IDENTIFIER,
			Type.IDENTIFIER,
			Type.EOF
	]
	var types := sut.tokenize(source).map(
			func(t: Token) -> Type:
				return t.type
	)
	assert_eq_deep(types, expected_types)
	assert_eq(tokens[0].value, "a")
	assert_eq(tokens[1].value, "b")
	assert_eq(tokens[2].value, "c")


func test_colon_with_text() -> void:
	var source := ":abc"
	var tokens := sut.tokenize(source)

	var expected_types: Array[Type] = [
			Type.COLON,
			Type.TEXT,
			Type.EOF
	]
	var types := sut.tokenize(source).map(
			func(t: Token) -> Type:
				return t.type
	)
	assert_eq_deep(types, expected_types)
	assert_eq(tokens[1].value, "abc")


func test_colon_with_space_between() -> void:
	var source := ": abc"
	var tokens := sut.tokenize(source)

	var expected_types: Array[Type] = [
			Type.COLON,
			Type.TEXT,
			Type.EOF
	]
	var types := sut.tokenize(source).map(
			func(t: Token) -> Type:
				return t.type
	)
	assert_eq_deep(types, expected_types)
	assert_eq(tokens[1].value, "abc")


func test_colon_without_text() -> void:
	var source := ":"
	var tokens := sut.tokenize(source)

	var expected_types: Array[Type] = [
			Type.COLON,
			Type.EOF
	]
	var types := sut.tokenize(source).map(
			func(t: Token) -> Type:
				return t.type
	)
	assert_eq_deep(types, expected_types)


func test_illegal_characters() -> void:
	var source := "# 9 ?!"
	var tokens := sut.tokenize(source)

	var expected_types: Array[Type] = [
			Type.ILLEGAL,
			Type.ILLEGAL,
			Type.ILLEGAL,
			Type.ILLEGAL,
			Type.EOF
	]
	var types := sut.tokenize(source).map(
			func(t: Token) -> Type:
				return t.type
	)
	assert_eq_deep(types, expected_types)


func test_example() -> void:
	var source := "@a\nb:c"
	var tokens := sut.tokenize(source)

	var expected_types: Array[Type] = [
			Type.ATSIGN,
			Type.IDENTIFIER,

			Type.EOL,

			Type.IDENTIFIER,

			Type.COLON,
			Type.TEXT,

			Type.EOF
	]
	var types := sut.tokenize(source).map(
			func(t: Token) -> Type:
				return t.type
	)
	assert_eq_deep(types, expected_types)
	assert_eq(tokens[1].value, "a")
	assert_eq(tokens[3].value, "b")
	assert_eq(tokens[5].value, "c")


func test_multiple_example() -> void:
	var source := "@a\nb:c\nd: e"
	var tokens := sut.tokenize(source)

	var expected_types: Array[Type] = [
			Type.ATSIGN,
			Type.IDENTIFIER,

			Type.EOL,

			Type.IDENTIFIER,
			Type.COLON,
			Type.TEXT,

			Type.EOL,

			Type.IDENTIFIER,
			Type.COLON,
			Type.TEXT,

			Type.EOF
	]
	var types := tokens.map(
			func(t: Token) -> Type:
				return t.type
	)
	assert_eq_deep(types, expected_types)
	assert_eq(tokens[1].value, "a")
	assert_eq(tokens[3].value, "b")
	assert_eq(tokens[5].value, "c")
	assert_eq(tokens[7].value, "d")
	assert_eq(tokens[9].value, "e")


func test_whitespace_ignored() -> void:
	var source := "@a   \n  b   : c"
	var tokens := sut.tokenize(source)

	assert_eq(tokens[1].value, "a")
	assert_eq(tokens[3].value, "b")
	assert_eq(tokens[5].value, "c")


func test_line_and_column() -> void:
	var source := "@a\n b: cde"
	var tokens := sut.tokenize(source)

	const expected := [
			[0, 0],
			[0, 1],
			[0, 2],
			[1, 1],
			[1, 2],
			[1, 4],
			[1, 7],
	]

	for i in expected.size():
		var line: int = expected[i][0]
		var column: int = expected[i][1]
		assert_eq(tokens[i].line, line)
		assert_eq(tokens[i].column, column)
