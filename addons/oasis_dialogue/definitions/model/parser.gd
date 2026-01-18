extends RefCounted

const _Token := preload("res://addons/oasis_dialogue/definitions/model/token.gd")
const _AST := preload("res://addons/oasis_dialogue/definitions/model/ast.gd")

const _Type := _Token.Type

var _program: _AST.Program = null
var _tokens: Array[_Token] = []
var _i := 0
var _state := Callable()
var _declared := false


func parse(tokens: Array[_Token]) -> _AST.Program:
	_program = _AST.Program.new()
	_tokens = tokens
	_i = 0
	_state = _parse_base
	_declared = false

	while _i < tokens.size():
		_state.call()

	return _program


func _parse_base() -> void:
	if not _validate_base():
		_consume_to(_Type.EOL)
		return

	var next := _peek()
	match next.type:
		_Type.ATSIGN:
			_consume()
			_state = _parse_annotation
		_Type.IDENTIFIER:
			_state = _parse_expected_identifier
		_Type.EOL, _Type.EOF:
			_declared = false
			_consume()


func _validate_base() -> bool:
	var result := true
	var next := _peek()
	const expected := [
			_Type.ATSIGN,
			_Type.IDENTIFIER,
			_Type.EOL,
			_Type.EOF,
	]
	if not next.type in expected:
		var error := _AST.Error.new(
				"Invalid start to definition. Expected an annotation or identifier.",
				next.line,
				next.column
		)
		_append_to_declaration(error)
		result = false
	return result


func _parse_annotation() -> void:
	if not _validate_annotation():
		_reset_to_base()
		return

	var next := _peek()
	const exit := [
			_Type.EOL,
			_Type.EOF,
	]
	if next.type in exit:
		_state = _parse_base
		return

	if not _declared:
		_push_new_declaration()
		_declared = true

	_consume()
	_append_to_declaration(_AST.Annotation.new(
			next.value,
			next.line,
			next.column,
	))

	_state = _parse_after_annotation


func _validate_annotation() -> bool:
	var result := true
	var next := _peek()
	if next.type != _Type.IDENTIFIER:
		var message := ""
		match next.type:
			_Type.EOF:
				message = "Incomplete annotation."
			_Type.EOL:
				message = "Incomplete annotation. If there is no annotation for this item, remove the '@'."
			_:
				message = "Invalid annotation. '@' must be followed by a valid identifier."
		_append_to_declaration(_AST.Error.new(
				message,
				next.line,
				next.column,
		))
		result = false
	return result


func _parse_after_annotation() -> void:
	var next := _peek()
	if next.type != _Type.EOL:
		_append_to_declaration(_AST.Error.new(
				"Annotations must be on their own line.",
				next.line,
				next.column
		))
	_consume_to(_Type.EOL)
	_state = _parse_base


func _parse_expected_identifier() -> void:
	var next := _peek()
	assert(next.type == _Type.IDENTIFIER)

	if not _declared:
		_push_new_declaration()
		_declared = true

	_consume()
	_append_to_declaration(_AST.Identifier.new(next.value, next.line, next.column))

	_state = _parse_after_identifier


func _validate_identifier() -> bool:
	var result := true
	var next := _peek()
	if next.type != _Type.IDENTIFIER:
		_append_to_declaration(_AST.Error.new(
				"Expected an identifier, but found %s instead." % next.value.c_escape(),
				next.line,
				next.column
		))
		result = false
	return result


func _parse_after_identifier() -> void:
	if not _validate_after_identifier():
		_reset_to_base()
		return

	const exit := [
			_Type.EOL,
			_Type.EOF,
	]
	var next := _peek()
	if next.type in exit:
		_state = _parse_base
		return

	_consume()
	_state = _parse_description


func _validate_after_identifier() -> bool:
	var result := true
	const expected := [
			_Type.COLON,
			_Type.EOL,
			_Type.EOF,
	]
	var next := _peek()
	if not next.type in expected:
		var message := ""
		match next.type:
			_Type.IDENTIFIER:
				message = "Multiple identifiers on the same line. Place each identifier on a separate line."
			_:
				message = "Unexpected '%s' after identifier. Expected ':' with a description or end of the line." % next.value.c_escape()
		_append_to_declaration(_AST.Error.new(
				message,
				next.line,
				next.column
		))
		result = false
	return result


func _parse_description() -> void:
	if not _validate_description():
		_reset_to_base()
		return

	var token := _consume()
	_append_to_declaration(_AST.Description.new(
			token.value,
			token.line,
			token.column,
	))
	_state = _parse_after_description


func _parse_after_description() -> void:
	var next := _peek()
	const expected := [
			_Type.EOL,
			_Type.EOF,
	]
	if not next.type in expected:
		_append_to_declaration(_AST.Error.new(
				"Expected end of line. Remove %s or move it to the next line." % next.value.c_escape(),
				next.line,
				next.column
		))
	_consume_to(_Type.EOL)
	_state = _parse_base


func _validate_description() -> bool:
	var result := true
	var next := _peek()
	if next.type != _Type.TEXT:
		_append_to_declaration(_AST.Error.new(
				"Missing description. If there is no description, remove the colon.",
				next.line,
				next.column
		))
		result = false
	return result


func _reset_to_base() -> void:
	_consume_to(_Type.EOL)
	_state = _parse_base


func _push_new_declaration() -> void:
	_program.children.push_back(_AST.Declaration.new())


func _append_to_declaration(ast: _AST.AST) -> void:
	var a: Array = []
	if _declared:
		a = (_program.children[-1] as _AST.Declaration).children
	else:
		a = _program.children
	a.push_back(ast)


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


func _peek(offset := 0) -> _Token:
	var next_i := _i + offset
	var result: _Token = null
	if next_i < _tokens.size():
		result = _tokens[next_i]
	return result
