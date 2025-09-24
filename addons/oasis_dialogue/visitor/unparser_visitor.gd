extends "res://addons/oasis_dialogue/visitor/visitor.gd"

const _BranchEdit := preload("res://addons/oasis_dialogue/branch/branch_edit.gd")


var _text := ""
var _id := -1
var _in_annotation := false
var _in_curly := false
var _seen_prompt := false
var _seen_response := false

@export
var _graph: _BranchEdit = null


func get_text() -> String:
	if _in_curly:
		_text += " }"
	return _text


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func visit_annotation(annotation: _AST.Annotation) -> void:
	var s := ""
	if _in_annotation:
		s += "\n"
	_in_annotation = true
	s += "@%s" % annotation.name
	_text += s


func visit_prompt(prompt: _AST.Prompt) -> void:
	var s := ""
	if _in_annotation:
		s += "\n"
		_in_annotation = false
	if not _seen_prompt:
		s += "@prompt"
		_seen_prompt = true
	if _in_curly:
		s += " }"
		_in_curly = false
	s += "\n"
	_text += s


func visit_response(response: _AST.Response) -> void:
	var s := ""
	if _in_annotation:
		s += "\n"
		_in_annotation = false
	if _in_curly:
		s += " }"
		_in_curly = false
	if not _seen_response:
		if _seen_prompt:
			s += "\n"
		s += "@response"
		_seen_response = true

	s += "\n"
	_text += s


func visit_condition(condition: _AST.Condition) -> void:
	var s := ""
	if _in_curly:
		# we are coming from an action."
		s += " }\n"
		_in_curly = false
	if not _in_curly:
		s += "{"
		_in_curly = true
	s += " %s" % condition.name
	_text += s


func visit_action(action: _AST.Action) -> void:
	var s := ""
	if not _in_curly:
		# Coming from _text.
		s += " {"
		_in_curly = true
	s += " %s" % action.name
	_text += s


func visit_stringliteral(value: _AST.StringLiteral) -> void:
	var s := ""
	if _in_curly:
		s += " } "
		_in_curly = false
	s += "%s" % value.value
	_text += s


func visit_numberliteral(value: _AST.NumberLiteral) -> void:
	var s := " %d" % value.value
	_text += s


func cancel() -> void:
	_text = ""
	_id = -1
	_in_annotation = false
	_in_curly = false
	_seen_prompt = false
	_seen_response = false


func finish() -> void:
	if _in_curly:
		_text += " }"
	_graph.get_branch(_id).set_text(_text)
	cancel()
