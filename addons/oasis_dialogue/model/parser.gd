extends RefCounted

const REGISTRY_KEY := "parser"

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Token := preload("res://addons/oasis_dialogue/model/token.gd")

const _Type := _Token.Type

var _stack: Array[_AST.Line] = []
var _tokens: Array[_Token] = []
var _i := 0
var _state := Callable()

# A callback to create the section (prompt/response) that we're in.
#
# Because we're creating the AST via tree like state machine, as opposed to
# linear parsing, we create the actual prompt/response within _parse_line.
var _section_factory := Callable()


func parse(tokens: Array[_Token]) -> _AST.Branch:
	_stack = [_AST.Branch.new()]
	_tokens = tokens
	_i = 0
	_state = _parse_base

	while _i < _tokens.size():
		_state.call()

	var ast: _AST.Branch = _stack[0]
	return ast


func _parse_base() -> void:
	if not _validate_base():
		_consume_to(_Type.EOL)
		return

	var next := _peek()
	if next.type == _Type.ATSIGN:
		_state = _parse_annotation
	_consume()


func _validate_base() -> bool:
	var result := true
	var next := _peek()
	const expected := [
		_Type.ATSIGN,
		_Type.EOL,
		_Type.EOF,
	]
	if not next.type in expected:
		var message := ""
		match next.type:
			_Type.TEXT:
				message = "Text must be inside a @prompt or @response block. Add '@prompt' or '@response' on the line above."
			_Type.CURLY_START:
				message = "Conditions must be inside a @prompt or @response block. Add '@prompt' or '@response' on the line above."
			_:
				message = "Invalid start to line. Expected '@prompt', '@response', '@annotation', or blank line."
		_append_error_to_parent(message, next)
		result = false
	return result


func _parse_annotation() -> void:
	if not _validate_annotation():
		_consume_to(_Type.EOL)
		return

	var next := _peek()
	var next_state := Callable()
	match next.type:
		_Type.PROMPT:
			_section_factory = _AST.Prompt.new
			next_state = _parse_line
		_Type.RESPONSE:
			_section_factory = _AST.Response.new
			next_state = _parse_line
		_:
			var annotation := _AST.Annotation.new(
					next.value,
					next.line,
					next.column,
			)
			_append_to_parent(annotation)
			next_state = _parse_base
	_consume()

	_state = _parse_after_annotation.bind(next_state)


func _validate_annotation() -> bool:
	var result := true
	var next := _peek()
	const expected := [
			_Type.PROMPT,
			_Type.RESPONSE,
			_Type.IDENTIFIER,
	]
	if not next.type in expected:
		var message := ""
		match next.type:
			_Type.EOF, _Type.EOL:
				message = "Missing annotation. Add an annotation or header, or remove the '@'."
			_:
				message = "Invalid annotation. '@' must be followed by 'prompt', 'response', or a valid identifier."
		_append_error_to_parent(message, next)
		result = false
	return result


func _parse_after_annotation(next_state: Callable) -> void:
	var next := _peek()
	const expected := [
			_Type.EOL,
			_Type.EOF,
	]
	if not next.type in expected:
		var message := ""
		match next.type:
			_Type.ILLEGAL:
				message = "Illegal character(s) '%s'. Annotations can only consist of letters, '_', and '-'." % next.value.c_escape()
			_:
				message = "Annotations and headers must be on their own line."
		_append_error_to_parent(message, next)
	_consume_to(_Type.EOL)
	_state = next_state


func _parse_line() -> void:
	if not _validate_line():
		_consume_to(_Type.EOL)
		return

	var next := _peek()
	const exit := [
		_Type.ATSIGN,
		_Type.EOL,
		_Type.EOF,
	]
	if next.type in exit:
		_state = _parse_base
		return

	var parent: _AST.Line = _section_factory.call()
	_append_to_parent(parent)
	_push_parent(parent)

	match next.type:
		_Type.CURLY_START:
			_state = _parse_condition
			_consume()
		_Type.TEXT:
			_state = _parse_text


func _validate_line() -> bool:
	var result := true
	var next := _peek()
	const expected := [
		_Type.CURLY_START,
		_Type.TEXT,
		_Type.EOL,
		_Type.EOF,
		_Type.ATSIGN,
	]
	assert(next)
	if not next.type in expected:
		_append_error_to_parent(
				"Lines must start with a '{condition}' or plain text.",
				next,
		)
		result = false
	return result


