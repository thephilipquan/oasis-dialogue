@tool
extends Control

const INPUT_DIALOG_FACTORY_REGISTRY_KEY := "input_dialog_factory"
const CONFIRM_DIALOG_FACTORY_REGISTRY_KEY := "confirm_dialog_factory"
const BRANCH_FACTORY_REGISTRY_KEY := "branch_factory"
const STATUS_LABEL_FACTORY_REGISTRY_KEY := "status_label_factory"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")

const _InputDialog := preload("res://addons/oasis_dialogue/input_dialog/input_dialog.tscn")
const _ConfirmDialog := preload("res://addons/oasis_dialogue/confirm_dialog/confirm_dialog.tscn")

const _Branch := preload("res://addons/oasis_dialogue/branch/branch.gd")
const _BranchScene := preload("res://addons/oasis_dialogue/branch/branch.tscn")
const _Highlighter := preload("res://addons/oasis_dialogue/branch/highlighter.gd")

const _StatusLabelScene := preload("res://addons/oasis_dialogue/status/status_label.tscn")

const _Lexer := preload("res://addons/oasis_dialogue/model/lexer.gd")
const _Parser := preload("res://addons/oasis_dialogue/model/parser.gd")


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
