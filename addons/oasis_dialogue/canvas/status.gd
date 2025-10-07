@tool
extends Label

@export
var _invalid_color := Color()
@export
var _timer: Timer = null

var _get_active_character := Callable()


func _ready() -> void:
	_timer.timeout.connect(_on_status_timer_timeout)


func init_get_active_character(callback: Callable) -> void:
	_get_active_character = callback


func rename_character(to: String) -> void:
	info("Renamed %s to %s" % [_get_active_character.call() , to] )


func remove_character() -> void:
	info("Removed %s" % _get_active_character.call())


func add_character(name: String) -> void:
	info("Added %s" % name)


func save_file() -> void:
	info("Saved %s" % _get_active_character.call())


func save_project() -> void:
	info("Saved project")


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