func _parse_condition() -> void:
	if not _validate_code("condition"):
		_consume_to(_Type.EOL)
		return

	var next := _consume()
	if next.type == _Type.CURLY_END:
		_state = _parse_text
		return

	var condition := _AST.Condition.new(next.value, null, next.line, next.column)
	_append_to_parent(condition)

	next = _peek()
	if next.type == _Type.NUMBER:
		condition.value = _AST.NumberLiteral.new(int(next.value), next.line, next.column)
		_consume()


func _parse_action() -> void:
	if not _validate_code("action"):
		_consume_to(_Type.EOL)
		return

	var next := _consume()
	if next.type == _Type.CURLY_END:
		_state = _parse_after_action
		return

	var action := _AST.Action.new(next.value, null, next.line, next.column)
	_append_to_parent(action)

	next = _peek()
	if next.type == _Type.NUMBER:
		action.value = _AST.NumberLiteral.new(int(next.value), next.line, next.column)
		_consume()


# [param type] for messages.
func _validate_code(type: String) -> bool:
	var result := true
	const expected := [
			_Type.IDENTIFIER,
			_Type.CURLY_END,
	]
	var next := _peek()
	if not next.type in expected:
		var message := ""
		match next.type:
			_Type.NUMBER:
				message = "Missing keyword for '%s'." % next.value
			_Type.ILLEGAL:
				message = "Illegal character(s) '%s'. Or is this text and you're missing a '}'?" % next.value.c_escape()
			_Type.EOL, _Type.EOF:
				message = "Incomplete %s. Close the %s with a '}'" % [type, type]
		_append_error_to_parent(message, next)
		result = false
	return result


func _parse_text() -> void:
	if not _validate_text():
		_consume_to(_Type.EOL)
		_state = _parse_line
		return

	var next := _peek()
	var text := _AST.StringLiteral.new(
			next.value,
			next.line,
			next.column
	)
	_append_to_parent(text)
	_consume()

	_state = _parse_after_text


func _validate_text() -> bool:
	var result := true
	var next := _peek()
	if next.type != _Type.TEXT:
		var message := ""
		match next.type:
			_Type.CURLY_START:
				message = "Missing text before action. Add dialogue text before the '{'."
			_Type.EOL, _Type.EOF:
				message = "Missing text. Add dialogue text after the condition."
			_Type.ATSIGN:
				message = "Dialogue text cannot start with '@'. Open an issue on GitHub if you need this feature."
			_:
				message = "Missing text."
		_append_error_to_parent(message, next)
		result = false
	return result


func _parse_after_text() -> void:
	if not _validate_after_text():
		_consume_to(_Type.EOL)
		_state = _parse_line
		return

	var next := _peek()
	match next.type:
		_Type.CURLY_START:
			_state = _parse_action
		_Type.EOL, _Type.EOF:
			_pop_parent()
			_state = _parse_line
	_consume()


func _validate_after_text() -> bool:
	var result := true
	var expected := [
			_Type.CURLY_START,
			_Type.EOL,
			_Type.EOF,
	]
	var next := _peek()
	if not next.type in expected:
		var message := "Invalid content after dialogue text. Expected '{action}' or end of line."
		_append_error_to_parent(message, next)
		result = false
	return result


func _parse_after_action() -> void:
	var next := _peek()
	const expected := [
			_Type.EOL,
			_Type.EOF,
	]
	if not next.type in expected:
		_append_error_to_parent("There should be nothing after actions. Remove '%s'." % next.value.c_escape(), next)
	_consume_to(_Type.EOL)
	_pop_parent()
	_state = _parse_line


func _push_parent(parent: _AST.Line) -> void:
	_stack.push_back(parent)


func _pop_parent() -> void:
	_stack.pop_back()


func _append_error_to_parent(message: String, invalid_token: _Token) -> void:
	var error := _AST.Error.new(
			message,
			invalid_token.line,
			invalid_token.column
	)
	_append_to_parent(error)


func _append_to_parent(ast: _AST.AST) -> void:
	_stack[-1].children.push_back(ast)


func _peek(offset := 0) -> _Token:
	var next: _Token = null
	var index := _i + offset
	if index < _tokens.size():
		next = _tokens[index]
	return next


func _consume(count := 1) -> _Token:
	var next := _peek(count - 1)
	if not next:
		return null
	_i += count
	return next


func _consume_to(type: _Type) -> void:
	while _i < _tokens.size():
		if _peek().type == type:
			_i += 1
			break
		_i += 1
