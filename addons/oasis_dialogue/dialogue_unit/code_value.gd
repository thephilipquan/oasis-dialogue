extends HBoxContainer


func set_text(text: String) -> void:
	($OptionButton as OptionButton).text = text


func set_value(value) -> void:
	($LineEdit as LineEdit).text = value
