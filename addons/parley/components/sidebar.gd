# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleySidebar extends VBoxContainer

var current_dialogue_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new(): set = _update_current_dialogue_ast
var filtered_nodes: Array[ParleyNodeAst] = []

var dialogue_asts: Array[ParleyDialogueSequenceAst] = []: set = _update_dialogue_asts
var filtered_dialogue_asts: Array[ParleyDialogueSequenceAst] = []

@onready var node_list: ItemList = %NodesItemList
@onready var dialogue_sequences_list: ItemList = %DialogueSequencesList

var node_filter: String = "": set = _update_node_filter
var dialogue_ast_filter: String = "": set = _update_dialogue_ast_filter

signal dialogue_ast_selected(dialogue_ast: ParleyDialogueSequenceAst)
signal node_selected(node: ParleyNodeAst)

func _ready() -> void:
	dialogue_asts = []
	_update_current_dialogue_ast(current_dialogue_ast)

func _update_node_filter(new_node_filter: String) -> void:
	node_filter = new_node_filter
	_update_current_dialogue_ast(current_dialogue_ast)

func _update_current_dialogue_ast(new_current_dialogue_ast: ParleyDialogueSequenceAst) -> void:
	current_dialogue_ast = new_current_dialogue_ast
	if not node_list:
		return
	node_list.clear()
	filtered_nodes = []
	for node: ParleyNodeAst in current_dialogue_ast.nodes:
		var raw_node_string: String = str(node.to_dict())
		if not node_filter or raw_node_string.containsn(node_filter):
			var index: int = node_list.add_item("%s [ID: %s]" % [ParleyDialogueSequenceAst.get_type_name(node.type), node.id])
			if index == -1:
				ParleyUtils.log.error("Unable to add item to Sidebar Node list")
				return
			filtered_nodes.append(node)

func _on_search_nodes_text_changed(new_text: String) -> void:
	_update_node_filter(new_text)

func _on_item_list_item_selected(index: int) -> void:
	node_selected.emit(filtered_nodes[index])

func _on_dialogue_sequences_list_item_selected(index: int) -> void:
	dialogue_ast_selected.emit(filtered_dialogue_asts[index])

func _update_dialogue_ast_filter(new_dialogue_ast_filter: String) -> void:
	dialogue_ast_filter = new_dialogue_ast_filter
	_update_dialogue_asts(dialogue_asts)

func _update_dialogue_asts(updated_dialogue_asts: Array[ParleyDialogueSequenceAst]) -> void:
	dialogue_asts = updated_dialogue_asts
	if not dialogue_sequences_list:
		return
	dialogue_sequences_list.clear()
	filtered_dialogue_asts = []
	for dialogue_ast: ParleyDialogueSequenceAst in dialogue_asts:
		if dialogue_ast.resource_path:
			var parts: PackedStringArray = dialogue_ast.resource_path.split('/')
			var filename: String = parts[parts.size() - 1]
			if not dialogue_ast_filter or filename.containsn(dialogue_ast_filter):
				var index: int = dialogue_sequences_list.add_item(filename)
				if index == -1:
					ParleyUtils.log.error("Unable to add item to Sidebar Dialogue Sequences list")
					return
				filtered_dialogue_asts.append(dialogue_ast)

func add_dialogue_ast(dialogue_ast: ParleyDialogueSequenceAst) -> void:
	# We don't want to add a Dialogue AST that already exists
	var filtered: Array = dialogue_asts.filter(func(d: ParleyDialogueSequenceAst) -> bool: return ParleyUtils.resource.get_uid(d) == ParleyUtils.resource.get_uid(dialogue_ast))
	if dialogue_asts.size() > 0 and filtered.size() > 0:
		return
	dialogue_asts.append(dialogue_ast)
	current_dialogue_ast = dialogue_ast
	_update_dialogue_asts(dialogue_asts)
