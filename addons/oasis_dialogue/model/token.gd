extends RefCounted

enum Type {
	INIT = -1,

	ATSIGN,
	IDENTIFIER,
	NUMBER,

	CURLY_START,
	CURLY_END,

	TEXT,
	EOF,
	EOL,

	# Keywords.
	ID,
	SEQ,
	RNG,
	UNIQUE,
	PROMPT,
	RESPONSE,
}

const reserved_keywords: Dictionary[String, Type] = {
	"id": Type.ID,
	"seq": Type.SEQ,
	"rng": Type.RNG,
	"unique": Type.UNIQUE,
	"prompt": Type.PROMPT,
	"response": Type.RESPONSE,
}


static func type_to_string(type: Type) -> String:
	var type_string = ""
	for t in Type.keys():
		if type == Type[t]:
			type_string = t
			break
	return type_string


static func types_to_string(types: Array[Type]) -> String:
	return " or ".join(types.map(func(t: Type): return type_to_string(t)))


var type := Type.INIT
var value := ""
var line := 0
var column := 0


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

