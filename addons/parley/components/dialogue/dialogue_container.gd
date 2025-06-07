# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool

class_name ParleyDialogueContainer extends MarginContainer


@onready var dialogue_text_label: RichTextLabel = %DialogueTextLabel


## The current dialogue node AST.
var dialogue_node: ParleyDialogueNodeAst = ParleyDialogueNodeAst.new():
	set(next_dialogue_node):
		dialogue_node = next_dialogue_node
		_render()


func _ready() -> void:
	_render()


func _render() -> void:
	if dialogue_text_label:
		var character: ParleyCharacter = dialogue_node.resolve_character()
		dialogue_text_label.text = "[b]%s[/b] – %s" % [character.name if character.name != '' else 'Unknown', dialogue_node.text]
