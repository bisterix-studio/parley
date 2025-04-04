@tool
class_name ParleyStringEditor extends HBoxContainer

@export var key: String = "": set = _set_key
@export var value: String = "": set = _set_value

@onready var label: Label = %Label
@onready var value_edit: LineEdit = %ValueEdit

signal value_changed(new_value: String)

func _ready() -> void:
	_render_key()
	_render_value()

func _set_key(new_key: String) -> void:
	key = new_key
	_render_key()

func _render_key() -> void:
	if label:
		label.text = "%s:" % [key.capitalize()]

func _set_value(new_value: String) -> void:
	value = new_value
	_render_value()

func _render_value() -> void:
	if value_edit and value_edit.text != value:
		value_edit.text = value

func _on_value_edit_text_changed(new_text: String) -> void:
	value = new_text
	value_changed.emit(new_text)
