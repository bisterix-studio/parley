@tool
extends EditorTranslationParserPlugin


func _parse_file(path: String) -> Array[PackedStringArray]:
	if not ResourceLoader.exists(path):
		return []
	var dialogue_sequence: ParleyDialogueSequenceAst = ResourceLoader.load(path, 'ParleyDialogueSequenceAst')
	var ret: Array[PackedStringArray] = []
	var uid: String = ParleyUtils.resource.get_uid(dialogue_sequence)
	for node: ParleyNodeAst in dialogue_sequence.nodes:
		if not uid:
			continue
		# TODO: handle this at the node level to be much more maintainable
		var text: Variant = node.get("text")
		if is_instance_of(text, TYPE_STRING) and text:
			# TODO: add support for nodes to have a custom translation key
			ret.append(PackedStringArray([text, ParleyUtils.translation.get_msg_ctx(uid, node, 'text')])) # id,ctx
	return ret


func _get_recognized_extensions() -> PackedStringArray:
	# TODO: is there a constant we can use?
	return ["ds"]
