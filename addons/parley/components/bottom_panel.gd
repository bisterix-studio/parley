# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
extends MarginContainer

#region DEFS
const back_icon: Texture2D = preload('res://addons/parley/assets/Back.svg')
const forward_icon: Texture2D = preload('res://addons/parley/assets/Forward.svg')

@onready var toggle_sidebar_button: Button = %ToggleSidebarButton

var is_sidebar_open: bool = true: set = _is_sidebar_open_setter

signal sidebar_toggled(is_sidebar_open: bool)
#endregion

#region LIFECYCLE
func _ready() -> void:
	# TODO: set from config
	is_sidebar_open = true
#endregion

#region SETTERS
func _is_sidebar_open_setter(new_value: bool) -> void:
	is_sidebar_open = new_value
	_render_sidebar_button()
	sidebar_toggled.emit(is_sidebar_open)
#endregion

#region RENDERERS
func _render_sidebar_button() -> void:
	if toggle_sidebar_button:
		if is_sidebar_open:
			toggle_sidebar_button.icon = back_icon
		else:
			toggle_sidebar_button.icon = forward_icon
#endregion

#region SIGNALS
func _on_toggle_sidebar_button_pressed() -> void:
	is_sidebar_open = !is_sidebar_open
#endregion
