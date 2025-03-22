@tool
extends PanelContainer

const StringEditor = preload("../editor/string_editor.tscn")

@export var character_id: String = ""
@export var character_name: String = ""

@onready var character_editor_container: VBoxContainer = %CharacterEditorContainer
@onready var id_editor = %IdEditor
@onready var name_editor = %NameEditor

signal character_changed(id: String, name: String)

func _ready() -> void:
	_render()

func _render() -> void:
	_render_id_editor()
	_render_name_editor()

func _render_id_editor() -> void:
	if id_editor:
		id_editor.value = character_id

func _render_name_editor() -> void:
	if name_editor:
		name_editor.value = character_name

func _add_string_edit(key: String, value: String) -> void:
	var character_edit = StringEditor.instantiate()
	character_edit.key = key
	character_edit.value = value
	character_editor_container.add_child(character_edit)
	
func _clear() -> void:
	for child: Node in get_children():
		child.queue_free()

func _on_id_editor_value_changed(new_id: String) -> void:
	character_id = new_id
	_emit_character_changed()

func _on_name_editor_value_changed(new_name: String) -> void:
	character_name = new_name
	_emit_character_changed()

func _emit_character_changed() -> void:
	character_changed.emit(character_id, character_name)
