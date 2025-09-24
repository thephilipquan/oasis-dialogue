extends RefCounted

var message := ""
var line := -1
var column := -1

func _init(message: String, line: int, column: int) -> void:
	self.message = message
	self.line = line
	self.column = column

func _to_string() -> String:
	return "Error at (%d, %d): %s" % [line, column, message]
