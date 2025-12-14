extends RefCounted

enum Type {
	INIT = -1,

	ATSIGN,
	COLON,

	IDENTIFIER,
	TEXT,

	EOL,
	EOF,

	ILLEGAL,
}

var type := Type.INIT
var value := ""
var line := -1
var column := -1


@warning_ignore("shadowed_variable")
func _init(type: Type, value: String, line: int, column: int) -> void:
	self.type = type
	self.value = value
	self.line = line
	self.column = column


func _to_string() -> String:
	var type_text := ""

	for key: String in Type.keys():
		if type == Type[key]:
			type_text = key
			break
	type_text = type_text.to_lower()

	const include_value: Array[Type] = [
			Type.IDENTIFIER,
			Type.TEXT,
	]
	var result := type_text
	if type in include_value:
		result += " (" + value + ")"
	return result
