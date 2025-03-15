@tool
class_name DialogueNodeEditor extends NodeEditor

signal dialogue_node_changed

@export var character: String = "": set = _on_character_changed
@export var dialogue: String = "": set = _on_dialogue_changed


var character_store: CharacterStore = ParleyManager.character_store


@onready var character_editor: OptionButton = %CharacterEditor
@onready var dialogue_editor: TextEdit = %DialogueEditor

func _ready() -> void:
	reload_character_store()
	hide()


func _on_character_changed(new_character: String) -> void:
	character = new_character
	_select_character()


func _select_character() -> void:
	if character_editor:
		var selected_index: int = -1
		for character_def in character_store.characters:
			if character == character_def.name:
				selected_index = character_def.id
		if character_editor.selected != selected_index:
			character_editor.select(selected_index)


func _on_dialogue_changed(new_dialogue: String) -> void:
	dialogue = new_dialogue
	if dialogue_editor and dialogue_editor.text != dialogue:
		dialogue_editor.text = dialogue


func reload_character_store() -> void:
	var max_index_to_delete: int = character_editor.item_count
	for character_def in character_store.characters:
		character_editor.add_item(character_def.name, character_def.id)
	for _index in range(max_index_to_delete):
		character_editor.remove_item(0)
	_select_character()
	show()


#region SIGNALS
func _on_dialogue_editor_text_changed() -> void:
	dialogue = dialogue_editor.text
	_emit_dialogue_node_changed()


func _on_character_editor_item_selected(index: int) -> void:
	var character_id: int = character_editor.get_item_id(index)
	character = character_store.get_character_name_by_id(character_id)
	_emit_dialogue_node_changed()


func _emit_dialogue_node_changed() -> void:
	var character: String = character_store.get_character_name_by_id(character_editor.selected)
	var dialogue: String = dialogue_editor.text
	dialogue_node_changed.emit(id, character, dialogue)
#endregion
