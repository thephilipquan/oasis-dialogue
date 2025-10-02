extends GutTest

const Token := preload("res://addons/oasis_dialogue/model/token.gd")
const Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const Parser := preload("res://addons/oasis_dialogue/model/parser.gd")
const AST := preload("res://addons/oasis_dialogue/model/ast.gd")

const Type := Token.Type

var lexer: Lexer = null
var sut: Parser = null


func before_each() -> void:
	lexer = Lexer.new()
	sut = Parser.new()


func test_push_parent() -> void:
	sut.push_parent(AST.Branch.new())
	assert_eq(sut._stack.size(), 1)


func test_pop_parent() -> void:
	sut.push_parent(AST.Branch.new())

	sut.pop_parent()

	assert_eq(sut._stack.size(), 0)


func test_append_child() -> void:
	var branch := AST.Branch.new()
	sut.push_parent(branch)
	sut.append_child(AST.Branch.new())

	assert_eq(branch.children.size(), 1)


func test_append_expected_error() -> void:
	var branch := AST.Branch.new()
	sut.push_parent(branch)
	sut.append_expected_error(Type.IDENTIFIER, Token.new(Type.EOF, "eof", 3, 4))

	if not branch.children:
		fail_test("")
		return
	assert_is(branch.children[0], AST.Error)


func test_at_eof_not_at_end_returns_false() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut._position = 0
	assert_false(sut.at_eof())

	sut._position = tokens.size() - 2
	assert_false(sut.at_eof())


func test_at_eof_at_end_returns_true() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut._position = tokens.size() - 1
	assert_true(sut.at_eof())


func test_peek() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	assert_eq(sut.peek(), tokens[0])


func test_peek_with_offset() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	assert_eq(sut.peek(2), tokens[2])


func test_peek_at_end_returns_null() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	assert_null(sut.peek(tokens.size()))


func text_peek_expected_returns_next() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	var next := sut.peek_expected(Type.ATSIGN)

	assert_eq(next, tokens[0])


func text_peek_expected_list_returns_next() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	var next := sut.peek_expected([Type.IDENTIFIER, Type.ATSIGN])

	assert_eq(next, tokens[0])


func test_peek_expected_failed_returns_null() -> void:
	var branch := AST.Branch.new()
	sut.push_parent(branch)

	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	var next := sut.peek_expected(Type.IDENTIFIER)

	assert_null(next)


func test_peek_expected_failed_appends_error() -> void:
	var branch := AST.Branch.new()
	sut.push_parent(branch)

	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	var next := sut.peek_expected(Type.IDENTIFIER)

	if branch.children:
		assert_is(branch.children[0], AST.Error)
	else:
		fail_test("")


func test_peek_expected_at_end_fails() -> void:
	var branch := AST.Branch.new()
	sut.push_parent(branch)

	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens
	sut._position = tokens.size() - 1

	var next := sut.peek_expected(Type.EOF)

	assert_null(next)


func text_peek_expected_not_in_list_fails() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	var next := sut.peek_expected([Type.IDENTIFIER, Type.TEXT])

	assert_null(next)


func test_peek_sequence_exists_returns_true() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	assert_true(sut.peek_sequence([Type.ATSIGN, Type.IDENTIFIER]))


func test_peek_sequence_not_exists_returns_false() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	assert_false(sut.peek_sequence([Type.ATSIGN, Type.TEXT]))


func test_peek_sequence_near_end_returns_false() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens
	sut._position = tokens.size() - 1

	assert_false(sut.peek_sequence([Type.ATSIGN, Type.IDENTIFIER]))


func test_consume_increments_position() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume()

	assert_eq(sut._position, 1)


func test_consume_with_count() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume(3)

	assert_eq(sut._position, 3)


func test_consume_expected_exists_position_increments() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume_expected(Type.ATSIGN)

	assert_eq(sut._position, 1)


func test_consume_expected_not_next_position_remains_unchanged() -> void:
	sut.push_parent(AST.Branch.new())

	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume_expected(Type.TEXT)

	assert_eq(sut._position, 0)


