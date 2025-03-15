@tool

class_name DialogueContainer extends MarginContainer

@onready var dialogue_text_label: RichTextLabel = %DialogueTextLabel


## The current dialogue node AST.
@export var dialogue_node: DialogueNodeAst = DialogueNodeAst.new():
	set(next_dialogue_node):
		dialogue_node = next_dialogue_node
		if dialogue_text_label:
			dialogue_text_label.text = dialogue_node.text


func _ready() -> void:
	dialogue_text_label.text = dialogue_node.text
