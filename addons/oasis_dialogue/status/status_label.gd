@tool
extends Label

@export
var _fade_in_duration := 0.3
@export
var _fade_out_duration := 0.6
@export_range(0, 48, 4)
var _y_distance := 24

@onready
var _timer: Timer = $Timer


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	var tween := get_tree().create_tween()
	tween.parallel().tween_property(self, "modulate", Color.WHITE, _fade_in_duration)


func init(message: String, duration: float) -> void:
	text = message
	if duration > 0 and is_inside_tree():
		_timer.wait_time = duration
		_timer.start()


func set_color(color: Color) -> void:
	add_theme_color_override("font_color", color)


func fade() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(0, _y_distance), _fade_out_duration).as_relative()
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, _fade_out_duration)
	tween.tween_callback(queue_free)


func _on_timer_timeout() -> void:
	fade()
