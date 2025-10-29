extends Node

const REGISTRY_KEY := "call_to_action_handler"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _AddBranch := preload("res://addons/oasis_dialogue/canvas/add_branch_button.gd")
const _BranchCallToAction := preload("res://addons/oasis_dialogue/canvas/branch_call_to_action.gd")
const _AddCharacter := preload("res://addons/oasis_dialogue/canvas/add_character_button.gd")
const _CharacterCallToAction := preload("res://addons/oasis_dialogue/canvas/character_call_to_action.gd")
const _Graph := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")
const _RemoveCharacter := preload("res://addons/oasis_dialogue/canvas/remove_character_button.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _CharacterTree := preload("res://addons/oasis_dialogue/canvas/character_tree.gd")

@export_range(0.1, 2.0, 0.1)
var _pulse_duration := 0.7

var _get_character_count := Callable()
var _get_branch_count := Callable()

var _events: Dictionary[String, Event] = {}


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var character_tree: _CharacterTree = registry.at(_CharacterTree.REGISTRY_KEY)
	init_get_character_count(character_tree.get_item_count)

	var graph: _Graph = registry.at(_Graph.REGISTRY_KEY)
	init_get_branch_count(graph.get_branch_count)

	var add_character_button: _AddCharacter = registry.at(_AddCharacter.REGISTRY_KEY)
	var add_character_call_to_action: _CharacterCallToAction = registry.at(
			_CharacterCallToAction.REGISTRY_KEY
	)
	var event := Event.new()
	event.add_highlight(add_character_button)
	event.add_display(add_character_call_to_action)
	_events.add_character = event

	var project_manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	project_manager.project_loaded.connect(update_add_character_event, CONNECT_DEFERRED)
	var remove_character_button: _RemoveCharacter = registry.at(_RemoveCharacter.REGISTRY_KEY)
	remove_character_button.character_removed.connect(update_add_character_event, CONNECT_DEFERRED)
	add_character_button.character_added.connect(hide_event.bind(event).unbind(1))

	var add_branch_button: _AddBranch = registry.at(_AddBranch.REGISTRY_KEY)
	var create_branch_call_to_action: _BranchCallToAction = registry.at(
			_BranchCallToAction.REGISTRY_KEY
	)
	event = Event.new()
	event.add_highlight(add_branch_button)
	event.add_display(create_branch_call_to_action)
	_events.create_branch = event

	project_manager.character_loaded.connect(update_create_branch_event.unbind(1), CONNECT_DEFERRED)
	graph.branch_removed.connect(update_create_branch_event.unbind(1), CONNECT_DEFERRED)
	add_branch_button.branch_added.connect(hide_event.bind(event).unbind(1))
	remove_character_button.character_removed.connect(hide_event.bind(event))


func init_get_character_count(callback: Callable) -> void:
	_get_character_count = callback


func init_get_branch_count(callback: Callable) -> void:
	_get_branch_count = callback


func update_add_character_event() -> void:
	var event := _events.add_character
	var character_count: int = _get_character_count.call()
	if character_count == 0:
		show_event(event)
	else:
		hide_event(event)


func update_create_branch_event() -> void:
	var event := _events.create_branch
	var branch_count: int = _get_branch_count.call()
	if branch_count == 0:
		show_event(event)
	else:
		hide_event(event)


func show_event(event: Event) -> void:
	hide_event(event)
	for i in event.highlights.size():
		var tween := pulse(event.highlights[i])
		event.tweens[i] = tween

	for control in event.displays:
		control.show()

	event.is_active = true


func hide_event(event: Event) -> void:
	if not event.is_active:
		return
	event.is_active = false

	for i in event.highlights.size():
		event.tweens[i].kill()
		event.tweens[i] = null
		event.highlights[i].modulate = Color.WHITE

	for control in event.displays:
		control.hide()


func pulse(control: Control) -> Tween:
	var tween := get_tree().create_tween()
	var original := control.modulate
	var final := original * 2
	tween.tween_property(control, "modulate", final, _pulse_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(control, "modulate", original, _pulse_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_loops()
	return tween


class Event:
	extends RefCounted

	var is_active := false
	var highlights: Array[Control] = []
	var displays: Array[Control] = []
	var tweens: Array[Tween] = []


	func add_highlight(control: Control) -> void:
		highlights.push_back(control)
		tweens.push_back(null)


	func add_display(control: Control) -> void:
		displays.push_back(control)
