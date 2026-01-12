## A "toggle" button that supports a hover texture when toggled on.
@tool
extends TextureButton

## Set the starting state of the button.
##
## Do not use the native _toggled member.
@export
var on := false:
	set(value):
		on = value
		_sync_textures()

@export_group("Textures")
@export
var off_normal: CompressedTexture2D = null:
	set(value):
		off_normal = value
		if not on:
			texture_normal = off_normal
@export
var off_hovered: CompressedTexture2D = null:
	set(value):
		off_hovered = value
		if not on:
			texture_hover = off_hovered
@export
var on_normal: CompressedTexture2D = null:
	set(value):
		on_normal = value
		if on:
			texture_normal = on_normal
@export
var on_hovered: CompressedTexture2D = null:
	set(value):
		on_hovered = value
		if on:
			texture_hover = on_hovered


func _pressed() -> void:
	on = not on


func _sync_textures() -> void:
	if on:
		texture_normal = on_normal
		texture_hover = on_hovered
	else:
		texture_normal = off_normal
		texture_hover = off_hovered
