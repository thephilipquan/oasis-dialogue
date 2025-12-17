## A controller for OasisTraverser that determines how it traverses a branch
## and/or run code in response to events.
##
## All overridable methods are [i]events[/i] that occur when traversing
## branches.
##
## Events whose return type is [code]bool[/code] indicate that it is an
## [b]exclusive event[/b], meaning only [b]1[/b] controller should handle that 
## event at runtime.
##
## If you override an [i]exclusive[/i] method, you [b]must return
## [code]true[/code][b].
##
## All custom OasisTraverserControllers [b]must be added as children of an
## OasisManager to be registered[/b].
@abstract
class_name OasisTraverserController
extends Node

## Returns the annotation as notated by the writer that this controller handles.
## [codeblock]
## func get_annotation() -> String
## 	# For example, if handling the @block annotation.
## 	return "block"
## [/codeblock]
@abstract
func get_annotation() -> String

## [b]Exclusive event.[/b]
##
## Called when the using class has called [method OasisTraverser.next] and the
## traverser needs to know whether it has a next prompt to display.
##
## [b]Must return [code]true[/code] when overriding.[/b]
##
## [br][br]
##
## This is where you implement custom dialogue prompt indexing.
## View [OasisTraverser] for exposed methods.
##
## [br][br]
##
## You should call [method OasisTraverser.set_prompt_index] in this method.
## If [code] 0 <= prompt_index <= prompts.size() - 1[/code], the traverser
## will determine there [b]is[/b] a next prompt.
## Setting the prompt index to [code]prompts.size()[/code] or higher will
## result in the traverser determining there [b]is not[/b] a next prompt.
##
## [br][br]
##
## See the default
## [url=https://github.com/thephilipquan/oasis-dialogue/blob/feat-docs/addons/oasis_dialogue/traverser_controller/seq.gd]
## @seq
## [/url]
## and
## [url=https://github.com/thephilipquan/oasis-dialogue/blob/feat-docs/addons/oasis_dialogue/traverser_controller/rng.gd]
## @rng
## [/url]
## annotations for example implementation.
func has_prompt(traverser: OasisTraverser) -> bool:
	return false

## [b]Exclusive event.[/b]
##
## Called when the current branch being traversed has displayed a prompt to
## the player and needs the prompt index incremented.
##
## [b]Must return [code]true[/code] when overriding.[/b]
##
## [br][br]
##
## Use [method OasisTraverser.get_prompt_index] and
## [method OasisTraverser set_prompt_index].
func increment_prompt_index(traverser: OasisTraverser) -> bool:
	return false

## Called when the traverser is finished traversing the entire dialogue.
func finish(traverser: OasisTraverser) -> void:
	pass

## Called when a branch with the specified annotation via
## [method get_annotation] is visited.
func enter_branch(traverser: OasisTraverser) -> void:
	pass

## Called when a branch with the specified annotation via
## [method get_annotation] is finished being visited.
func exit_branch(traverser: OasisTraverser) -> void:
	pass
