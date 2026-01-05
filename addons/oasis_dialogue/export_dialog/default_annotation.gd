@tool
extends OptionButton

signal changed(text: String)


func _on_item_selected(index: int) -> void:
	var text := get_item_text(index)
	changed.emit(text)
