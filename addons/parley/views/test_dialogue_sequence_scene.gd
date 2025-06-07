# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends Node2D


var current_dialogue_ast: ParleyDialogueSequenceAst


func _ready() -> void:
	var ctx: Dictionary = {}
	current_dialogue_ast = ParleyManager.get_instance().load_test_dialogue_sequence()
	ParleyUtils.signals.safe_connect(current_dialogue_ast.dialogue_ended, _on_dialogue_ended)
	var start_node_variant: Variant = ParleyManager.get_instance().get_test_start_node(current_dialogue_ast)
	if start_node_variant is ParleyNodeAst:
		var start_node: ParleyNodeAst = start_node_variant
		var _node: Node = ParleyRuntime.get_instance().start_dialogue(ctx, current_dialogue_ast, start_node)
	else:
		var _node: Node = ParleyRuntime.get_instance().start_dialogue(ctx, current_dialogue_ast)


func _exit_tree() -> void:
	ParleyManager.get_instance().set_test_dialogue_sequence_running(false)
	ParleyUtils.signals.safe_disconnect(current_dialogue_ast.dialogue_ended, _on_dialogue_ended)


func _on_dialogue_ended(_dialogue_ast: ParleyDialogueSequenceAst) -> void:
	get_tree().quit()
