@tool
extends EditorTranslationParserPlugin


const ParleyConstants = preload("./constants.gd")


func _parse_file(path: String) -> Array[PackedStringArray]:
	if not ResourceLoader.exists(path):
		return []
	var dialogue_sequence: ParleyDialogueSequenceAst = ResourceLoader.load(path, 'ParleyDialogueSequenceAst')
	var ret: Array[PackedStringArray] = []
	var uid: String = ParleyUtils.resource.get_uid(dialogue_sequence)
	for node: ParleyNodeAst in dialogue_sequence.nodes:
		if not uid:
			continue
		ret.append_array(node.get_translation_strings())
	return ret


func _get_recognized_extensions() -> PackedStringArray:
	return [ParleyConstants.DIALOGUE_SEQUENCE_EXTENSION]
