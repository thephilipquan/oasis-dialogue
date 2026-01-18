extends RefCounted

const _Token := preload("res://addons/oasis_dialogue/definitions/model/token.gd")

const _Type := _Token.Type

var _source := ""
var _i := -1
var _line := -1
var _column := -1
var _tokens: Array[_Token] = []
var _state := Callable()


func tokenize(source: String) -> Array[_Token]:
	_source = source
	_i = 0
	_line = 0
	_column = 0
	_tokens = []
	_state = _base

	while _i < source.length():
		_state.call()

	_add_token(_Type.EOF)
	return _tokens


func _base() -> void:
	if _source[_i] == " ":
		_move(1)

	elif _source[_i] == "\n":
		_add_token(_Type.EOL)
		_move_line()

	elif _source[_i] == "@":
		_add_token(_Type.ATSIGN)
		_move(1)
		_state = _identifier

	elif _is_valid_identifier_character(_source[_i]):
		_state = _identifier

	elif _source[_i] == ":":
		_add_token(_Type.COLON)

		var length := 1
		if _i + 1 < _source.length() and _source[_i + 1] == " ":
			length = 2
		_move(length)

		_state = _text

	else:
		_add_token(_Type.ILLEGAL, _source[_i])
		_move(1)


func _is_valid_identifier_character(s: String) -> bool:
	return (
			s == "_"
			or s == "-"
			or (s >= "a" and s <= "z")
	)


func _identifier() -> void:
	var start := _i
	var end := _i
	while end < _source.length() and _is_valid_identifier_character(_source[end]):
		end += 1

	if end > start:
		var value := _source.substr(start, end - start)
		_add_token(_Type.IDENTIFIER, value)
		_move(value.length())

	_state = _base


func _text() -> void:
	var start := _i
	var end := _i
	while end < _source.length() and _source[end] != "\n":
		end += 1

	if end > start:
		var value := _source.substr(start, end - start)
		_add_token(_Type.TEXT, value)
		_move(value.length())

	_state = _base


func _add_token(type: _Type, value := "") -> void:
	var token := _Token.new(type, value, _line, _column)
	_tokens.push_back(token)


func _move(step: int) -> void:
	_i += step
	_column += step


func _move_line() -> void:
	_i += 1
	_line += 1
	_column = 0
