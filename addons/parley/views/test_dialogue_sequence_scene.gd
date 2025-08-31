# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends Node2D


var ctx: ParleyContext
var current_dialogue_ast: ParleyDialogueSequenceAst
var original_translation_server_locale: String = TranslationServer.get_locale()


func _ready() -> void:
	var test_locale: String = ParleyManager.get_instance().get_test_locale()
	if test_locale:
		TranslationServer.set_locale(test_locale)
	current_dialogue_ast = ParleyManager.get_instance().load_test_dialogue_sequence()
	ctx = ParleyContext.create(current_dialogue_ast)
	ParleyUtils.signals.safe_connect(ctx.dialogue_ended, _on_dialogue_ended)
	var start_node_variant: Variant = ParleyManager.get_instance().get_test_start_node(current_dialogue_ast)
	if start_node_variant is ParleyNodeAst:
		var start_node: ParleyNodeAst = start_node_variant
		var _node: Node = ParleyManager.get_runtime_instance().run_dialogue(ctx, current_dialogue_ast, start_node)
	else:
		var _node: Node = ParleyManager.get_runtime_instance().run_dialogue(ctx, current_dialogue_ast)


func _exit_tree() -> void:
	ParleyManager.get_instance().set_test_dialogue_sequence_running(false)
	_clear()


func _on_dialogue_ended() -> void:
	get_tree().quit()


func _clear() -> void:
	# Ensure the ctx is fully cleaned up
	if ctx:
		ParleyUtils.signals.safe_disconnect(ctx.dialogue_ended, _on_dialogue_ended)
		if not ctx.is_queued_for_deletion():
			ctx.free()
	TranslationServer.set_locale(original_translation_server_locale)
