extends RefCounted

const REGISTRY_KEY := "lexer"

const _Token := preload("res://addons/oasis_dialogue/model/token.gd")

const _Type := _Token.Type

var _tokens: Array[_Token] = []
var _source := ""
var _i := 0
var _line := 0
var _column := 0
var _state := Callable()

var _text_is_identifier := false


func tokenize(source: String) -> Array[_Token]:
	count = 0
	_source = source
	_tokens = []
	_i  = 0
	_line  = 0
	_column  = 0
	_state = _base

	_text_is_identifier = false

	while _i < _source.length():
		_state.call()

	_add_token(_Type.EOF)
	return _tokens.duplicate()

var count := 0

func _base() -> void:
	count += 1
	if count > 10000:
		var x := 0
		x += 1

	var next := _source[_i]
	if next == " " or next == "\t":
		_move()
	elif next == "\n":
		_add_token(_Type.EOL)
		_move_line()
		_text_is_identifier = false
	elif next == "@":
		_add_token(_Type.ATSIGN, next)
		_move()
		_text_is_identifier = true
	elif next == "{":
		_add_token(_Type.CURLY_START, next)
		_move()
		_text_is_identifier = true
	elif next == "}":
		_add_token(_Type.CURLY_END, next)
		_move()
		_text_is_identifier = false
	elif _text_is_identifier and next.is_valid_int():
		_state = _number
	else:
		if _text_is_identifier:
			_state = _identifier
		else:
			_state = _text


func _identifier() -> void:
	var start := _i
	var end := _i
	while end < _source.length() and _is_valid_identifier_character(_source[end]):
		end += 1

	if start == end:
		_state = _illegal
		return

	var value := _source.substr(start, end - start)
	if value in _Token.reserved_keywords:
		_add_token(_Token.reserved_keywords[value], value)
	else:
		_add_token(_Type.IDENTIFIER, value)
	_move(value.length())

	_state = _base


func _illegal() -> void:
	var start := _i
	var end := _i
	while (
			end < _source.length()
			and not _is_valid_identifier_character(_source[end])
			and _source[end] != "\n"
	):
		end += 1

	if end > start:
		var value := _source.substr(start, end - start)
		_add_token(_Type.ILLEGAL, value)
		_move(value.length())
	else:
		push_warning("bug: thought there was an illegal sequence in %s at %d but found nothing." % [_source, _i])

	_state = _base


func _number() -> void:
	var start := _i
	var end := _i
	while end < _source.length() and _source[end].is_valid_int():
		end += 1

	if end > start:
		var value := _source.substr(start, end - start)
		_add_token(_Type.NUMBER, value)
		_move(value.length())

	_state = _base


func _text() -> void:
	var start := _i
	var end := _i
	while (
			end < _source.length()
			and _source[end] != "\n"
			and _source[end] != "{"
	):
		end += 1

	if end > start:
		var value := _source.substr(start, end - start).strip_edges()
		_add_token(_Type.TEXT, value)
		_move(value.length())

	_state = _base


func _add_token(type: _Type, value := "") -> void:
	var token := _Token.new(type, value, _line, _column)
	_tokens.push_back(token)


func _move(step := 1) -> void:
	_i += step
	_column += step


func _move_line() -> void:
	_i += 1
	_line += 1
	_column = 0


func _is_valid_identifier_character(s: String) -> bool:
	return (
		s == "_"
		or s == "-"
		or (("A" <= s and s <= "Z") or ("a" <= s and s <= "z"))
	)
