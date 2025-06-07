# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyStringEditor extends HBoxContainer

#region DEFS
@export var key: String = "": set = _set_key
@export var value: String = "": set = _set_value
@export var minimum_x: float = 100 : set = _set_minimum_x
@export var placeholder: String = "" : set = _set_placeholder


@onready var label: Label = %Label
@onready var value_edit: LineEdit = %ValueEdit


signal value_changed(new_value: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_render_key()
	_render_value()
#endregion


#region SETTERS
func _set_key(new_key: String) -> void:
	key = new_key
	_render_key()


func _set_value(new_value: String) -> void:
	value = new_value
	_render_value()


func _set_minimum_x(new_value: float) -> void:
	minimum_x = new_value
	_render_key()


func _set_placeholder(new_value: String) -> void:
	placeholder = new_value
	_render_value()
#endregion


#region RENDERERS
func _render_key() -> void:
	if label:
		label.text = "%s:" % [key.capitalize()]
		if label.custom_minimum_size.x != minimum_x:
			label.custom_minimum_size.x = minimum_x


func _render_value() -> void:
	if value_edit:
		if value_edit.text != value:
			value_edit.text = value
		if value_edit.placeholder_text != placeholder:
			value_edit.placeholder_text = placeholder
#endregion


#region SIGNALS
func _on_value_edit_text_changed(new_text: String) -> void:
	value = new_text
	value_changed.emit(new_text)
#endregion
