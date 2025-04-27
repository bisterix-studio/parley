extends Node2D

var current_dialogue_ast: DialogueAst

func _ready() -> void:
	var ctx: Dictionary = {}
	current_dialogue_ast = ParleyManager.load_test_dialogue_sequence()
	ParleyUtils.safe_connect(current_dialogue_ast.dialogue_ended, _on_dialogue_ended)
	var start_node_variant: Variant = ParleyManager.get_test_start_node(current_dialogue_ast)
	if start_node_variant is NodeAst:
		var start_node: NodeAst = start_node_variant
		var _node: Node = ParleyManager.start_dialogue(ctx, current_dialogue_ast, start_node)
	else:
		var _node: Node = ParleyManager.start_dialogue(ctx, current_dialogue_ast)


func _exit_tree() -> void:
	ParleyManager.set_test_dialogue_sequence_running(false)
	ParleyUtils.safe_disconnect(current_dialogue_ast.dialogue_ended, _on_dialogue_ended)

func _on_dialogue_ended(_dialogue_ast: DialogueAst) -> void:
	get_tree().quit()
