@tool
extends PanelContainer

var character: Character

const CharacterEdit = preload("../editor/string_editor.tscn")

@onready var character_editor_container: VBoxContainer = %CharacterEditorContainer
@onready var id_editor = %IdEditor
@onready var name_editor = %NameEditor

func _ready() -> void:
	_render()

func _render() -> void:
	if not character:
		return
	_render_id_editor()
	_render_name_editor()

func _render_id_editor() -> void:
	if id_editor:
		id_editor.value = character.id

func _render_name_editor() -> void:
	if name_editor:
		name_editor.value = character.name

func _add_string_edit(key: String, value: String) -> void:
	var character_edit = CharacterEdit.instantiate()
	character_edit.key = key
	character_edit.value = value
	character_editor_container.add_child(character_edit)
	
func _clear() -> void:
	for child: Node in get_children():
		child.queue_free()