func test_consume_at_end_returns_null() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume(tokens.size() - 1)

	assert_null(sut.consume())


func test_consume_at_end_does_not_increment_position() -> void:
	var source := "@a @b @c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume(tokens.size() - 1)

	var before := sut._position
	sut.consume
	var after := sut._position

	assert_eq(after, before)


func test_consume_to_consumes_first_match_and_increments() -> void:
	var source := "@@@b c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume_to(Type.ATSIGN)

	assert_eq(sut._position, 1)


func test_consume_to_consumes_first_match() -> void:
	var source := "@@@b c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume_to(Type.IDENTIFIER)

	assert_eq(sut._position, 4)


func test_consume_to_stops_at_eof_if_no_match() -> void:
	var source := "@@@b c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume_to(Type.TEXT)

	assert_eq(sut._position, 5)


func test_consume_while_stops_at_first_non_match() -> void:
	var source := "@@@b c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume_while(Type.ATSIGN)

	assert_eq(sut._position, 3)


func test_consume_while_stops_at_eof() -> void:
	var source := "@@@"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume_while(Type.ATSIGN)

	assert_eq(sut._position, 3)


func test_consume_until_stops_if_next_is_match() -> void:
	var source := "@hey @@b c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume_until(Type.ATSIGN)

	assert_eq(sut._position, 0)


func test_consume_until_stops_at_match() -> void:
	var source := "@@@b c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume_until(Type.IDENTIFIER)

	assert_eq(sut._position, 3)


func test_consume_until_stops_at_eof_if_no_match() -> void:
	var source := "@@@b c"
	var tokens := lexer.tokenize(source)
	sut._tokens = tokens

	sut.consume_until(Type.TEXT)

	assert_eq(sut._position, 5)


func test_annotation() -> void:
	var source := "@rng"
	var tokens := lexer.tokenize(source)
	var branch := sut.parse(tokens)

	assert_is(branch.children[0], AST.Annotation)

	var annotation: AST.Annotation = branch.children[0]
	assert_eq(annotation.name, tokens[1].value)
	assert_eq(annotation.line, tokens[1].line)
	assert_eq(annotation.column, tokens[1].column)


func test_multiple_annotation() -> void:
	var source := "@rng\n@rng\n@rng"
	var tokens := lexer.tokenize(source)
	var branch := sut.parse(tokens)

	for child in branch.children:
		assert_is(child, AST.Annotation)


func test_annotation_unknown_identifier_appends_error() -> void:
	var source := "@hey"
	var tokens := lexer.tokenize(source)
	var branch := sut.parse(tokens)

	assert_is(branch.children[0], AST.Error)


func test_annotation_next_is_not_eol_appends_error() -> void:
	var source := "@rng whattup"
	var tokens := lexer.tokenize(source)
	var branch := sut.parse(tokens)

	assert_is(branch.children[1], AST.Error)


func test_annotation_only_appends_first_error_on_line() -> void:
	var source := "@seq hey whattup you\n@rng"
	var tokens := lexer.tokenize(source)
	var branch := sut.parse(tokens)

	var children := branch.children
	assert_eq(children.size(), 3)
	assert_is(children[0], AST.Annotation)

	assert_is(children[1], AST.Error)
	assert_eq(children[1].column, 5)

	assert_is(children[2], AST.Annotation)


func test_parse_condition() -> void:
	var source := "@prompt\n{hey}"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt: AST.Prompt = ast.children[0]
	assert_eq(prompt.children.size(), 1)

	var condition := prompt.children[0]
	assert_is(condition, AST.Condition)
	assert_eq(condition.name, tokens[4].value)
	assert_eq(condition.line, tokens[4].line)
	assert_eq(condition.column, tokens[4].column)


func test_parse_text_after_condition() -> void:
	var source := "@prompt\n{foo} hello world"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)

	assert_eq(ast.children.size(), 1)

	var prompt: AST.Prompt = ast.children[0]
	assert_eq(prompt.children.size(), 2)

	var text := prompt.children[1]
	assert_is(text, AST.StringLiteral)
	assert_eq(text.value, tokens[6].value)


