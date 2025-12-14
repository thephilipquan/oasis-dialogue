extends SyntaxHighlighter

const _Token := preload("res://addons/oasis_dialogue/definition_panel/model/token.gd")
const _Lexer := preload("res://addons/oasis_dialogue/definition_panel/model/lexer.gd")

const _Type := _Token.Type

var lexer: _Lexer = null
var identifier_color := Color()
var annotation_color := Color()
var description_color := Color()


func _get_line_syntax_highlighting(line_number: int) -> Dictionary:
	var text_edit := get_text_edit()
	var line := text_edit.get_line(line_number)

	var map := {}

	var tokens := lexer.tokenize(line)
	for i in tokens.size():
		var color := Color()
		match tokens[i].type:
			_Type.ATSIGN:
				color = annotation_color
			_Type.IDENTIFIER:
				var prev := i - 1
				if prev > -1 and tokens[prev].type == _Type.ATSIGN:
					color = annotation_color
				else:
					color = identifier_color
			_Type.ILLEGAL:
				color = Color.WHITE
			_Type.COLON, _Type.TEXT:
				color = description_color

		map[tokens[i].column] = {"color": color}

	return map
