extends GutTest

const Token := preload("res://addons/oasis_dialogue/model/token.gd")
const Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const Parser := preload("res://addons/oasis_dialogue/model/parser.gd")

const Type := Token.Type
# openCurlyButEmptyCondition_missingCondition
# openCurlyButEmptyAction_missingAction

var lexer: Lexer = null
var sut: Parser = null


func before_each() -> void:
	lexer = Lexer.new()
	sut = Parser.new()

func test_peek_with_offset() -> void:
	var source := "@rng\n"
	sut._tokens = lexer.tokenize(source)
	assert_eq(sut.peek().type, Type.ATSIGN)
	assert_eq(sut.peek(1).type, Type.RNG)


func test_peek_type_with_offset() -> void:
	var source := "@rng\n"
	sut._tokens = lexer.tokenize(source)
	assert_eq(sut.peek_type(), Type.ATSIGN)
	assert_eq(sut.peek_type(1), Type.RNG)


func test_add_error_ignores_eol() -> void:
	var source := "@rng\n\nhey there"
	sut._tokens = lexer.tokenize(source)
	sut._position = 4
	sut.add_error("some_error")
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_true(error.message.contains("RNG"), "WARNING: brittle test checks if RNG is in error message")
	else:
		fail_test("expected error got none")


func test_add_error_ignores_atsign() -> void:
	var source := "@rng@@hey there"
	sut._tokens = lexer.tokenize(source)
	sut._position = 4
	sut.add_error("some_error")
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_true(error.message.contains("RNG"), "WARNING: brittle test checks if RNG is in error message")
	else:
		fail_test("expected error got none")


func test_annotations_on_same_line() -> void:
	var source := "@rng@unique"
	var tokens := lexer.tokenize(source)
	gut.p(tokens, 3)
	sut.parse(tokens)
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_eq(error.line, 0)
		assert_eq(error.column, 4)
	else:
		fail_test("expected errors, got none")


func test_space_between_prompt_annotation_and_body() -> void:
	var source := (
"""
@prompt

hey there
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_eq(error.line, 2)
		assert_eq(error.column, 0)
	else:
		fail_test("expected errors, got none")


func test_space_between_response_annotation_and_body() -> void:
	var source := (
"""
@response

hey there
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_eq(error.line, 2)
		assert_eq(error.column, 0)
	else:
		fail_test("expected errors, got none")


func test_space_between_prompt_body() -> void:
	var source := (
"""
@prompt
hey there

you fool
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_eq(error.line, 4)
		assert_eq(error.column, 0)
	else:
		fail_test("expected errors, got none")


func test_space_between_response_body() -> void:
	var source := (
"""
@response
hey there

you fool
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_eq(error.line, 4)
		assert_eq(error.column, 0)
	else:
		fail_test("expected errors, got none")


func test_no_prompt_body_text() -> void:
	var source := (
"""
@prompt
{ give_gold }
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_eq(error.line, 2)
		assert_eq(error.column, 13)
	else:
		fail_test("missing errors when there should be")


func test_no_response_body_text() -> void:
	var source := (
"""
@response
{ give_gold }
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_eq(error.line, 2)
		assert_eq(error.column, 13)
	else:
		fail_test("expected errors, got none")


func test_text_after_prompt_action() -> void:
	var source := (
"""
@prompt
hey there { branch 3 } you fool
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_eq(error.line, 2)
		assert_eq(error.column, 23)
	else:
		fail_test("expected errors, got none")


func test_text_after_response_action() -> void:
	var source := (
"""
@response
hey there { branch 3 } you fool
"""
	)

	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_eq(error.line, 2)
		assert_eq(error.column, 23)
	else:
		fail_test("expected errors, got none")


func test_prompt_after_response() -> void:
	var source := (
"""
@response
yes please
@prompt
want something?
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	var error := sut.get_errors().front()
	if error:
		gut.p(error.message, 2)
		assert_eq(error.line, 3)
		assert_eq(error.column, 0)
	else:
		fail_test("expected errors, got none")


func test_extra_lines_in_beginning() -> void:
	var source := (
"""


@unique
@prompt
hey there
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	assert_eq(sut.get_errors().size(), 0)


func test_extra_lines_at_end() -> void:
	var source := (
"""
@rng
@prompt
hey there


"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	assert_eq(sut.get_errors().size(), 0)
	print(sut.get_errors())


func test_only_prompt() -> void:
	var source := (
"""
@prompt
hey there
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	assert_eq(sut.get_errors().size(), 0)


func test_only_response() -> void:
	var source := (
"""
@response
hey there
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	assert_eq(sut.get_errors().size(), 0)
