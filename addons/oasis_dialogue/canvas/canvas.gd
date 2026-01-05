@tool
extends Control

const INPUT_DIALOG_FACTORY_REGISTRY_KEY := "input_dialog_factory"
const CONFIRM_DIALOG_FACTORY_REGISTRY_KEY := "confirm_dialog_factory"
const BRANCH_FACTORY_REGISTRY_KEY := "branch_factory"
const STATUS_LABEL_FACTORY_REGISTRY_KEY := "status_label_factory"
const FILE_DIALOG_FACTORY_REGISTRY_KEY := "file_dialog_factory"
const CSV_FILE_FACTORY_REGISTRY_KEY := "csv_file_factory"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.tscn")
const _ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.tscn")
const _FileDialog := preload("res://addons/oasis_dialogue/project_dialog/file_dialog.gd")
const _CSVFile := preload("res://addons/oasis_dialogue/io/csv_file.gd")
const _ProjectMenu := preload("res://addons/oasis_dialogue/menu_bar/project.gd")

const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _BranchScene := preload("res://addons/oasis_dialogue/branch/branch.tscn")
const _Highlighter := preload("res://addons/oasis_dialogue/branch/highlighter.gd")

const _StatusLabelScene := preload("res://addons/oasis_dialogue/status/status_label.tscn")

const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")

signal close_requested
signal quit_requested

@export
var _graph: GraphEdit = null


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	var add_branch: TextureButton = $AddBranch
	add_branch.reparent(_graph.get_menu_hbox())
	add_branch.size_flags_vertical = Control.SIZE_SHRINK_CENTER


func register(registry: _Registry) -> void:
	var lexer := _Lexer.new()
	registry.add(_Lexer.REGISTRY_KEY, lexer)
	var parser := _Parser.new()
	registry.add(_Parser.REGISTRY_KEY, parser)

	var input_dialog_factory := func create_input_dialog() -> Control:
		var dialog: Control = _InputDialog.instantiate()
		add_child(dialog)
		return dialog
	registry.add(INPUT_DIALOG_FACTORY_REGISTRY_KEY, input_dialog_factory)

	var confirm_dialog_factory := func create_confirm_dialog() -> Control:
		var dialog: Control = _ConfirmDialog.instantiate()
		add_child(dialog)
		return dialog
	registry.add(CONFIRM_DIALOG_FACTORY_REGISTRY_KEY, confirm_dialog_factory)

	var branch_factory := func create_branch() -> _Branch:
		var branch: _Branch = _BranchScene.instantiate()
		var highlighter := _Highlighter.new()
		highlighter.set_lexer(lexer)
		branch.init(highlighter)
		return branch
	registry.add(BRANCH_FACTORY_REGISTRY_KEY, branch_factory)

	var status_label_factory := func create_status_label() -> Label:
		var label: Label = _StatusLabelScene.instantiate()
		return label
	registry.add(STATUS_LABEL_FACTORY_REGISTRY_KEY, status_label_factory)

	var file_dialog_factory := func create_file_dialog() -> _FileDialog:
		var dialog: _FileDialog = _FileDialog.new()
		return dialog
	registry.add(FILE_DIALOG_FACTORY_REGISTRY_KEY, file_dialog_factory)

	var csv_file_factory := func create_csv_file() -> _CSVFile:
		var file := _CSVFile.new()
		return file
	registry.add(CSV_FILE_FACTORY_REGISTRY_KEY, csv_file_factory)


func setup(registry: _Registry) -> void:
	var project_menu: _ProjectMenu = registry.at(_ProjectMenu.REGISTRY_KEY)
	project_menu.close_project_requested.connect(close_requested.emit)
	project_menu.quit_app_requested.connect(quit_requested.emit)
