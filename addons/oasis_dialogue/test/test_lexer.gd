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
	var source := "     "
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


func test_identifier() -> void:
	var source := "{ hey }"
	var expected: Array[Type] = [
		Type.CURLY_START,
		Type.IDENTIFIER,
		Type.CURLY_END,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_keyword() -> void:
	var source := "@rng"
	var expected: Array[Type] = [
		Type.ATSIGN,
		Type.IDENTIFIER,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_atsign_makes_next_text_identifier() -> void:
	var source := "\n@hey there"
	var expected: Array[Type] = [
		Type.EOL,
		Type.ATSIGN,
		Type.IDENTIFIER,
		Type.IDENTIFIER,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_text() -> void:
	var source := "hey_there"
	var expected: Array[Type] = [
		Type.TEXT,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_text_after_newline() -> void:
	var source := "@prompt\nhey there"
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
	var source := "}hey there"
	var expected: Array[Type] = [
		Type.CURLY_END,
		Type.TEXT,
		Type.EOF,
	]
	var got := sut.tokenize(source).map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_whitespace_ignored_after_curly_end() -> void:
	var source := "{ something }     \nhey"
	var expected: Array[Type] = [
		Type.CURLY_START,
		Type.IDENTIFIER,
		Type.CURLY_END,
		Type.EOL,
		Type.TEXT,
		Type.EOF,
	]
	var tokens := sut.tokenize(source)
	gut.p(tokens.map(func(t: Token): return t.to_string()), 1)
	var got := tokens.map(func(t: Token): return t.type)
	assert_eq_deep(got, expected)


func test_new_line_shifts_line_and_column() -> void:
	var source := (
"""{ }
  { }"""
	)

	var tokens := sut.tokenize(source)
	var expected_tokens: Array[Vector2i] = [
		Vector2(0, 0),
		Vector2(0, 2),
		Vector2(0, 3),

		Vector2(1, 2),
		Vector2(1, 4),
		Vector2(1, 5),
	]

	for i in tokens.size():
		var got := tokens[i]
		var expected := expected_tokens[i]

		assert_eq(got.line, expected.x) # x is line.
		assert_eq(got.column, expected.y) # y is column.
