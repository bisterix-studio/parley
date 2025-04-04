@tool
class_name ParleyDialogueSequenceAstFormatSaver extends ResourceFormatSaver

## Returns the list of extensions available for saving the resource object,
## provided it is recognized (see _recognize).
func _recognize(resource: Resource) -> bool:
	return is_instance_of(resource, DialogueAst)

## Returns whether the given resource object can be saved by this saver.
func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return PackedStringArray(["ds"])

## Saves the given resource object to a file at the target path.
## flags is a bitmask composed with SaverFlags constants.
## Returns @GlobalScope.OK on success, or an Error constant in case of failure.
func _save(resource: Resource, path: String, flags: int) -> Error:
	if not resource:
		return ERR_INVALID_PARAMETER
	if not _recognize(resource):
		push_error("PARLEY_ERR: Unable to save resource, not a DialogueAst instance.")
		return ERR_FILE_UNRECOGNIZED
	var dialogue_ast: DialogueAst = resource
	var raw_file: Variant = FileAccess.open(path, FileAccess.WRITE)
	if not raw_file:
		var err = FileAccess.get_open_error()
		if err != OK:
			push_error("PARLEY_ERR: Cannot save GDScript file %s." % path)
			return err
		return ERR_CANT_CREATE
	var file: FileAccess = raw_file
	var dialogue_ast_raw = JSON.stringify(dialogue_ast.to_dict(), "  ", false)
	raw_file.store_string(dialogue_ast_raw)
	if (raw_file.get_error() != OK and raw_file.get_error() != ERR_FILE_EOF):
		return ERR_CANT_CREATE
	return OK
