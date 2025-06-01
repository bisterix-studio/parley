@tool

# TODO: prefix with Parley
class_name DialogueContainer extends MarginContainer


@onready var dialogue_text_label: RichTextLabel = %DialogueTextLabel


## The current dialogue node AST.
var dialogue_node: DialogueNodeAst = DialogueNodeAst.new():
	set(next_dialogue_node):
		dialogue_node = next_dialogue_node
		_render()


func _ready() -> void:
	_render()


func _render() -> void:
	if dialogue_text_label:
		var character: Character = dialogue_node.resolve_character()
		dialogue_text_label.text = "[b]%s[/b] – %s" % [character.name if character.name != '' else 'Unknown', dialogue_node.text]
