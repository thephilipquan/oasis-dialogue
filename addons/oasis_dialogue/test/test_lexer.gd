extends GutTest

const Token := preload("res://addons/oasis_dialogue/model/token.gd")
const Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")

const Type := Token.Type

var sut: Lexer = null


func before_each() -> void:
	sut = Lexer.new()


func test_end_of_file() -> void:
	var source := ""
	var expected: Array[Type] = [
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_whitespace_is_ignored() -> void:
	var source := "  \t  \t"
	var expected: Array[Type] = [
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_newline() -> void:
	var source := "\n"
	var expected: Array[Type] = [
		Type.EOL,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_curly_start() -> void:
	var source := "{"
	var expected: Array[Type] = [
		Type.CURLY_START,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_curly_end() -> void:
	var source := "}"
	var expected: Array[Type] = [
		Type.CURLY_END,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_skip_whitespace() -> void:
	var source := "		"
	var expected: Array[Type] = [
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_atsign() -> void:
	var source := "@"
	var expected: Array[Type] = [
		Type.ATSIGN,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_text_after_curly_brace_is_identifier() -> void:
	var source := "{ a b c_d-e }"
	var expected: Array[Type] = [
		Type.CURLY_START,
		Type.IDENTIFIER,
		Type.IDENTIFIER,
		Type.IDENTIFIER,
		Type.CURLY_END,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_text_after_atsign_is_identifier() -> void:
	var source := "@a"
	var expected: Array[Type] = [
		Type.ATSIGN,
		Type.IDENTIFIER,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_atsign_makes_next_text_identifier() -> void:
	var source := "@a b"
	var expected: Array[Type] = [
		Type.ATSIGN,
		Type.IDENTIFIER,
		Type.IDENTIFIER,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_text() -> void:
	var source := "!&*9@a b c"
	var expected: Array[Type] = [
		Type.TEXT,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_number() -> void:
	var source := "{ 0 1"
	var expected: Array[Type] = [
		Type.CURLY_START,
		Type.NUMBER,
		Type.NUMBER,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_illegal_character_in_identifier() -> void:
	var source := "@ab#!\n{ a#"
	var expected: Array[Type] = [
		Type.ATSIGN,
		Type.IDENTIFIER,
		Type.ILLEGAL,
		Type.EOL,

		Type.CURLY_START,
		Type.IDENTIFIER,
		Type.ILLEGAL,

		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_text_after_newline() -> void:
	var source := "@prompt\na b"
	var expected: Array[Type] = [
		Type.ATSIGN,
		Type.PROMPT,
		Type.EOL,
		Type.TEXT,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_text_after_curly_end() -> void:
	var source := "}a"
	var expected: Array[Type] = [
		Type.CURLY_END,
		Type.TEXT,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_text_ends_with_curly_start() -> void:
	var source := "a b {a"
	var expected: Array[Type] = [
		Type.TEXT,
		Type.CURLY_START,
		Type.IDENTIFIER,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_text_that_starts_with_numbers() -> void:
	var source := "5 a b c"
	var expected: Array[Type] = [
		Type.TEXT,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_new_line_shifts_line_and_column() -> void:
	var source := "a\n b\n\n  c"

	var tokens := sut.tokenize(source)
	var expected_tokens: Array[Vector2i] = [
		Vector2(0, 0), # a
		Vector2(0, 1),

		Vector2(1, 1), # b
		Vector2(1, 2),

		Vector2(2, 0),

		Vector2(3, 2), # c
		Vector2(3, 3), # EOF
	]

	for i in tokens.size():
		var got := tokens[i]
		var expected := expected_tokens[i]

		assert_eq(got.line, expected.x) # x is line.
		assert_eq(got.column, expected.y) # y is column.


func test_newline_resets_text_and_identifier() -> void:
	var source := "{a}\nb\n{c} d {e}"
	var expected: Array[Type] = [
			Type.CURLY_START,
			Type.IDENTIFIER,
			Type.CURLY_END,
			Type.EOL,

			Type.TEXT,
			Type.EOL,

			Type.CURLY_START,
			Type.IDENTIFIER,
			Type.CURLY_END,
			Type.TEXT,
			Type.CURLY_START,
			Type.IDENTIFIER,
			Type.CURLY_END,
			Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)
