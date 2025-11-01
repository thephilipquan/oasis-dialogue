extends RefCounted

const REGISTRY_KEY := "parser"

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Token := preload("res://addons/oasis_dialogue/model/token.gd")

const _Type := _Token.Type

var _stack: Array[_AST.Line] = []
var _tokens: Array[_Token] = []
var _position := 0


func push_parent(ast: _AST.AST) -> void:
	_stack.push_back(ast)


func pop_parent() -> void:
	_stack.pop_back()


func append_child(ast: _AST.AST) -> void:
	_stack[-1].add(ast)


func append_expected_error(expected: Variant, found: _Token) -> void:
	var message := "Expected "
	if expected is Array:
		message += _Token.types_to_string(expected)
	elif expected is _Type:
		message += _Token.type_to_string(expected)
	message += ", found %s instead" % _Token.type_to_string(found.type)

	var error := _AST.Error.new(message, found.line, found.column)
	append_child(error)


func at_eof(i := _position) -> bool:
	return i >= _tokens.size() - 1


func peek(offset := 0) -> _Token:
	var next: _Token = null
	var index := _position + offset
	if not at_eof(index):
		next = _tokens[index]
	return next


func peek_type(offset := 0) -> _Type:
	var type := _Type.INIT
	var next := peek(offset)
	if next:
		type = next.type
	return type


func peek_sequence(types: Array[_Type]) -> bool:
	var is_match := true
	for i in range(types.size()):
		is_match = peek_type(i) == types[i]
		if not is_match:
			break
	return is_match


func peek_expected(expected: Variant) -> _Token:
	var next := peek()
	if not next:
		var eof := _tokens[-1]
		append_expected_error(expected, eof)
	elif expected is _Type and next.type != expected:
		append_expected_error(expected, next)
		next = null
	elif expected is Array and not next.type in expected:
		append_expected_error(expected, next)
		next = null
	return next


func consume(count := 1) -> _Token:
	var next := peek(count - 1)
	if not next:
		return null

	_position += count
	return next


func consume_expected(expected_type: Variant) -> _Token:
	var next := peek_expected(expected_type)
	if next:
		_position += 1
	return next


func consume_to(type: _Type) -> void:
	while not at_eof():
		if peek_type() == type:
			_position += 1
			break
		_position += 1


func consume_while(type: _Type) -> void:
	while not at_eof() and peek_type() == type:
		_position += 1


func consume_until(type: _Type) -> void:
	if peek_type() == type:
		return
	while not at_eof():
		if peek_type(1) == type:
			_position += 1
			break
		_position += 1


func consume_eof() -> void:
	assert(_tokens[-1].type == _Type.EOF)
	if _position != _tokens.size() - 1:
		var next := _tokens[_position]
		append_child(_AST.Error.new(
				"Expected %s found %s instead" % [
					_Token.type_to_string(_Type.EOF),
					_Token.type_to_string(next.type),
				],
				next.line,
				next.column,
		))
		return
	_position += 1


func parse(tokens: Array[_Token]) -> _AST.Branch:
	_stack = [_AST.Branch.new()]
	_tokens = tokens
	_position = 0

	consume_while(_Type.EOL)
	_parse_annotations()
	consume_while(_Type.EOL)
	_parse_prompts()
	consume_while(_Type.EOL)
	_parse_responses()
	consume_while(_Type.EOL)
	consume_eof()

	var ast: _AST.Branch = _stack[0]
	return ast


func _parse_annotations() -> void:
	const expected: Array[_Type] = [
			_Type.SEQ,
			_Type.RNG,
			_Type.UNIQUE,
	]
	const prompt_sequence: Array[_Type] =  [_Type.ATSIGN, _Type.PROMPT]
	const response_sequence: Array[_Type] =  [_Type.ATSIGN, _Type.RESPONSE]
	while (
		not at_eof()
		and peek_type() == _Type.ATSIGN
		and not peek_sequence(prompt_sequence)
		and not peek_sequence(response_sequence)
	):
		consume()

		var token := peek_expected(expected)
		if token:
			consume()
			append_child(_AST.Annotation.new(
					token.value,
					token.line,
					token.column,
			))
		else:
			consume_until(_Type.EOL)
		if at_eof():
			return
		peek_expected(_Type.EOL)
		consume_to(_Type.EOL)


