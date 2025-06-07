# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyCaseEditor extends HBoxContainer

@export var available_cases: Array[Variant] = [ParleyMatchNodeAst.fallback_key]: set = _set_available_cases
@export var value: Variant = "": set = _set_value
@export var is_fallback: bool = false: set = _set_is_fallback

@onready var case_text_editor: LineEdit = %CaseTextEditor
@onready var case_editor: OptionButton = %CaseEditor
@onready var fallback_icon: TextureRect = %FallbackIcon

enum ValueType {
	String,
	Int,
	Float,
	Bool,
}

var _value_type: ValueType = ValueType.String

signal case_edited(value: String, is_fallback: bool)
signal case_deleted

#region SETUP
func _init(p_value: String = "", _is_fallback: bool = false) -> void:
	is_fallback = _is_fallback
	value = p_value

func _ready() -> void:
	_render_available_cases()
	_render_is_fallback()
	_render_value()

func _render_available_cases() -> void:
	if case_editor and case_text_editor:
		_set_edit_mode()
		case_editor.clear()
		var index: int = 0
		for case: Variant in available_cases:
			case_editor.add_item(str(case).capitalize(), index)
			index += 1

func _render_value() -> void:
	if case_text_editor and case_text_editor.text != str(value):
		case_text_editor.text = str(value)
	if case_editor:
		var index: int = available_cases.map(_map_value_for_comparison).find(_map_value_for_comparison(value))
		if index == -1:
			case_editor.selected = -1
		else:
			if case_editor.selected != index and case_editor.item_count > 0:
				case_editor.select(index)

func _render_is_fallback() -> void:
	if case_text_editor and case_editor:
		if is_fallback:
			fallback_icon.show()
		else:
			fallback_icon.hide()
		_set_edit_mode()
#endregion

#region SETTERS
func _set_value(_value: Variant) -> void:
	if is_fallback:
		value = ParleyMatchNodeAst.fallback_key
	else:
		if value is String and value == ParleyMatchNodeAst.fallback_key:
			is_fallback = true
		value = _value
	match typeof(value):
		TYPE_STRING: _value_type = ValueType.String
		TYPE_INT: _value_type = ValueType.Int
		TYPE_FLOAT: _value_type = ValueType.Float
		TYPE_BOOL: _value_type = ValueType.Bool
		_: _value_type = ValueType.String
	_render_value()

func _set_available_cases(_available_cases: Array[Variant]) -> void:
	available_cases = _available_cases
	_render_available_cases()

func _set_is_fallback(_is_fallback: bool) -> void:
	is_fallback = _is_fallback
	if is_fallback:
		value = ParleyMatchNodeAst.fallback_name
	_render_is_fallback()
#endregion

#region HELPERS
func _set_edit_mode() -> void:
	if available_cases.size() == 1 and available_cases.has(ParleyMatchNodeAst.fallback_key):
		case_editor.hide()
		case_text_editor.show()
	else:
		case_editor.show()
		case_text_editor.hide()
#endregion

#region SIGNALS
func _on_case_text_editor_text_changed(new_text: String) -> void:
	value = _map_text_to_value(new_text)
	_emit_case_edited()

func _on_case_editor_item_selected(index: int) -> void:
	if index < available_cases.size():
		value = available_cases[index]
		_emit_case_edited()

func _emit_case_edited() -> void:
	case_edited.emit(ParleyMatchNodeAst.fallback_key if is_fallback else value, is_fallback)

func _on_delete_button_pressed() -> void:
	case_deleted.emit()
#endregion

#region HELPERS
func _map_text_to_value(text: String) -> Variant:
	match _value_type:
		ValueType.String: return str(text)
		ValueType.Int: return int(text)
		ValueType.Float: return float(text)
		ValueType.Bool: return true if text == 'true' else false
		_: return str(text)

func _map_value_for_comparison(value_variant: Variant) -> Variant:
	if is_instance_of(value_variant, TYPE_INT):
		var value_to_map: int = value_variant
		return float(value_to_map)
	return value_variant
#endregion
