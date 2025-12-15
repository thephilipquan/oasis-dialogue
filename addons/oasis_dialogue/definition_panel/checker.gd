@tool
extends Node

const _DefinitionPanel := preload("res://addons/oasis_dialogue/definition_panel/definition_panel.gd")
const _Status := preload("res://addons/oasis_dialogue/definition_panel/status.gd")
const _TextEdit := preload("res://addons/oasis_dialogue/definition_panel/text_edit.gd")
const _AST := preload("res://addons/oasis_dialogue/definition_panel/model/ast.gd")
const _Error := preload("res://addons/oasis_dialogue/definition_panel/model/error.gd")

const _DuplicateAnnotation := preload("res://addons/oasis_dialogue/definition_panel/visitor/duplicate_annotation.gd")
const _DuplicateDefault := preload("res://addons/oasis_dialogue/definition_panel/visitor/duplicate_default.gd")
const _DuplicateId := preload("res://addons/oasis_dialogue/definition_panel/visitor/duplicate_id.gd")
const _FinishCallback := preload("res://addons/oasis_dialogue/definition_panel/visitor/finish_callback.gd")
const _UpdateSummary := preload("res://addons/oasis_dialogue/definition_panel/visitor/update_summary.gd")
const _UpdateExclusiveAnnotations := preload("res://addons/oasis_dialogue/definition_panel/visitor/update_exclusive_annotations.gd")
const _ParseError := preload("res://addons/oasis_dialogue/definition_panel/visitor/parse_error.gd")
const _VisitorIterator := preload("res://addons/oasis_dialogue/definition_panel/visitor/visitor_iterator.gd")
const _ValidateAnnotation := preload("res://addons/oasis_dialogue/definition_panel/visitor/validate_annotation.gd")

var _iterator: _VisitorIterator = null

@export
var _panel: _DefinitionPanel = null
@export
var _text: _TextEdit = null
@export
var _status: _Status = null


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	_iterator = _VisitorIterator.new()

	var on_err := func checker_on_err(error: _Error) -> void:
		_iterator.stop()
		_status.err(error)
		_text.highlight(error.line)
		_panel.mark_page_invalid()

	var parse_error := _ParseError.new()
	parse_error.init_on_err(on_err)

	var validate_annotation := _ValidateAnnotation.new()
	validate_annotation.init_get_annotations(_panel.get_annotations)
	validate_annotation.init_on_err(on_err)

	var duplicate_id := _DuplicateId.new()
	duplicate_id.init_on_err(on_err)

	var duplicate_annotation := _DuplicateAnnotation.new()
	duplicate_annotation.init_on_err(on_err)

	var duplicate_default := _DuplicateDefault.new()
	duplicate_default.init_is_default(_panel.annotation_is_default)
	duplicate_default.init_on_err(on_err)

	var update_summary := _UpdateSummary.new()
	update_summary.set_update(_panel.set_summary)

	var update_exclusive_annotations := _UpdateExclusiveAnnotations.new()
	update_exclusive_annotations.init_is_viewing_annotations(_panel.viewing_annotations)
	update_exclusive_annotations.init_is_exclusive_annotation(_panel.annotation_is_exclusive)
	update_exclusive_annotations.init_update_exclusives(_panel.set_annotation_exclusives)

	var mark_page_valid := _FinishCallback.new(_panel.mark_page_valid)

	_iterator.set_visitors([
			parse_error,
			validate_annotation,
			duplicate_id,
			duplicate_annotation,
			duplicate_default,
			update_summary,
			update_exclusive_annotations,
			mark_page_valid,
	])


func check(ast: _AST.Program) -> void:
	_status.clear()
	_text.clear_highlights()
	_iterator.accept(ast)
