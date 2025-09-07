extends HBoxContainer

const _CodeValue := preload("res://addons/oasis_dialogue/dialogue_unit/code_value.gd")
const _CodeValueScene := preload("res://addons/oasis_dialogue/dialogue_unit/code_value.tscn")

signal changed

@onready
var _conditions: VBoxContainer = %Conditions
@onready
var _actions: VBoxContainer = %Actions
@onready
var _add_condition: Button = %AddCondition
@onready
var _add_action: Button = %AddAction
@onready
var _text: TextEdit = %Text


func set_text(text: String) -> void:
	_text.text = text


func add_condition(text: String, value) -> void:
	if _conditions.get_child_count() == 1:
		var label: Label = _create_list_label("conditions")
		_conditions.add_child(label)
		_conditions.move_child(label, 0)
		_conditions.move_child(_add_condition, -1)
	var item := _create_item(text, value)
	_conditions.add_child(item)
	_conditions.move_child(item, -2)
	if _actions.get_child_count() == 1:
		size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	else:
		size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func add_action(text: String, value) -> void:
	if _actions.get_child_count() == 1:
		var label: Label = _create_list_label("actions")
		_actions.add_child(label)
		_actions.move_child(label, 0)
		_actions.move_child(_add_action, -1)
	var item := _create_item(text, value)
	_actions.add_child(item)
	_actions.move_child(item, -2)


func realign() -> void:
	var alignment := Control.SIZE_SHRINK_CENTER
	if _actions.get_child_count() == 1 and _conditions.get_child_count() == 1:
		alignment = Control.SIZE_SHRINK_CENTER
	elif _actions.get_child_count() == 1:
		alignment = Control.SIZE_SHRINK_END
	else:
		alignment = Control.SIZE_SHRINK_BEGIN
	size_flags_horizontal = alignment


func _on_add_condition_button_up() -> void:
	add_condition("", "")


func _on_add_action_button_up() -> void:
	add_action("", "")


func _create_list_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _create_item(text: String, value) -> _CodeValue:
	var item: _CodeValue = _CodeValueScene.instantiate()
	item.set_text(text)
	item.set_value(value)
	return item
