@tool
extends VBoxContainer

const REGISTRY_KEY := "definition_panel"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _OasisFile := preload("res://addons/oasis_dialogue/io/oasis_file.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _TextEdit := preload("res://addons/oasis_dialogue/definition_panel/text_edit.gd")

## Emitted definitions have updated and branches should re-parse.
signal updated
## Emitted, after the debounce period, when a page is edited and needs parsing.
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

var annotations := AnnotationPage.new()
var conditions := Page.new()
var actions := ActionsPage.new()

var _page: Page = null
# Prevents re-setting _text.text when the source is already displayed.
# If there are errors and the text is highlighted, re-setting the text
# will bug the lines already colored.
var _viewing_source := false
# Prevents multiple updates emitting while loading.
var _loading := false


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	annotations.button = $HeaderBackground/Header/ShowAnnotations
	annotations.button.pressed.connect(change_page.bind(annotations))

	conditions.button = $HeaderBackground/Header/ShowConditions
	conditions.button.pressed.connect(change_page.bind(conditions))

	actions.button = $HeaderBackground/Header/ShowActions
	actions.button.pressed.connect(change_page.bind(actions))


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	manager.saving_annotations.connect(save_annotations)
	manager.annotations_loaded.connect(load_annotations)
	manager.saving_conditions.connect(save_conditions)
	manager.conditions_loaded.connect(load_conditions)
	manager.saving_actions.connect(save_actions)
	manager.actions_loaded.connect(load_actions)
	manager.saving_settings.connect(save_settings)
	manager.settings_loaded.connect(load_settings)


func change_page(to: Page) -> void:
	if _page == to:
		return

	# No page when first changing pages.
	if _page:
		_page.active = false

	_page = to
	_page.active = true
	_sync_page()


func show_page_source() -> void:
	if not _page.enabled or _viewing_source:
		return
	_text.text = _page.source
	_viewing_source = true


func show_page_summary() -> void:
	_text.text = "\n".join(_page.summary)
	_viewing_source = false


func mark_page_invalid() -> void:
	_page.has_error = true
	_color_page_button(_page)


func mark_page_valid() -> void:
	_page.has_error = false
	_color_page_button(_page)


func update_page_summary(summary: PackedStringArray) -> void:
	_page.summary = summary
	if _loading:
		return
	updated.emit()


func get_page_annotations() -> PackedStringArray:
	return _page.annotations


func save_annotations(file: _OasisFile) -> void:
	file.set_value("data", "source", annotations.source)


func load_annotations(file: _OasisFile) -> void:
	annotations.source = file.get_value("data", "source", "")


func save_conditions(file: _OasisFile) -> void:
	file.set_value("data", "source", conditions.source)


func load_conditions(file: _OasisFile) -> void:
	conditions.source = file.get_value("data", "source", "")


func save_actions(file: _OasisFile) -> void:
	file.set_value("data", "source", actions.source)


func load_actions(file: _OasisFile) -> void:
	actions.source = file.get_value("data", "source", "")


func save_settings(file: ConfigFile) -> void:
	file.set_value("annotations", "enabled", annotations.enabled)
	file.set_value("annotations", "active", annotations.active)
	file.set_value("conditions", "enabled", conditions.enabled)
	file.set_value("conditions", "active", conditions.active)
	file.set_value("actions", "enabled", actions.enabled)
	file.set_value("actions", "active", actions.active)


func load_settings(file: ConfigFile) -> void:
	_loading = true
	annotations.enabled = file.get_value("annotations", "enabled", false)
	annotations.active =  file.get_value("annotations", "active", true) # Default page.

	conditions.enabled = file.get_value("conditions", "enabled", false)
	conditions.active =  file.get_value("conditions", "active", false)

	actions.enabled = file.get_value("actions", "enabled", false)
	actions.active =  file.get_value("actions", "active", false)

	var active_page: Page = null
	for page in [annotations, conditions, actions]:
		if page.active:
			active_page = page

		# Methods exposed by this class allow visitors to only alter the current
		# page, so we have to simulate each page being active to visit them.
		change_page(page)
		changed.emit(_page.source)

	active_page.button.button_pressed = true
	active_page.button.pressed.emit()

	_loading = false
	updated.emit()


func _sync_page(page := _page) -> void:
	_enable_page_checkbox.button_pressed = page.enabled
	_text.editable = page.enabled
	_color_page_button(page)

	if not page.enabled:
		show_page_summary()
		cleared.emit()
		return

	if page.has_error:
		show_page_source()
		changed.emit(page.source)
	else:
		show_page_summary()
		cleared.emit()


func _emit_if_loaded(s: Signal) -> void:
	s.emit()


func _on_summary_edit_text_changed() -> void:
	_page.source = _text.text
	_parse_timer.start()


func _on_parse_timer_timeout() -> void:
	changed.emit(_page.source)


func _on_enable_page_toggled(toggled_on: bool) -> void:
	_page.enabled = toggled_on
	_sync_page()

	if _loading:
		return

	if toggled_on:
		enabled.emit()
	else:
		disabled.emit()


func _color_page_button(page: Page) -> void:
	var color := Color()
	if page.has_error:
		color = get_theme_color("invalid_color", "Project")
	elif page.enabled:
		color = get_theme_color("enabled_color", "Project")
	else:
		color = Color.WHITE
	page.button.modulate = color


class Page:
	extends RefCounted

	var enabled := false
	var source := ""
	var summary := PackedStringArray()
	var has_error := false
	var button: BaseButton = null
	var active := false

	var annotations := PackedStringArray()

	func is_enabled() -> bool:
		return enabled


	func exists(value: String) -> bool:
		return value in summary


	func is_active() -> bool:
		return active


class AnnotationPage:
	extends Page

	var _exclusives := PackedStringArray()


	func _init() -> void:
		annotations = ["default", "prompt"]


	func annotation_marks_default(value: String) -> bool:
		return value == "default"


	func annotation_marks_exclusive(value: String) -> bool:
		return value == "prompt"


	func is_exclusive(value: String) -> bool:
		return value in _exclusives


	func set_exclusives(values: PackedStringArray) -> void:
		_exclusives = values


class ActionsPage:
	extends Page


	func _init() -> void:
		annotations = ["branch"]
