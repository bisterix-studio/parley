# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyDialogueSequenceAstFormatSaver extends ResourceFormatSaver

## Returns the list of extensions available for saving the resource object,
## provided it is recognized (see _recognize).
func _recognize(resource: Resource) -> bool:
	return is_instance_of(resource, ParleyDialogueSequenceAst)

## Returns whether the given resource object can be saved by this saver.
func _get_recognized_extensions(_resource: Resource) -> PackedStringArray:
	return PackedStringArray(["ds"])

## Saves the given resource object to a file at the target path.
## flags is a bitmask composed with SaverFlags constants.
## Returns @GlobalScope.OK on success, or an Error constant in case of failure.
func _save(resource: Resource, path: String, _flags: int) -> Error:
	if not resource:
		return ERR_INVALID_PARAMETER
	if not _recognize(resource):
		push_error(ParleyUtils.log.error_msg("Unable to save resource, not a ParleyDialogueSequenceAst instance."))
		return ERR_FILE_UNRECOGNIZED
	var dialogue_ast: ParleyDialogueSequenceAst = resource
	var raw_file: Variant = FileAccess.open(path, FileAccess.WRITE)
	if not raw_file:
		var err: int = FileAccess.get_open_error()
		if err != OK:
			push_error(ParleyUtils.log.error_msg("Cannot save GDScript file %s." % path))
			return err as Error
		return ERR_CANT_CREATE
	var file: FileAccess = raw_file
	var dialogue_ast_raw: String = JSON.stringify(dialogue_ast.to_dict(), "  ", false)
	var _result: bool = file.store_string(dialogue_ast_raw)
	if (file.get_error() != OK and file.get_error() != ERR_FILE_EOF):
		return ERR_CANT_CREATE
	return OK
