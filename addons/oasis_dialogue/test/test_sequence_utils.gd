extends GutTest

const Sequence := preload("res://addons/oasis_dialogue/utils/sequence.gd")

var sut: Sequence = null

func before_all() -> void:
	sut = Sequence.new()


func test_get_next() -> void:
	var sequence: Array[int] = [0, 2, 4]
	assert_eq(sut.get_next(sequence), 1)


func test_get_next_on_empty_sequence() -> void:
	var sequence: Array[int] = []
	assert_eq(sut.get_next(sequence), 0)


func test_get_next_on_non_gap_sequence() -> void:
	var sequence: Array[int] = [0, 1, 2, 3]
	assert_eq(sut.get_next(sequence), 4)
