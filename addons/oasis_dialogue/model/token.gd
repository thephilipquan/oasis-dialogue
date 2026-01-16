extends RefCounted

enum Type {
	INIT = 0,

	ATSIGN,
	CURLY_START,
	CURLY_END,
	EOF,
	EOL,
	ILLEGAL,

	NUMBER,
	TEXT,
	IDENTIFIER,

	PROMPT,
	RESPONSE,
}

const reserved_keywords: Dictionary[String, Type] = {
	"prompt": Type.PROMPT,
	"response": Type.RESPONSE,
}


var type := Type.INIT
var value := ""
var line := 0
var column := 0


@warning_ignore("shadowed_variable")
static func type_to_string(type: Type) -> String:
	var type_text := ""

	for key: String in Type.keys():
		if type == Type[key]:
			type_text = key
			break
	return type_text.to_lower()


static func types_to_string(types: Array) -> String:
	return " or ".join(types.map(func(t: Type) -> String: return type_to_string(t)))


@warning_ignore("shadowed_variable")
func _init(type: Type, value: String, line: int, column: int) -> void:
	self.type = type
	self.value = value
	self.line = line
	self.column = column


func _to_string() -> String:
	const include_value: Array[Type] = [
		Type.IDENTIFIER,
		Type.NUMBER,
		Type.TEXT,
	]
	var result := type_to_string(type)
	if type in include_value:
		result += " (" + value + ")"
	return result
