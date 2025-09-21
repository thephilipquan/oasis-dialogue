extends RefCounted

const _Token := preload("res://addons/oasis_dialogue/model/token.gd")

const _Type := _Token.Type

var _patterns: Array[Pattern] = []

var _tokens: Array[_Token] = []
var _source := ""
var _position := 0
var _line := 0
var _column := 0

var _can_be_text := true

func _init() -> void:
	_patterns = [
		Pattern.new(RegEx.create_from_string("@"), atsign_handler),
		Pattern.new(RegEx.create_from_string("\n"), newline_handler),
		Pattern.new(RegEx.create_from_string("{"), curly_start_handler),
		Pattern.new(RegEx.create_from_string("}"), curly_end_handler),
		Pattern.new(RegEx.create_from_string(r"[ ]+"), skip_handler),
		Pattern.new(RegEx.create_from_string("[a-zA-Z_]+"), match_handler.bind(_Type.IDENTIFIER)),
		Pattern.new(RegEx.create_from_string("[0-9]+"), match_handler.bind(_Type.NUMBER)),
		Pattern.new(RegEx.create_from_string("[^{\n]+"), text_handler),
	]


func atsign_handler(m: RegExMatch) -> bool:
	_can_be_text = false
	return default_handler(m, _Type.ATSIGN, "@")


func default_handler(m: RegExMatch, type: _Type, value: String) -> bool:
	add_token(type, value)
	move_position(value.length())
	return true


func newline_handler(m: RegExMatch) -> bool:
	default_handler(m, _Type.EOL, "\n")
	_line += 1
	_column = 0
	_can_be_text = true
	return true


func skip_handler(m: RegExMatch) -> bool:
	var length := m.get_end() - m.get_start()
	move_position(length)
	return true


func curly_start_handler(m: RegExMatch) -> bool:
	_can_be_text = false
	return default_handler(m, _Type.CURLY_START, "{")


func curly_end_handler(m: RegExMatch) -> bool:
	_can_be_text = true
	return default_handler(m, _Type.CURLY_END, "}")


func match_handler(m: RegExMatch, type: _Type) -> bool:
	if _can_be_text:
		return false
	var value := m.get_string()
	var actual_type := type
	if value in _Token.reserved_keywords:
		actual_type = _Token.reserved_keywords[value]
	add_token(actual_type, value)
	move_position(value.length())
	return true


func text_handler(m: RegExMatch) -> bool:
	var value := m.get_string()
	value = value.rstrip(" ")
	var type := _Type.TEXT
	add_token(type, value)
	move_position(value.length())
	return true


func add_token(type: _Type, value: String) -> void:
	var token := _Token.new(type, value, _line, _column)
	_tokens.push_back(token)


func move_position(steps: int) -> void:
	_position += steps
	_column += steps


func remainder() -> String:
	return _source.substr(_position)


func tokenize(source: String) -> Array[_Token]:
	_tokens = []
	_source = source
	_position  = 0
	_line  = 0
	_column  = 0
	_can_be_text = true

	while _position < _source.length():
		var matched := false
		var remaining := remainder()

		for pattern in _patterns:
			var m := pattern.regex.search(remaining)
			if m and m.get_start() == 0:
				matched = pattern.handler.call(m)
			if matched:
				break

		if not matched:
			push_warning("ERROR: nothing matched: (%s)" % remaining)
			move_position(1)

	add_token(_Type.EOF, "EOF")
	return _tokens


class Pattern:
	extends RefCounted

	var regex: RegEx = null
	var handler := Callable()


	func _init(regex: RegEx, handler: Callable) -> void:
		self.regex = regex
		self.handler = handler
