@tool
class_name DialogueAstFormatSaver extends ResourceFormatSaver

## Returns the list of extensions available for saving the resource object,
## provided it is recognized (see _recognize).
func _recognize(resource: Resource) -> bool:
	return is_instance_of(resource, DialogueAst)

## Returns whether the given resource object can be saved by this saver.
func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return ["dlog"]

## Saves the given resource object to a file at the target path.
## flags is a bitmask composed with SaverFlags constants.
## Returns @GlobalScope.OK on success, or an Error constant in case of failure.
func _save(resource: Resource, path: String, flags: int) -> Error:
	if not _recognize(resource):
		printerr("PARLEY_ERR: Unable to save resource. Must be a DialogueAst instance.")
		return ERR_FILE_UNRECOGNIZED
	var dialogue_ast: DialogueAst = resource
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var dialogue_ast_raw = JSON.stringify(dialogue_ast.to_dict(), "  ", false)
	file.store_string(dialogue_ast_raw)
	file.close()
	return OK
