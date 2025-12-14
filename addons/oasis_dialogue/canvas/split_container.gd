@tool
extends SplitContainer

const REGISTRY_KEY := "split_container"

const _CharacterTree := preload("res://addons/oasis_dialogue/canvas/character_tree.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

@export_range(0.1, 1.0, 0.1)
var _duration := 0.3

var _get_longest_item := Callable()
var _get_current_item := Callable()

var _max_offset := -1


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	dragged.connect(_on_dragged)


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var character_tree: _CharacterTree = registry.at(_CharacterTree.REGISTRY_KEY)
	character_tree.changed.connect(update)

	init_get_longest_item(character_tree.get_longest_item)
	init_get_current_item(character_tree.get_selected_item)


func init_get_longest_item(callback: Callable) -> void:
	_get_longest_item = callback


func init_get_current_item(callback: Callable) -> void:
	_get_current_item = callback


func update() -> void:
	var font := get_theme_font("font_name", &"Tree")
	var font_size := get_theme_font_size("font_size", &"Tree")
	var left_margin := get_theme_constant("inner_item_margin_left", &"Tree")
	var longest_item: String = _get_longest_item.call()
	_max_offset = (
			font.get_string_size(longest_item, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			+ left_margin * 3
	)

	var current_item: String = _get_current_item.call()
	if split_offset > _max_offset:
		split_offset = _max_offset


func _on_dragged(offset: int) -> void:
	split_offset = mini(offset, _max_offset)
