# TODO: prefix with Parley
class_name DialogueTestScene extends Node2D

const ParleyConstants = preload("../constants.gd")
const ParleySettings = preload("../settings.gd")


var current_dialogue_ast: DialogueAst


func _ready():
	if not ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH):
		return
	current_dialogue_ast = load(ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH))
	current_dialogue_ast.dialogue_ended.connect(_on_dialogue_ended)
	var start_node
	var start_node_id = ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID)
	var from_start = ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START)
	if not from_start and start_node_id:
		start_node = current_dialogue_ast.find_node_by_id(start_node_id)
	ParleyManager.start_dialogue({}, current_dialogue_ast, start_node)


func _exit_tree() -> void:
	ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST, false)


func _on_dialogue_ended(dialogue_ast: DialogueAst):
	get_tree().quit()
