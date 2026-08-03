# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyBottomPanel extends MarginContainer

#region DEFS
const back_icon: Texture2D = preload('res://addons/parley/assets/Back.svg')
const forward_icon: Texture2D = preload('res://addons/parley/assets/Forward.svg')

@onready var toggle_sidebar_button: Button = %ToggleSidebarButton
@onready var version_label: LinkButton = %Version

var is_sidebar_open: bool = true: set = _is_sidebar_open_setter
var version: String  = "" : set = _set_version
const version_label_tooltip: StringName = &"Click to copy the version information"

signal sidebar_toggled(is_sidebar_open: bool)
#endregion

#region LIFECYCLE
func _ready() -> void:
	# TODO: set from config
	is_sidebar_open = true
#endregion

#region SETTERS
func _set_version(new_version: String) -> void:
	version = new_version
	_render_version_label()


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


func _render_version_label() -> void:
	if version_label:
		version_label.tooltip_text = version_label_tooltip
		version_label.text = "v%s" % version
#endregion

#region SIGNALS
func _on_toggle_sidebar_button_pressed() -> void:
	is_sidebar_open = !is_sidebar_open


func _on_version_pressed() -> void:
	DisplayServer.clipboard_set("Parley [v%s]" % [version])
#endregion