func test_parse_text() -> void:
	var source := "@prompt\nhello world"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt: AST.Prompt = ast.children[0]
	assert_eq(prompt.children.size(), 1)

	var text := prompt.children[0]
	assert_is(text, AST.StringLiteral)
	assert_eq(text.value, tokens[3].value)
	assert_eq(text.line, tokens[3].line)
	assert_eq(text.column, tokens[3].column)


func test_parse_action() -> void:
	var source := "@prompt\nhello world{foo}"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt: AST.Prompt = ast.children[0]
	assert_eq(prompt.children.size(), 2)

	var action := prompt.children[1]
	assert_is(action, AST.Action)
	assert_eq(action.name, tokens[5].value)
	assert_eq(action.line, tokens[5].line)
	assert_eq(action.column, tokens[5].column)


func test_condition_with_value() -> void:
	var source := "@prompt\n{foo 3}"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt: AST.Prompt = ast.children[0]
	assert_eq(prompt.children.size(), 1)

	var condition := prompt.children[0]
	assert_eq(condition.value.value, int(tokens[5].value))
	assert_eq(condition.value.line, int(tokens[5].line))
	assert_eq(condition.value.column, int(tokens[5].column))


func test_action_with_value() -> void:
	var source := "@prompt\nhello world{foo 3}"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt: AST.Prompt = ast.children[0]
	assert_eq(prompt.children.size(), 2)

	var action := prompt.children[1]
	assert_eq(action.value.value, int(tokens[6].value))
	assert_eq(action.value.line, int(tokens[6].line))
	assert_eq(action.value.column, int(tokens[6].column))


func test_full_prompt_with_condition_and_action() -> void:
	var source := "@prompt\n{foo} hello world {bar}"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt: AST.Prompt = ast.children[0]
	assert_eq(prompt.children.size(), 3)

	assert_is(prompt.children[0], AST.Condition)
	assert_is(prompt.children[1], AST.StringLiteral)
	assert_is(prompt.children[2], AST.Action)


func test_multiple_conditions() -> void:
	var source := "@prompt\n{foo 3 bar baz}"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt: AST.Prompt = ast.children[0]
	assert_eq(prompt.children.size(), 3)

	assert_eq(prompt.children[0].name, tokens[4].value)
	assert_eq(prompt.children[1].name, tokens[6].value)
	assert_eq(prompt.children[2].name, tokens[7].value)


func test_multiple_actions() -> void:
	var source := "@prompt\nhello world{foo bar 3 baz 2}"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt: AST.Prompt = ast.children[0]
	assert_eq(prompt.children.size(), 4)

	assert_eq(prompt.children[1].name, tokens[5].value)
	assert_eq(prompt.children[2].name, tokens[6].value)
	assert_eq(prompt.children[3].name, tokens[8].value)


func test_next_line_creates_new_prompt() -> void:
	var source := "@prompt\nhello world\nhello again"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 2)

	assert_eq(ast.children[0].children[0].value, tokens[3].value)
	assert_eq(ast.children[1].children[0].value, tokens[5].value)


func test_multiple_condition_groups_appends_error() -> void:
	var source := "@prompt\n{foo}{bar}hello world"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt := ast.children[0]
	assert_eq(prompt.children.size(), 2)

	assert_is(prompt.children[1], AST.Error)


func test_multiple_text_appends_error() -> void:
	var source := "@prompt\n{foo}hello world{bar}hello again"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt: AST.Line = ast.children[0]
	assert_eq(prompt.children.size(), 4)

	assert_is(prompt.children[3], AST.Error)


func test_multiple_action_groups_appends_error() -> void:
	var source := "@prompt\nhello world {foo}{bar}"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	var prompt := ast.children[0]
	assert_eq(prompt.children.size(), 3)

	assert_is(prompt.children[2], AST.Error)


func test_header_with_eol_is_valid() -> void:
	var source := "@prompt\n"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)

	assert_eq(ast.children.size(), 0)

	source = "@response\n"
	tokens = lexer.tokenize(source)

	ast = sut.parse(tokens)

	assert_eq(ast.children.size(), 0)


