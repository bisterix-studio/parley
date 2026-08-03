# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyTranslationKeyEditor extends VBoxContainer


#region DEFS
var label: String = "": set = _set_label
var key: String = "": set = _set_key


@onready var translation_key_label: Label = %TranslationKeyLabel
@onready var translation_key_editor: LineEdit = %TranslationKeyEditor
@onready var generate_translation_key_button: Button = %GenerateTranslationKeyButton
@onready var edit_translation_key_button: Button = %EditTranslationKeyButton


signal key_changed(new_key: String)
signal key_generation_requested()
#endregion


#region LIFECYCLE
func _ready() -> void:
	_render_label()
	_render_key(true)
	_render_edit_translation_key_button(true)
	_render_generate_translation_key_button(true)
#endregion


#region SETTERS
func _set_key(new_key: String) -> void:
	key = new_key
	_render_key()


func _set_label(new_label: String) -> void:
	label = new_label
	_render_label()
#endregion


#region RENDERERS
func _render_label() -> void:
	if translation_key_label:
		translation_key_label.text = label

func _render_key(on_ready: bool = false) -> void:
	if translation_key_editor:
		if translation_key_editor.text != key:
			translation_key_editor.text = key
		if on_ready:
			translation_key_editor.tooltip_text = &"Set the translation key for the associated field"
			translation_key_editor.editable = false


func _render_edit_translation_key_button(on_ready: bool = false) -> void:
	if edit_translation_key_button:
		if on_ready:
			edit_translation_key_button.tooltip_text = &"Edit the translation key for this Node AST. Be cautious when changing this as it is likely to affect existing translations."
			edit_translation_key_button.button_pressed = false


func _render_generate_translation_key_button(on_ready: bool = false) -> void:
	if generate_translation_key_button:
		if on_ready:
			generate_translation_key_button.tooltip_text = &"Generate the translation key for this Node AST. Be cautious when regenerating this as it is likely to affect existing translations."
#endregion


#region SIGNALS
func _on_translation_key_editor_text_changed(new_text: String) -> void:
	key = new_text
	key_changed.emit(key)


func _on_generate_translation_key_button_pressed() -> void:
	key_generation_requested.emit()


func _on_edit_translation_key_button_toggled(toggled_on: bool) -> void:
	if translation_key_editor:
		translation_key_editor.editable = toggled_on
#endregion
