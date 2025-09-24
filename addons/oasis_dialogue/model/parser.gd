extends RefCounted

const _AST := preload("res://addons/oasis_dialogue/model/ast.gd")
const _Token := preload("res://addons/oasis_dialogue/model/token.gd")
const _ParseError := preload("res://addons/oasis_dialogue/model/parse_error.gd")

const _Type := _Token.Type

var _tokens: Array[_Token] = []
var _position := 0
var _errors: Array[_ParseError] = []
var _root: _AST.Branch = null


func get_errors() -> Array[_ParseError]:
	return _errors


func peek(offset := 0) -> _Token:
	var next: _Token = null
	var index := _position + offset
	if index < _tokens.size():
		next = _tokens[index]
	return next


func peek_type(offset := 0) -> _Type:
	var next := _Type.INIT
	var index := _position + offset
	if index < _tokens.size():
		next = _tokens[index].type
	return next


func peek_expected_type(expected_type: _Type) -> bool:
	var next := peek_type()
	if next != expected_type:
		add_error(_Token.type_to_string(expected_type))
		return false
	return true


func peek_expected_types(expected_types: Array[_Type]) -> bool:
	var next := peek_type()
	if not next in expected_types:
		add_error(_Token.types_to_string(expected_types))
		return false
	return true


func add_error(expected_type: String) -> void:
	var next := peek()

	# These _tokens are only helpful for parsing and not when giving warnings.
	const ignore_previous: Array[_Type] = [
		_Type.EOL,
		_Type.ATSIGN,
	]
	var previous: _Token = null
	var previous_i := _position - 1
	while previous_i > 0 and _tokens[previous_i].type in ignore_previous:
		previous_i -= 1
	if previous_i >= 0 and not _tokens[previous_i].type in ignore_previous:
		previous = _tokens[previous_i]

	var message := "expected %s" % expected_type
	if previous:
		message += " after previous %s," % previous
	message += " found %s instead" %  _Token.type_to_string(next.type)
	var error := _ParseError.new(message, next.line, next.column)

	if _errors and error.line == _errors[-1].line:
		_errors[-1] = error
	else:
		_errors.push_back(error)


func consume(count := 1) -> _Token:
	var next := peek()
	_position += count
	return next


func consume_expected(expected_type: _Type) -> _Token:
	var next := peek()
	if next.type != expected_type:
		add_error(_Token.type_to_string(expected_type))
		return null
	_position += 1
	return next


func consume_while(type: _Type) -> void:
	var next := peek()
	while next.type == type:
		_position += 1
		next = peek()


func parse(_tokens: Array[_Token]) -> _AST.Branch:
	self._tokens = _tokens
	_root = null
	_position = 0
	_errors = []

	consume_while(_Type.EOL)
	var annotations := _parse_annotations()
	consume_while(_Type.EOL)
	var prompts := _parse_prompts()
	consume_while(_Type.EOL)
	var responses :=_parse_responses()
	consume_while(_Type.EOL)
	consume_expected(_Type.EOF)

	_root = _AST.Branch.new(-1, annotations, prompts, responses)
	return _root


func _parse_annotations() -> Array[_AST.Annotation]:
	const expected: Array[_Type] = [
		_Type.ID,
		_Type.SEQ,
		_Type.RNG,
		_Type.UNIQUE,
	]

	var annotations: Array[_AST.Annotation] = []
	while peek_type() == _Type.ATSIGN and peek_type(1) in expected:
		consume_expected(_Type.ATSIGN)
		var annotation := _parse_annotation()
		annotations.push_back(annotation)

		# When annotations are on the same line.
		# eg: "@rng@unique". We don't want this.
		if not peek_expected_type(_Type.EOL):
			break
		consume_expected(_Type.EOL)
	return annotations


func _parse_annotation() -> _AST.Annotation:
	var token := consume()
	var value: _AST.ASTNode = null
	if token.type == _Type.ID:
		peek_expected_type(_Type.NUMBER)
		value = _parse_number_literal()
	var annotation := _AST.Annotation.new(token.value, value)
	return annotation


func _parse_prompts() -> Array[_AST.Prompt]:
	if not (peek_type() == _Type.ATSIGN and peek_type(1) == _Type.PROMPT):
		return []
	consume(2)
	consume_expected(_Type.EOL)
	var expected: Array[_Type] = [
		_Type.CURLY_START,
		_Type.TEXT,
	]
	if not peek_expected_types(expected):
		return []
	var prompts: Array[_AST.Prompt] = []
	while peek_type() in expected:
		var prompt := _parse_prompt()
		prompts.push_back(prompt)
		if peek_type() != _Type.EOF:
			consume_expected(_Type.EOL)
	return prompts


func _parse_prompt() -> _AST.Prompt:
	var conditions := _parse_conditions()
	peek_expected_type(_Type.TEXT)
	var text := _parse_string_literal()
	var actions := _parse_actions()
	var prompt := _AST.Prompt.new(conditions, text, actions)
	return prompt


func _parse_responses() -> Array[_AST.Response]:
	if not (peek_type() == _Type.ATSIGN and peek_type(1) == _Type.RESPONSE):
		return []
	consume(2)
	consume_expected(_Type.EOL)
	var expected: Array[_Type] = [
		_Type.CURLY_START,
		_Type.TEXT,
	]
	if not peek_expected_types(expected):
		return []
	var responses: Array[_AST.Response] = []
	while peek_type() in expected:
		var response := _parse_response()
		responses.push_back(response)
		if peek_type() != _Type.EOF:
			consume_expected(_Type.EOL)
	return responses


func _parse_response() -> _AST.Response:
	var conditions := _parse_conditions()
	peek_expected_type(_Type.TEXT)
	var text := _parse_string_literal()
	var actions := _parse_actions()
	var response := _AST.Response.new(conditions, text, actions)
	return response


func _parse_conditions() -> Array[_AST.Condition]:
	if peek_type() != _Type.CURLY_START:
		return []
	consume()
	var conditions: Array[_AST.Condition] = []
	while peek_type() == _Type.IDENTIFIER:
		var condition := _parse_condition()
		conditions.push_back(condition)
	if not conditions:
		add_error(_Token.type_to_string(_Type.IDENTIFIER))
	consume_expected(_Type.CURLY_END)
	return conditions


func _parse_condition() -> _AST.Condition:
	var name := consume_expected(_Type.IDENTIFIER).value
	var value := _parse_number_literal()
	var condition := _AST.Condition.new(name, value)
	return condition


func _parse_actions() -> Array[_AST.Action]:
	if peek_type() != _Type.CURLY_START:
		return []
	consume()
	var actions: Array[_AST.Action] = []
	while peek_type() == _Type.IDENTIFIER:
		var action := _parse_action()
		actions.push_back(action)
	if not actions:
		add_error(_Token.type_to_string(_Type.IDENTIFIER))
	consume_expected(_Type.CURLY_END)
	return actions


func _parse_action() -> _AST.Action:
	var name := consume_expected(_Type.IDENTIFIER).value
	var value := _parse_number_literal()
	var action := _AST.Action.new(name, value)
	return action


func _parse_string_literal() -> _AST.StringLiteral:
	if peek_type() != _Type.TEXT:
		return null
	var value := consume().value
	var string_literal := _AST.StringLiteral.new(value)
	return string_literal


func _parse_number_literal() -> _AST.NumberLiteral:
	if peek_type() != _Type.NUMBER:
		return null
	var value := int(consume().value)
	var number_literal := _AST.NumberLiteral.new(value)
	return number_literal
