@tool
class_name DialogueOptionNodeEditor extends NodeEditor

# TODO: can we move this into the class?
signal dialogue_option_node_changed

@export var character: String = ""
@export var option: String = ""


var character_store: CharacterStore = ParleyManager.character_store


func _ready() -> void:
	_render()
	hide()


func _render() -> void:
	show()
	%OptionButton.clear()
	var selected: int = -1
	var characters: Array[Character] = character_store.characters
	for character_def in characters:
		%OptionButton.add_item(character_def.name, character_def.id)
		if character == character_def.name:
			selected = character_def.id
	%OptionButton.selected = selected
	%CodeEdit.text = option


func _on_code_edit_text_changed() -> void:
	emit_dialogue_option_node_changed()


func _on_option_button_item_selected(index: int) -> void:
	emit_dialogue_option_node_changed()


func set_data(node: DialogueOptionNode) -> void:
	id = node.id
	character = node.character
	option = node.option
	_render()

func emit_dialogue_option_node_changed() -> void:
	var character: String = character_store.get_character_name_by_id(%OptionButton.selected)
	var option: String = %CodeEdit.text
	dialogue_option_node_changed.emit(id, character, option)
