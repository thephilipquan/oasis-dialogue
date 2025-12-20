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

	while _i < tokens.size():
		_state.call()

	return _program


func _parse_base() -> void:
	_declared = false

	if not _validate_base():
		_consume_to(_Type.EOL)
		return

	var next := _peek()
	match next.type:
		_Type.ATSIGN:
			_state = _parse_annotation
		_Type.IDENTIFIER:
			_state = _parse_identifier
		_Type.EOL, _Type.EOF:
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
				"Expected a declaration but found %s instead." % next.value,
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

	if not _declared:
		_push_new_declaration()
		_declared = true

	var token := _consume_to(_Type.IDENTIFIER)
	_append_to_declaration(_AST.Annotation.new(token.value, token.line, token.column))

	_validate_after_annotation()
	_consume_to(_Type.EOL)

	if _peek().type != _Type.ATSIGN:
		_state = _parse_identifier



func _validate_annotation() -> bool:
	assert(_peek().type == _Type.ATSIGN)

	var result := true
	var next := _peek(1)
	if not next:
		var atsign := _peek()
		_append_to_declaration(_AST.Error.new(
				"Missing name after the @. If there is no annotation for this item, remove the @." % next.value,
				atsign.line,
				atsign.column
		))
		result = false
	elif next.type != _Type.IDENTIFIER:
		_append_to_declaration(_AST.Error.new(
				"Expected the name of the annotation after @ but found %s instead." % next.value,
				next.line,
				next.column
		))
		result = false
	return result


func _validate_after_annotation() -> bool:
	var next := _peek()
	var result := true
	if next.type != _Type.EOL:
		_append_to_declaration(_AST.Error.new(
				"End the annotatation by creating a new line.",
				next.line,
				next.column
		))
		result = false
	return result


func _parse_identifier() -> void:
	if not _validate_identifier():
		_reset_to_base()
		return

	if not _declared:
		_push_new_declaration()
		_declared = true

	var token := _consume_to(_Type.IDENTIFIER)
	_append_to_declaration(_AST.Identifier.new(token.value, token.line, token.column))

	if not _validate_after_identifier():
		_reset_to_base()
		return

	_state = _parse_description


func _validate_identifier() -> bool:
	var result := true
	var next := _peek()
	if next.type != _Type.IDENTIFIER:
		_append_to_declaration(_AST.Error.new(
				"Expected an identifier but found %s instead." % next.value,
				next.line,
				next.column
		))
		result = false
	return result


func _validate_after_identifier() -> bool:
	var result := true
	var next := _peek()
	match next.type:
		_Type.EOL, _Type.EOF, _Type.COLON:
			pass
		_Type.IDENTIFIER:
			_append_to_declaration(_AST.Error.new(
				"Keep identifiers on separate lines.",
				next.line,
				next.column
			))
			result = false
		_:
			_append_to_declaration(_AST.Error.new(
				"Expected a description for the identifier or the end of the line but found %s instead." % next.value,
				next.line,
				next.column
			))
			result = false
	return result


func _parse_description() -> void:
	if not _peek().type == _Type.COLON:
		_state = _parse_base
		return

	if not _validate_description():
		_reset_to_base()
		return

	var token := _consume_to(_Type.TEXT)
	_append_to_declaration(_AST.Description.new(token.value, token.line, token.column))
	_consume_to(_Type.EOL)

	_state = _parse_base


func _validate_description() -> bool:
	assert(_peek().type == _Type.COLON)
	var result := true
	var next := _peek(1)
	if not next:
		var colon := _peek()
		_append_to_declaration(_AST.Error.new(
				"Missing description. If there is no description, remove the colon." % next.value,
				colon.line,
				colon.column
		))
		result = false
	elif next.type != _Type.TEXT:
		_append_to_declaration(_AST.Error.new(
				"Expected a description after the colon but found %s instead." % next.value,
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


func _consume(amount := 1) -> _Token:
	_i += amount
	var consumed: _Token = null
	if _i < _tokens.size():
		consumed = _tokens[_i]
	return consumed


func _consume_to(type: _Type) -> _Token:
	var past: _Token = null

	# Do not consume EOF.
	while _i < _tokens.size() - 1:
		_i += 1
		past = _peek(-1)
		if past.type == type:
			break
	return past


func _peek(offset := 0) -> _Token:
	var next_i := _i + offset
	var result: _Token = null
	if next_i < _tokens.size():
		result = _tokens[next_i]
	return result
