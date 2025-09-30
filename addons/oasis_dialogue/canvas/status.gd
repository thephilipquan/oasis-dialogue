extends Label

@export
var _invalid_color := Color()
@export
var _timer: Timer = null


func _ready() -> void:
	_timer.timeout.connect(_on_status_timer_timeout)


func info(message: String) -> void:
	text = message
	if has_theme_color_override("font_color"):
		remove_theme_color_override("font_color")
	_timer.start()


func err(message: String) -> void:
	text = message
	add_theme_color_override("font_color", _invalid_color)
	_timer.stop()


func clear_err() -> void:
	text = ""
	_timer.stop()


func _on_status_timer_timeout() -> void:
	text = ""

