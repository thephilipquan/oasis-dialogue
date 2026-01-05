@tool
extends Label

var _ids: Array[int] = []
var _messages: Array[String] = []


func queue(id: int, message: String) -> void:
	_ids.push_back(id)
	_messages.push_back(message)
	_update()


func resolve(id: int) -> void:
	var i := _ids.find(id)

	if i == -1:
		return

	_ids.pop_at(i)
	_messages.pop_at(i)

	_update()


func _update() -> void:
	if _ids:
		text = _messages[0]
		show()
	else:
		hide()
