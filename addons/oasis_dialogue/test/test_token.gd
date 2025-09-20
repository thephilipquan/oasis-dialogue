extends GutTest

const Token := preload("res://addons/oasis_dialogue/model/token.gd")

const Type := Token.Type

var sut: Token = null

func after_each() -> void:
	sut = null


func test_init() -> void:
	sut = Token.new(Type.TEXT, "abc", 3, 7)

	assert_eq(sut.type, Type.TEXT)
	assert_eq(sut.value, "abc")
	assert_eq(sut.line, 3)
	assert_eq(sut.column, 7)
