@tool
# TODO: prefix with Parley
class_name DialogueNodeEditor extends NodeEditor

signal dialogue_node_changed(id: String, character: String, dialogue: String)

@export var character: String = "": set = _set_character
@export var dialogue: String = "": set = _set_dialogue

# TODO: add a separate drop down for a character store rather than all characters in a list
var selected_character_stores: Array[CharacterStore] = []: set = _set_selected_character_stores
var all_characters: Array[Character] = []

@onready var character_editor: OptionButton = %CharacterEditor
@onready var dialogue_editor: TextEdit = %DialogueEditor

func _ready() -> void:
	set_title()
	reload_character_store()
	_select_character()
	_render_dialogue()

func _set_character(new_character: String) -> void:
	character = new_character
	_select_character()

func _set_selected_character_stores(new_selected_character_stores: Array[CharacterStore]) -> void:
	selected_character_stores = new_selected_character_stores
	reload_character_store()

func _select_character() -> void:
	if character_editor:
		var selected_index: int = -1
		var index = 0
		for character_def: Character in all_characters:
			if character == character_def.id:
				selected_index = index
			index += 1
		if character_editor.selected != selected_index:
			character_editor.select(selected_index)

func _set_dialogue(new_dialogue: String) -> void:
	dialogue = new_dialogue
	_render_dialogue()

func _render_dialogue() -> void:
	if dialogue_editor and dialogue_editor.text != dialogue:
		dialogue_editor.text = dialogue

func reload_character_store() -> void:
	if not character_editor:
		return

	var new_all_characters: Array[Character] = []
	for character_store in selected_character_stores:
		new_all_characters.append_array(character_store.characters)
	all_characters = new_all_characters

	character_editor.clear()
	for character_def in all_characters:
		character_editor.add_item(character_def.id)
	_select_character()

#region SIGNALS
func _on_dialogue_editor_text_changed() -> void:
	dialogue = dialogue_editor.text
	_emit_dialogue_node_changed()

func _on_character_editor_item_selected(index: int) -> void:
	character = all_characters[index].id
	_emit_dialogue_node_changed()

func _emit_dialogue_node_changed() -> void:
	dialogue_node_changed.emit(id, character, dialogue)
#endregion
