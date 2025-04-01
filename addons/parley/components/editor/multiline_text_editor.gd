@tool
extends Control

@export_multiline var text: String = "" : set = _set_text

@onready var text_editor: TextEdit = %TextEdit
@onready var edit_modal: Window = %EditModal
@onready var modal_text_edit: TextEdit = %ModalTextEdit

func _ready() -> void:
	_render_text()

func _set_text(new_text: String) -> void:
	text = new_text
	_render_text()

func _render_text() -> void:
	if text_editor and text_editor.text != text:
		text_editor.text = text

func _on_text_edit_text_changed() -> void:
	if text_editor and text_editor.text != text:
		text = text_editor.text

func _on_button_pressed() -> void:
	if edit_modal and modal_text_edit:
		edit_modal.show()
		modal_text_edit.text = text

func _on_modal_text_edit_text_changed() -> void:
	if modal_text_edit and modal_text_edit.text != text:
		text = modal_text_edit.text
