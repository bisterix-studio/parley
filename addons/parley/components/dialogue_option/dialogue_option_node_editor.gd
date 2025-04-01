@tool
# TODO: prefix with Parley
class_name DialogueOptionNodeEditor extends NodeEditor

# TODO: this is out of date in terms of best practice - rewrite

# TODO: can we move this into the class?
signal dialogue_option_node_changed

@export var character: String = "": set = _set_character
@export var option: String = "": set = _set_option

# TODO: add a separate drop down for a character store rather than all characters in a list# TODO: change this to draw from multiple stores
var selected_character_stores: Array[CharacterStore] = []: set = _set_selected_character_stores
var all_characters: Array[Character] = []

@onready var character_editor: OptionButton = %OptionButton
# TODO: do we need code edit here?
@onready var option_editor: CodeEdit = %CodeEdit

func _ready() -> void:
	set_title()
	_render_character_store()
	_select_character()
	_render_option()

func _set_character(new_character: String) -> void:
	character = new_character
	_select_character()

func _set_option(new_option: String) -> void:
	option = new_option
	_render_option()

func _set_selected_character_stores(new_selected_character_stores: Array[CharacterStore]) -> void:
	selected_character_stores = new_selected_character_stores
	var new_all_characters: Array[Character] = []
	for character_store in selected_character_stores:
		new_all_characters.append_array(character_store.characters)
	all_characters = new_all_characters

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

func _render_character_store() -> void:
	if not character_editor:
		return
	character_editor.clear()
	for character_def in all_characters:
		character_editor.add_item(character_def.id)
	_select_character()

func _render_option() -> void:
	if option_editor and option_editor.text != option:
		option_editor.text = option

func _on_code_edit_text_changed() -> void:
	option = option_editor.text
	emit_dialogue_option_node_changed()

func _on_option_button_item_selected(index: int) -> void:
	character = all_characters[index].id
	emit_dialogue_option_node_changed()

func emit_dialogue_option_node_changed() -> void:
	dialogue_option_node_changed.emit(id, character, option)
