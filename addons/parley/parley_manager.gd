@tool
extends Node

const ParleyConstants = preload('./constants.gd')
const ParleySettings = preload('./settings.gd')

# TODO: deprecated
var character_store: CharacterStore = CharacterStore.new()
# TODO: deprecated
var action_store: ActionStore = ActionStore.new()
# TODO: deprecated
var fact_store: FactStore = FactStore.new()

# TODO: rename to character store paths
var character_stores: Array[String]: get = _character_stores

var current_dialogue_ast: DialogueAst

# TODO: expose settings in here to avoid circular dependencies

signal dialogue_imported(source_file_path: String)

func _init() -> void:
	_init_character_store()
	_init_action_store()
	_init_fact_store()

## Start a dialogue session with the provided Dialogue AST
## Example: ParleyManager.start_dialogue(dialogue)
func start_dialogue(ctx: Dictionary, dialogue_ast: DialogueAst, start_node: NodeAst = null) -> Node:
	current_dialogue_ast = dialogue_ast
	var current_scene: Node = get_current_scene.call()
	var dialogue_balloon_path: String = ParleySettings.get_setting(ParleyConstants.DIALOGUE_BALLOON_PATH)
	if not ResourceLoader.exists(dialogue_balloon_path):
		print("PARLEY_DBG: Dialogue balloon does not exist at: %s. Falling back to default balloon." % [dialogue_balloon_path])
		dialogue_balloon_path = ParleySettings.DEFAULT_SETTINGS[ParleyConstants.DIALOGUE_BALLOON_PATH]
	var dialogue_balloon_scene: PackedScene = load(dialogue_balloon_path)
	var balloon: Node = dialogue_balloon_scene.instantiate()
	current_scene.add_child(balloon)
	if not current_dialogue_ast:
		printerr("PARLEY_ERR: No active Dialogue AST set, exiting.")
		return balloon
	if balloon.has_method(&"start"):
		balloon.start(ctx, current_dialogue_ast, start_node)
	else:
		# TODO: add translation for error here
		assert(false, "dialogue_balloon_scene_missing_start_method")
	return balloon

## Used to resolve the current scene.
## Override if your game manages the current scene itself.
## Example: get_current_scene.call()
var get_current_scene: Callable = func() -> Node:
	var current_scene: Node = Engine.get_main_loop().current_scene
	if current_scene == null:
		current_scene = Engine.get_main_loop().root.get_child(Engine.get_main_loop().root.get_child_count() - 1)
	return current_scene

# TODO: add check for these at startup
func _character_stores() -> Array[String]:
	var _paths = ParleySettings.get_setting(ParleyConstants.CHARACTER_STORE_PATHS)
	var paths: Array[String] = []
	for path: String in _paths:
		paths.append(path)
	return paths

func _init_character_store() -> void:
	var character_store_path = ParleySettings.get_setting(ParleyConstants.CHARACTER_STORE_PATH)
	if ResourceLoader.exists(character_store_path):
		character_store = ResourceLoader.load(character_store_path)
	else:
		character_store = CharacterStore.new()
		ResourceSaver.save(character_store, character_store_path)

func _init_action_store() -> void:
	var action_store_path = ParleySettings.get_setting(ParleyConstants.ACTION_STORE_PATH)
	if ResourceLoader.exists(action_store_path):
		action_store = ResourceLoader.load(action_store_path)
	else:
		action_store = ActionStore.new()
		ResourceSaver.save(action_store, action_store_path)

func _init_fact_store() -> void:
	var fact_store_path = ParleySettings.get_setting(ParleyConstants.FACT_STORE_PATH)
	if ResourceLoader.exists(fact_store_path):
		fact_store = ResourceLoader.load(fact_store_path)
	else:
		fact_store = FactStore.new()
		ResourceSaver.save(fact_store, fact_store_path)