func _parse_prompts() -> void:
	if not peek_sequence([_Type.ATSIGN, _Type.PROMPT]):
		return
	consume(2)
	if peek_expected(_Type.EOL):
		consume()
	else:
		consume_to(_Type.EOL)

	const response: Array[_Type] = [_Type.ATSIGN, _Type.RESPONSE]
	while (
		not at_eof()
		and not peek_sequence(response)
		and not peek_type() == _Type.EOL
	):
		var prompt := _AST.Prompt.new()
		append_child(prompt)
		push_parent(prompt)
		_parse_line()

		if at_eof():
			break

		consume_expected(_Type.EOL)
		_stack.pop_back()


func _parse_responses() -> void:
	if not peek_sequence([_Type.ATSIGN, _Type.RESPONSE]):
		return
	consume(2)
	if peek_expected(_Type.EOL):
		consume()
	else:
		consume_to(_Type.EOL)

	while not at_eof() and not peek_type() == _Type.EOL:
		var response := _AST.Response.new()
		append_child(response)
		push_parent(response)
		_parse_line()

		if at_eof():
			break

		consume_expected(_Type.EOL)
		_stack.pop_back()


func _parse_line() -> void:
	const expected: Array[_Type] = [_Type.CURLY_START, _Type.TEXT]

	var seen_condition := false
	var seen_text := false
	var seen_action := false
	while not at_eof() and peek_type() != _Type.EOL:
		var next := peek_expected(expected)

		if not next:
			consume_until(_Type.EOL)
			break

		if next.type == _Type.TEXT:
			if not seen_text:
				seen_text = true
				_parse_text()
			else:
				append_child(_AST.Error.new(
						"Expected end of line, found text instead",
						next.line,
						next.column,
				))
				consume_to(_Type.EOL)
		elif not seen_text:
			if not seen_condition:
				seen_condition = true
				_parse_conditions()
			else:
				append_child(_AST.Error.new(
						"Expected text or actions, but found condition instead",
						next.line,
						next.column,
				))
				consume_to(_Type.EOL)
		else:
			if not seen_action:
				seen_action = true
				_parse_actions()
			else:
				append_child(_AST.Error.new(
						"Expected end of line, but found action instead",
						next.line,
						next.column,
				))
				consume_to(_Type.EOL)


func _parse_conditions() -> void:
	consume_expected(_Type.CURLY_START)
	while (
		not at_eof()
		and peek_type() == _Type.IDENTIFIER
	):
		var token := consume()

		var value: _AST.NumberLiteral = null
		if peek_type() == _Type.NUMBER:
			var number := consume()
			value = _AST.NumberLiteral.new(int(number.value), number.line, number.column)

		var condition := _AST.Condition.new(token.value, value, token.line, token.column)
		append_child(condition)

	consume_expected(_Type.CURLY_END)


func _parse_text() -> void:
	var token := consume_expected(_Type.TEXT)

	var text := _AST.StringLiteral.new(token.value, token.line, token.column)
	append_child(text)


func _parse_actions() -> void:
	consume_expected(_Type.CURLY_START)
	while (
		not at_eof()
		and peek_type() == _Type.IDENTIFIER
	):
		var token := consume()

		var value: _AST.NumberLiteral = null
		if peek_type() == _Type.NUMBER:
			var number := consume()
			value = _AST.NumberLiteral.new(int(number.value), number.line, number.column)

		var action := _AST.Action.new(token.value, value, token.line, token.column)
		append_child(action)

	consume_expected(_Type.CURLY_END)
