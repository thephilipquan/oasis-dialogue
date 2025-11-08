extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _CSVFile := preload("res://addons/oasis_dialogue/io/csv_file.gd")

var _stage: _CSVFile.Stage = null
var _in_prompt := false
var _in_response := false


func set_stage(stage: _CSVFile.Stage) -> void:
	_stage = stage


func visit_prompt(_prompt: _AST.Prompt) -> void:
	_in_response = false
	_in_prompt = true


func visit_response(_response: _AST.Response) -> void:
	_in_prompt = false
	_in_response = true


func visit_stringliteral(value: _AST.StringLiteral) -> void:
	assert(_in_prompt or _in_response, "This should be impossible to be false")
	var entry := value.value.replace('"', '""')
	entry = '"%s"' % entry
	if _in_prompt:
		_stage.add_prompt(entry)
	elif _in_response:
		_stage.add_response(entry)


func cancel() -> void:
	_stage = null
	_in_prompt = false
	_in_response = false


func finish() -> void:
	cancel()
