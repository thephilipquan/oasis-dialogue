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


func test_parse_annotation_sets_position() -> void:
	var source := "@rng\n@unique"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)

	var rng := ast.annotations[0]
	assert_eq(rng.line, tokens[1].line)
	assert_eq(rng.column, tokens[1].column)

	var unique := ast.annotations[1]
	assert_eq(unique.line, tokens[4].line)
	assert_eq(unique.column, tokens[4].column)


func test_parse_condition_sets_position() -> void:
	var source := "@response\n{ is_day }"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)

	var response := ast.responses[0]
	var condition := response.conditions[0]
	assert_eq(condition.line, tokens[4].line)
	assert_eq(condition.column, tokens[4].column)


func test_parse_action_sets_position() -> void:
	var source := "@response\nhello world{ is_day }"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)

	var response := ast.responses[0]
	var action := response.actions[0]
	assert_eq(action.line, tokens[5].line)
	assert_eq(action.column, tokens[5].column)


func test_parse_stringliteral_sets_position() -> void:
	var source := "@response\nhello world{ is_day }"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)

	var text := ast.responses[0].text
	assert_eq(text.line, tokens[3].line)
	assert_eq(text.column, tokens[3].column)


func test_parse_numberliteral_sets_position() -> void:
	var source := "@response\nhello world{ is_day 3}"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)

	var response := ast.responses[0]
	var action := response.actions[0]
	assert_eq(action.value.line, tokens[6].line)
	assert_eq(action.value.column, tokens[6].column)


func test_annotations_on_same_line_is_invalid() -> void:
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


func test_space_between_prompt_annotation_and_body_is_invalid() -> void:
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


func test_space_between_response_annotation_and_body_is_invalid() -> void:
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


func test_space_between_prompt_body_is_invalid() -> void:
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


func test_space_between_response_body_is_invalid() -> void:
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


func test_no_prompt_body_text_is_invalid() -> void:
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


func test_no_response_body_text_is_invalid() -> void:
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


func test_text_after_prompt_action_is_invalid() -> void:
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


func test_text_after_response_action_is_invalid() -> void:
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


func test_prompt_after_response_is_invalid() -> void:
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


func test_extra_lines_in_beginning_is_valid() -> void:
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


func test_extra_lines_at_end_is_valid() -> void:
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


func test_only_prompt_is_valid() -> void:
	var source := (
"""
@prompt
hey there
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	assert_eq(sut.get_errors().size(), 0)


func test_only_response_is_valid() -> void:
	var source := (
"""
@response
hey there
"""
	)
	var tokens := lexer.tokenize(source)
	sut.parse(tokens)
	assert_eq(sut.get_errors().size(), 0)
