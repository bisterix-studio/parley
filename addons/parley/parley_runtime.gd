# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyRuntime extends Node


#region DEFS
const ParleyConstants = preload('./constants.gd')
#endregion


#region REGISTRATIONS
static func get_instance() -> ParleyRuntime:
	if Engine.has_singleton(ParleyConstants.PARLEY_RUNTIME_SINGLETON):
		return Engine.get_singleton(ParleyConstants.PARLEY_RUNTIME_SINGLETON)
	var parley_runtime: ParleyRuntime = ParleyRuntime.new()
	Engine.register_singleton(ParleyConstants.PARLEY_RUNTIME_SINGLETON, parley_runtime)
	return parley_runtime
#endregion


#region GAME
## Run a dialogue session with the provided Dialogue Sequence AST
## Example: parley_runtime.run_dialogue(ctx, dialogue_sequence_ast)
func run_dialogue(ctx: ParleyContext, dialogue_sequence_ast: ParleyDialogueSequenceAst, start_node: ParleyNodeAst = null) -> Node:
	# TODO: maybe pass this in instead of getting from the engine - gives us a bit more flexibility
	var current_scene: Node = _get_current_scene()
	var dialogue_balloon_path: String = ParleySettings.get_setting(ParleyConstants.DIALOGUE_BALLOON_PATH)
	if not ResourceLoader.exists(dialogue_balloon_path):
		print_rich(ParleyUtils.log.info_msg("Dialogue balloon does not exist at: %s. Falling back to default balloon." % [dialogue_balloon_path]))
		dialogue_balloon_path = ParleySettings.DEFAULT_SETTINGS[ParleyConstants.DIALOGUE_BALLOON_PATH]
	var dialogue_balloon_scene: PackedScene = load(dialogue_balloon_path)
	var balloon: Node = dialogue_balloon_scene.instantiate()
	current_scene.add_child(balloon)
	if not dialogue_sequence_ast:
		push_error(ParleyUtils.log.error_msg("No active Dialogue AST set, exiting."))
		return balloon
	if balloon.has_method(&"start"):
		@warning_ignore("UNSAFE_METHOD_ACCESS") # Covered by the if statement
		balloon.start(ctx, dialogue_sequence_ast, start_node)
	else:
		# TODO: add translation for error here
		assert(false, "Dialogue balloon is missing the `start` method can cannot execute the Dialogue Sequence")
	return balloon


func _get_current_scene() -> Node:
	@warning_ignore("UNSAFE_PROPERTY_ACCESS")
	var current_scene: Node = Engine.get_main_loop().current_scene
	if current_scene == null:
		@warning_ignore("UNSAFE_PROPERTY_ACCESS")
		@warning_ignore("UNSAFE_METHOD_ACCESS")
		current_scene = Engine.get_main_loop().root.get_child(Engine.get_main_loop().root.get_child_count() - 1)
	return current_scene
#endregion
