extends Node2D

var current_dialogue_ast: DialogueAst

func _ready() -> void:
	var ctx: Dictionary = {}
	# TODO: can we get rid of this global ref?
	if not Engine.has_singleton("ParleyRuntime"):
		return
	current_dialogue_ast = ParleyManager.get_instance().load_test_dialogue_sequence()
	ParleyUtils.signals.safe_connect(current_dialogue_ast.dialogue_ended, _on_dialogue_ended)
	# TODO: can we get rid of this global ref?
	var start_node_variant: Variant = ParleyManager.get_instance().get_test_start_node(current_dialogue_ast)
	if start_node_variant is NodeAst:
		var start_node: NodeAst = start_node_variant
		# TODO: can we get rid of this global ref?
		var _node: Node = Engine.get_singleton("ParleyRuntime").start_dialogue(ctx, current_dialogue_ast, start_node)
	else:
		# TODO: can we get rid of this global ref?
		var _node: Node = Engine.get_singleton("ParleyRuntime").start_dialogue(ctx, current_dialogue_ast)


func _exit_tree() -> void:
	# TODO: can we get rid of this global ref?
	ParleyManager.get_instance().set_test_dialogue_sequence_running(false)
	ParleyUtils.signals.safe_disconnect(current_dialogue_ast.dialogue_ended, _on_dialogue_ended)

func _on_dialogue_ended(_dialogue_ast: DialogueAst) -> void:
	get_tree().quit()
