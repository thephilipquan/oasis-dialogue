@tool
extends Node

const REGISTRY_KEY := "export_handler"

const _Definitions := preload("res://addons/oasis_dialogue/definitions/definitions.gd")
const _ExportConfig := preload("res://addons/oasis_dialogue/model/export_config.gd")
const _DefaultAnnotationData := preload("res://addons/oasis_dialogue/export_dialog/model/default_annotation_data.gd")
const _Dialog := preload("res://addons/oasis_dialogue/export_dialog/export_dialog.gd")
const _DialogScene := preload("res://addons/oasis_dialogue/export_dialog/export_dialog.tscn")
const _ProjectMenu := preload("res://addons/oasis_dialogue/menu_bar/project.gd")
const _ProjectManager := preload("res://addons/oasis_dialogue/main/project_manager.gd")
const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

signal export_requested(config: _ExportConfig)

var _dialog_factory := Callable()
var _get_default_annotation := Callable()
var _get_exclusive_annotations := Callable()

var _last_export := _ExportConfig.new()


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	init_dialog_factory(
			func create_export_dialog() -> _Dialog:
				var scene: _Dialog = _DialogScene.instantiate()
				add_child(scene)
				return scene
	)

	var definitions: _Definitions = registry.at(_Definitions.REGISTRY_KEY)
	init_get_default_annotation(definitions.annotations.get_default)
	init_get_exclusive_annotations(definitions.annotations.get_index.bind("prompt"))

	var project_manager: _ProjectManager = registry.at(_ProjectManager.REGISTRY_KEY)
	project_manager.saving_settings.connect(save_settings)
	project_manager.settings_loaded.connect(load_settings)

	var project_menu: _ProjectMenu = registry.at(_ProjectMenu.REGISTRY_KEY)
	project_menu.export_requested.connect(show_file_dialog)


func init_dialog_factory(callback: Callable) -> void:
	_dialog_factory = callback


func init_get_exclusive_annotations(callback: Callable) -> void:
	_get_exclusive_annotations = callback


func init_get_default_annotation(callback: Callable) -> void:
	_get_default_annotation = callback


func show_file_dialog() -> void:
	# Override history if explicit default annotation exists.
	_refresh_last_export_default_annotation()

	var dialog: _Dialog = _dialog_factory.call()

	var annotation_data := _DefaultAnnotationData.new()
	annotation_data.default = _last_export.default_annotation
	annotation_data.options = _get_exclusive_annotations.call()
	dialog.init_default_annotation_data(annotation_data)

	dialog.init_last_export(_last_export)
	dialog.canceled.connect(_on_dialog_canceled.bind(dialog))
	dialog.finished.connect(_on_dialog_finished.bind(dialog))


func _on_dialog_canceled(dialog: _Dialog) -> void:
	dialog.get_parent().remove_child(dialog)
	dialog.queue_free()


func _on_dialog_finished(data: _ExportConfig, dialog: _Dialog) -> void:
	_last_export = data
	_on_dialog_canceled(dialog)
	export_requested.emit(data)


func save_settings(config: ConfigFile) -> void:
	_last_export.save_to_config(config, "export")


func load_settings(config: ConfigFile) -> void:
	_last_export.load_from_config(config, "export")


func _refresh_last_export_default_annotation() -> void:
	var try: String = _get_default_annotation.call()
	if try:
		_last_export.default_annotation = try
