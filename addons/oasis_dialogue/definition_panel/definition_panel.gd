@tool
extends VBoxContainer

const REGISTRY_KEY := "definition_panel"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _TextEdit := preload("res://addons/oasis_dialogue/definition_panel/text_edit.gd")

## Emitted, after the debounce period, when a page is edited.
signal changed(text: String)
## Emitted when a page is enabled.
signal enabled
## Emitted when a page is disabled.
signal disabled
## Emitted when the panel needs to be cleared via disabling or changing pages.
signal cleared

@onready
var _parse_timer: Timer = $ParseTimer
@onready
var _text: _TextEdit = $TextEdit
@onready
var _enable_page_checkbox: CheckBox = $HeaderBackground/Header/EnablePage

var _annotations := _AnnotationPage.new()
var _conditions := _Page.new()
var _actions := _Page.new()

var _page: _Page = null
# Prevents re-setting _text.text when the source is already displayed.
# If there are errors and the text is highlighted, re-setting the text
# will bug the lines already colored.
var _viewing_source := false


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	var show_annotations: BaseButton = $HeaderBackground/Header/ShowAnnotations
	show_annotations.pressed.connect(change_page.bind(_annotations))
	_annotations.button = show_annotations

	var show_conditions: BaseButton = $HeaderBackground/Header/ShowConditions
	show_conditions.pressed.connect(change_page.bind(_conditions))
	_conditions.button = show_conditions

	var show_actions: BaseButton = $HeaderBackground/Header/ShowActions
	show_actions.pressed.connect(change_page.bind(_actions))
	_actions.button = show_actions

	# Simulate button press. Remove in future. Press the button on loading from project.
	# If none-last viewed, the default to annotation.
	show_annotations.button_pressed = true
	show_annotations.pressed.emit()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func change_page(to: _Page) -> void:
	if _page == to:
		return
	_page = to
	_sync_page()


func get_annotations() -> PackedStringArray:
	var result := PackedStringArray()
	if _page == _annotations:
		result = ["default", "prompt"]
	elif _page == _actions:
		result =  ["branch"]
	return result


func annotation_is_default(value: String) -> bool:
	return value == "default"


func annotation_is_exclusive(value: String) -> bool:
	return value == "prompt"


func show_source() -> void:
	if _viewing_source:
		return
	_text.text = _page.source
	_viewing_source = true


func show_summary() -> void:
	_text.text = "\n".join(_page.summary)
	_viewing_source = false


func mark_page_invalid() -> void:
	_page.has_error = true
	_page.button.modulate = get_theme_color("invalid_color", "Project")


func mark_page_valid() -> void:
	_page.has_error = false
	_page.button.modulate = (
			get_theme_color("enabled_color", "Project")
			if _page.enabled
			else Color.WHITE
	)


func viewing_annotations() -> bool:
	return _page == _annotations


func viewing_conditions() -> bool:
	return _page == _conditions


func viewing_actions() -> bool:
	return _page == _actions


func set_summary(summary: PackedStringArray) -> void:
	_page.summary = summary


func set_annotation_exclusives(exclusives: PackedStringArray) -> void:
	(_page as _AnnotationPage).exclusives = exclusives


func branch_annotation_is_exclusive(annotation: String) -> bool:
	return _annotations.exclusives.find(annotation) != -1


func branch_annotation_exists(annotation: String) -> bool:
	return annotation in _annotations.summary


func annotations_enabled() -> bool:
	return _annotations.enabled


func condition_exists(condition: String) -> bool:
	return condition in _conditions.summary


func conditions_enabled() -> bool:
	return _conditions.enabled


func action_exists(action: String) -> bool:
	return action in _actions.summary


func actions_enabled() -> bool:
	return _actions.enabled


func _sync_page() -> void:
	_enable_page_checkbox.button_pressed = _page.enabled
	_text.editable = _page.enabled

	if not _page.enabled:
		show_summary()
		_page.button.modulate = Color.WHITE
		cleared.emit()
		return

	if _page.has_error:
		show_source()
		_page.button.modulate = get_theme_color("invalid_color", "Project")
		changed.emit(_page.source)
	else:
		show_summary()
		_page.button.modulate = get_theme_color("enabled_color", "Project")
		cleared.emit()


func _on_summary_edit_text_changed() -> void:
	_page.source = _text.text
	_parse_timer.start()


func _on_parse_timer_timeout() -> void:
	changed.emit(_page.source)


func _on_enable_page_toggled(toggled_on: bool) -> void:
	_page.enabled = toggled_on
	_sync_page()
	if toggled_on:
		enabled.emit()
	else:
		disabled.emit()


class _Page:
	extends RefCounted

	var enabled := false
	var source := ""
	var summary := PackedStringArray()
	var has_error := false
	var button: BaseButton = null


class _AnnotationPage:
	extends _Page

	var exclusives := PackedStringArray()
