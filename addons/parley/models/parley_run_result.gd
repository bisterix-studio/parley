class_name ParleyRunResult extends Object


var dialogue_sequence: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new()


var node_asts: Array[ParleyNodeAst] = []


var finished: bool = true


func _init(p_dialogue_sequence: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new(), p_node_asts: Array[ParleyNodeAst] = [], p_finished: bool = true) -> void:
	dialogue_sequence = p_dialogue_sequence
	node_asts = p_node_asts
	finished = p_finished


static func create(p_dialogue_sequence_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new(), p_node_asts: Array[ParleyNodeAst] = []) -> ParleyRunResult:
	return ParleyRunResult.new(p_dialogue_sequence_ast, p_node_asts, false)


static func create_end(p_dialogue_sequence_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new(), p_node_asts: Array[ParleyNodeAst] = []) -> ParleyRunResult:
	return ParleyRunResult.new(p_dialogue_sequence_ast, p_node_asts, true)
