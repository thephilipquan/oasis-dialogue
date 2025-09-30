## Calls the registered callback with the [member AST.Branch.id] of the branch
## during [method finish].
## [br][br]
## Logistically, the callback is called if the result all the visitors in the
## [VisitorIterator] [b]is valid[/b].
extends "res://addons/oasis_dialogue/visitor/visitor.gd"

## [code]func(id: int) -> void[/code]
var _callback := Callable()

var _id := -1


## [param callback] [code]func(id: int) -> void[/code]
## [br][br]
## [method Callable.unbind] the callback if you want to pass a method that takes no parameters.
func _init(callback: Callable) -> void:
	_callback = callback


func visit_branch(branch: _AST.Branch) -> void:
	_id = branch.id


func cancel() -> void:
	_id = -1


func finish() -> void:
	_callback.call(_id)
	cancel()
