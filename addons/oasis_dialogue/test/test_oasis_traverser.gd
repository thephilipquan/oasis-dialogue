extends GutTest

const SequenceController := preload("res://addons/oasis_dialogue/traverser_controller/seq.gd")
var seq: OasisTraverserController = null


func before_all() -> void:
	seq = SequenceController.new()
	add_child(seq)


func after_all() -> void:
	seq.queue_free()


func test_prompt_to_prompt() -> void:
	var one := OasisBranch.new()
	one.annotations.push_back("seq")
	one.prompts.push_back(OasisLine.new("a"))
	one.prompts.push_back(OasisLine.new("b"))

	var branches: Dictionary[int, OasisBranch] = {
			1: one,
	}
	var root := 1
	var sut := OasisTraverser.new(branches, root)
	sut.init_controllers({ "seq": seq })
	sut.init_translation(func(s: String) -> String: return s)
	sut.init_condition_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> bool:
				return true
	)
	sut.init_action_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> void:
				pass
	)

	watch_signals(sut)
	sut.next()
	sut.next()
	assert_signal_emitted_with_parameters(sut.prompt, ["a"], 0)
	assert_signal_emitted_with_parameters(sut.prompt, ["b"], 1)


func test_prompt_to_response() -> void:
	var one := OasisBranch.new()
	one.annotations.push_back("seq")
	one.prompts.push_back(OasisLine.new("a"))
	one.responses.push_back(OasisLine.new("b"))

	var branches: Dictionary[int, OasisBranch] = {
			1: one,
	}
	var root := 1
	var sut := OasisTraverser.new(branches, root)
	sut.init_controllers({ "seq": seq })
	sut.init_translation(func(s: String) -> String: return s)
	sut.init_condition_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> bool:
				return true
	)
	sut.init_action_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> void:
				pass
	)

	watch_signals(sut)
	sut.next()
	assert_signal_emitted_with_parameters(sut.prompt, ["a"])
	assert_signal_emitted_with_parameters(sut.responses, [["b"]])


func test_prompt_to_finished() -> void:
	var one := OasisBranch.new()
	one.annotations.push_back("seq")
	one.prompts.push_back(OasisLine.new("a"))

	var branches: Dictionary[int, OasisBranch] = {
			1: one,
	}
	var root := 1
	var sut := OasisTraverser.new(branches, root)
	sut.init_controllers({ "seq": seq })
	sut.init_translation(func(s: String) -> String: return s)
	sut.init_condition_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> bool:
				return true
	)
	sut.init_action_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> void:
				pass
	)

	watch_signals(sut)
	sut.next()
	assert_signal_emitted_with_parameters(sut.prompt, ["a"])
	assert_signal_not_emitted(sut.finished)
	sut.next()
	assert_signal_emitted(sut.finished)


func test_response_to_prompt() -> void:
	var one := OasisBranch.new()
	one.annotations.push_back("seq")
	one.responses.push_back(
			OasisLine.new(
				"a",
				[],
				[
					OasisKeyValue.new("b", 2),
				],
				)
	)

	var two := OasisBranch.new()
	two.annotations.push_back("seq")
	two.prompts.push_back(OasisLine.new("b"))

	var branches: Dictionary[int, OasisBranch] = {
			1: one,
			2: two,
	}
	var root := 1
	var sut := OasisTraverser.new(branches, root)
	sut.init_controllers({ "seq": seq })
	sut.init_translation(func(s: String) -> String: return s)
	sut.init_condition_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> bool:
				return true
	)
	sut.init_action_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> void:
				for action in a:
					if action.key == "b":
						sut.branch(action.value)
	)

	watch_signals(sut)
	sut.next()
	assert_signal_emitted_with_parameters(sut.responses, [["a"]])
	sut.next(0)
	assert_signal_emitted_with_parameters(sut.prompt, ["b"])


func test_response_to_response() -> void:
	var one := OasisBranch.new()
	one.annotations.push_back("seq")
	one.responses.push_back(
			OasisLine.new(
				"a",
				[],
				[
					OasisKeyValue.new("b", 2),
				],
				)
	)

	var two := OasisBranch.new()
	two.annotations.push_back("seq")
	two.responses.push_back(OasisLine.new("b"))

	var branches: Dictionary[int, OasisBranch] = {
			1: one,
			2: two,
	}
	var root := 1
	var sut := OasisTraverser.new(branches, root)
	sut.init_controllers({ "seq": seq })
	sut.init_translation(func(s: String) -> String: return s)
	sut.init_condition_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> bool:
				return true
	)
	sut.init_action_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> void:
				for action in a:
					if action.key == "b":
						sut.branch(action.value)
	)

	watch_signals(sut)
	sut.next()
	sut.next(0)
	assert_signal_emitted_with_parameters(sut.responses, [["a"]], 0)
	assert_signal_emitted_with_parameters(sut.responses, [["b"]], 1)


func test_response_to_finished() -> void:
	var one := OasisBranch.new()
	one.annotations.push_back("seq")
	one.responses.push_back(OasisLine.new("a"))

	var branches: Dictionary[int, OasisBranch] = {
			1: one,
	}
	var root := 1
	var sut := OasisTraverser.new(branches, root)
	sut.init_controllers({ "seq": seq })
	sut.init_translation(func(s: String) -> String: return s)
	sut.init_condition_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> bool:
				return true
	)
	sut.init_action_handler(
			func(t: OasisTraverser, a: Array[OasisKeyValue]) -> void:
				pass
	)

	watch_signals(sut)
	sut.next()
	assert_signal_emitted_with_parameters(sut.responses, [["a"]])
	sut.next(0)
	assert_signal_emitted(sut.finished)
