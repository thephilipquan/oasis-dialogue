@tool
class_name DialogueNode
extends GraphNode

const _DialogueUnit := preload("res://addons/oasis_dialogue/dialogue_unit/dialogue_unit.gd")
const _DialogueUnitScene := preload("res://addons/oasis_dialogue/dialogue_unit/dialogue_unit.tscn")

@onready
var _id: Label = %Id
@onready
var _unique: CheckBox = %Unique
@onready
var _prompt: TextEdit = %PromptInput
@onready
var _response: TextEdit = %ResponseInput
@onready
var _prompts: VBoxContainer = $VBoxContainer/Prompts
@onready
var _responses: VBoxContainer = $VBoxContainer/Responses


func _ready() -> void:
	var title_hbox := get_titlebar_hbox()
	var label: Label = title_hbox.get_children()[0]
	title_hbox.remove_child(label)


func _unhandled_key_input(event: InputEvent) -> void:
	if selected and Input.is_key_pressed(KEY_X):
		queue_free()
		return


func _on_prompt_input_text_changed() -> void:
	var text := _prompt.text
	var column := _prompt.get_caret_column()

	if text.contains("\n"):
		text = text.replace("\n", "")
		_add_prompt_unit(text)
		_prompt.text = ""
		return

	const illegals: Array[String] = [
		"\t",
	]
	var correction_offset := 0
	for c in illegals:
		correction_offset += text.count(c)

	if not correction_offset:
		return
	column -= correction_offset

	for c in illegals:
		text = text.replace(c, "")

	_prompt.text = text
	_prompt.set_caret_column(column)


func _add_prompt_unit(text: String) -> void:
	var unit: _DialogueUnit = _DialogueUnitScene.instantiate()
	_prompts.add_child(unit)
	unit.set_text(text)
	unit.changed.connect(_realign_prompts)


func _realign_prompts() -> void:
	for child in _prompts:
		var cast := child as _DialogueUnit
		if not cast:
			continue
		cast.realign()
