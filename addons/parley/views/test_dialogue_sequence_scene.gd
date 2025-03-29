extends Node2D

var current_dialogue_ast: DialogueAst

func _ready():
	var ctx: Dictionary = {}
	var current_dialogue_ast = ParleyManager.load_test_dialogue_sequence()
	current_dialogue_ast.dialogue_ended.connect(_on_dialogue_ended)
	var start_node = ParleyManager.get_test_start_node(current_dialogue_ast)
	ParleyManager.start_dialogue(ctx, current_dialogue_ast, start_node)

func _exit_tree() -> void:
	ParleyManager.set_test_dialogue_sequence_running(false)

func _on_dialogue_ended(dialogue_ast: DialogueAst):
	get_tree().quit()
