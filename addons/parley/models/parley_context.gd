class_name ParleyContext extends Object


#region DEFS
## The current Dialogue Sequence AST of the Parley Context.
var dialogue_sequence_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new(): set = _set_dialogue_sequence_ast


## The translation mode of the Parley Context.
var translation_mode: TranslationMode = TranslationMode.Auto


## The data of the Parley Context.
var p_data: Dictionary = {}


## The available Translation Mode options of the Parley Context.
enum TranslationMode {
	Auto,
	PO,
	CSV,
	Off,
}


signal dialogue_ended
#endregion


#region LIFECYCLE
func _init(p_dialogue_sequence_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new(), data: Dictionary = {}) -> void:
	dialogue_sequence_ast = p_dialogue_sequence_ast
	p_data = data
#endregion


#region SETTERS
func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	if dialogue_sequence_ast != new_dialogue_sequence_ast:
		if dialogue_sequence_ast:
			ParleyUtils.signals.safe_disconnect(dialogue_sequence_ast.dialogue_ended, _on_dialogue_ended)
		dialogue_sequence_ast = new_dialogue_sequence_ast
		if new_dialogue_sequence_ast:
			ParleyUtils.signals.safe_connect(new_dialogue_sequence_ast.dialogue_ended, _on_dialogue_ended)
#endregion


#region FACTORY
static func create(p_dialogue_sequence_ast: ParleyDialogueSequenceAst, data: Dictionary = {}) -> ParleyContext:
	return ParleyContext.new(p_dialogue_sequence_ast, data)
#endregion


#region SIGNALS
func _on_dialogue_ended(_dialogue_ast: Variant) -> void:
	dialogue_ended.emit()
#endregion
