extends RefCounted

var id := -1
var message := ""
var line := -1
var column := -1

func _init(id: int, message: String, line: int, column: int) -> void:
	self.id = id
	self.message = message
	self.line = line
	self.column = column

func _to_string() -> String:
	return "Error at (%d, %d): %s" % [line, column, message]
