extends SyntaxHighlighter

const Token := preload("res://addons/oasis_dialogue/model/token.gd")
const Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")

const Type := Token.Type

const _NORMAL := Color.WHITE
const _NUMBER := Color.YELLOW
const _KEYWORD := Color.MEDIUM_PURPLE
const _BRACKET := Color.SKY_BLUE
const _IDENTIFIER := Color.DARK_ORANGE

var lexer: Lexer = null


@warning_ignore("shadowed_variable")
func set_lexer(lexer: Lexer) -> void:
	self.lexer = lexer


func _get_line_syntax_highlighting(line_number: int) -> Dictionary:
	var text_edit := get_text_edit()
	var line := text_edit.get_line(line_number)

	var map := {}

	var tokens := lexer.tokenize(line)
	for token in tokens:
		var color := _NORMAL
		match token.type:
			Type.ATSIGN, Type.SEQ, Type.RNG, Type.UNIQUE, Type.PROMPT, Type.RESPONSE:
				color = _KEYWORD
			Type.IDENTIFIER:
				color = _IDENTIFIER
			Type.NUMBER:
				color = _NUMBER
			Type.CURLY_START, Type.CURLY_END:
				color = _BRACKET

		map[token.column] = {"color": color}
	return map