func test_header_without_eol_appends_error() -> void:
	var source := "@prompt"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	assert_is(ast.children[0], AST.Error)

	source = "@response"
	tokens = lexer.tokenize(source)

	ast = sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	assert_is(ast.children[0], AST.Error)


func test_tokens_after_header_annotation_appends_error() -> void:
	var source := "@prompt heythere you fool"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	assert_is(ast.children[0], AST.Error)

	source = "@response heythere you fool"
	tokens = lexer.tokenize(source)

	ast = sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	assert_is(ast.children[0], AST.Error)


func test_prompt_and_response() -> void:
	var source := "@prompt\nhello\n@response\nworld"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 2)

	for child in ast.children:
		assert_false(child is AST.Error)


func test_annotation_and_prompt() -> void:
	var source := "@rng\n@prompt\nhello"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 2)

	assert_is(ast.children[0], AST.Annotation)
	assert_is(ast.children[1], AST.Prompt)


func test_annotation_and_response() -> void:
	var source := "@rng\n@response\nhello"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 2)

	assert_is(ast.children[0], AST.Annotation)
	assert_is(ast.children[1], AST.Response)


func test_full_example() -> void:
	var source := "@rng\n@prompt\nhello\n@response\nworld"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 3)

	assert_is(ast.children[0], AST.Annotation)
	assert_is(ast.children[1], AST.Prompt)
	assert_is(ast.children[2], AST.Response)


func test_prompt_after_response_appends_error() -> void:
	var source := "@response\nhello\n@prompt\nworld"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 3)

	var invalid_response: AST.Response = ast.children[1]
	assert_eq(invalid_response.children.size(), 1)

	assert_is(invalid_response.children[0], AST.Error)


func test_extra_lines_before_annotations_is_valid() -> void:
	var source := "\n\n\n@rng"
	var tokens := lexer.tokenize(source)
	var ast := sut.parse(tokens)

	for child in ast.children:
		assert_false(child is AST.Error)


func test_extra_lines_between_annotations_appends_error() -> void:
	var source := "@rng\n\n@unique"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 2)

	assert_is(ast.children[1], AST.Error)


func test_extra_lines_between_annotations_and_prompts_is_valid() -> void:
	var source := "@rng\n\n@prompt\nhello world"
	var tokens := lexer.tokenize(source)
	var ast := sut.parse(tokens)

	for child in ast.children:
		assert_false(child is AST.Error)


func test_extra_lines_between_prompt_header_and_body_is_invalid() -> void:
	var source := "@prompt\n\nhello world"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 1)

	assert_is(ast.children[0], AST.Error)


func test_extra_lines_between_prompt_body_is_invalid() -> void:
	var source := "@prompt\nhello world\n\nhello again"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 2)

	assert_is(ast.children[1], AST.Error)


func test_extra_lines_between_prompt_and_response_header_is_valid() -> void:
	var source := "@prompt\nhello world\n\n@response\nhello again"
	var tokens := lexer.tokenize(source)
	var ast := sut.parse(tokens)

	for child in ast.children:
		assert_false(child is AST.Error)


func test_extra_lines_between_response_header_and_body_is_invalid() -> void:
	var source := "@response\n\nhello world"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(),  1)

	assert_is(ast.children[0], AST.Error)


func test_extra_lines_between_response_body_is_invalid() -> void:
	var source := "@response\nhello world\n\nhello again"
	var tokens := lexer.tokenize(source)

	var ast := sut.parse(tokens)
	assert_eq(ast.children.size(), 2)

	assert_is(ast.children[1], AST.Error)


func test_extra_lines_at_end_of_file_is_valid() -> void:
	var source := "@response\nhello\n\n\n"
	var tokens := lexer.tokenize(source)
	var ast := sut.parse(tokens)

	for child in ast.children:
		assert_false(child is AST.Error)


func test_empty_is_valid() -> void:
	var source := ""
	var tokens := lexer.tokenize(source)
	var ast := sut.parse(tokens)

	assert_eq(ast.children.size(), 0)
