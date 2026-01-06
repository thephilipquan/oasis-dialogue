@tool
extends Node

const REGISTRY_KEY := "help_handler"

const _Registry := preload("res://addons/oasis_dialogue/registry.gd")
const _HelpMenu := preload("res://addons/oasis_dialogue/menu_bar/help.gd")


func register(registry: _Registry) -> void:
	registry.add(REGISTRY_KEY, self)


func setup(registry: _Registry) -> void:
	var menu: _HelpMenu = registry.at(_HelpMenu.REGISTRY_KEY)
	menu.view_documentation_requested.connect(_open_documentation)
	menu.report_bug_requested.connect(_open_github_issues)


func _open_documentation() -> void:
	OS.shell_open("https://github.com/thephilipquan/oasis-dialogue/blob/main/docs/how_to_write.md")


func _open_github_issues() -> void:
	OS.shell_open("https://github.com/thephilipquan/oasis-dialogue/issues")
