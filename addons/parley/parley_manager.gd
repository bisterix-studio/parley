@tool
extends Node


#region DEFS
const ParleyConstants = preload('./constants.gd')
const ParleySettings = preload('./settings.gd')


# TODO: deprecated
var character_store: CharacterStore = CharacterStore.new()
# TODO: deprecated
var action_store: ActionStore = ActionStore.new()
# TODO: deprecated
var fact_store: FactStore = FactStore.new()
# TODO: rename to character store paths
var character_stores: Array[String]: get = _get_character_stores
var fact_stores: Array[String]: get = _get_fact_stores
var action_stores: Array[String]: get = _get_action_stores
var current_dialogue_ast: DialogueAst
var settings = ParleySettings

# TODO: expose settings in here to avoid circular dependencies

signal dialogue_imported(source_file_path: String)
#endregion


#region LIFECYCLE
func _init() -> void:
	if Engine.is_editor_hint():
		ParleySettings.prepare()
	_init_character_store()
	_init_action_store()
	_init_fact_store()
#endregion


#region GAME
## Start a dialogue session with the provided Dialogue AST
## Example: ParleyManager.start_dialogue(dialogue)
func start_dialogue(ctx: Dictionary, dialogue_ast: DialogueAst, start_node: NodeAst = null) -> Node:
	current_dialogue_ast = dialogue_ast
	var current_scene: Node = get_current_scene.call()
	var dialogue_balloon_path: String = ParleySettings.get_setting(ParleyConstants.DIALOGUE_BALLOON_PATH)
	if not ResourceLoader.exists(dialogue_balloon_path):
		ParleyUtils.log.info("Dialogue balloon does not exist at: %s. Falling back to default balloon." % [dialogue_balloon_path])
		dialogue_balloon_path = ParleySettings.DEFAULT_SETTINGS[ParleyConstants.DIALOGUE_BALLOON_PATH]
	var dialogue_balloon_scene: PackedScene = load(dialogue_balloon_path)
	var balloon: Node = dialogue_balloon_scene.instantiate()
	current_scene.add_child(balloon)
	if not current_dialogue_ast:
		ParleyUtils.log.error("No active Dialogue AST set, exiting.")
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
#endregion


#region REGISTRATIONS
func register_action_store(store: ActionStore) -> void:
	var _paths: Variant = ParleySettings.get_setting(ParleyConstants.ACTION_STORE_PATHS)
	var paths: Array[String] = []
	for path: String in _paths:
		paths.append(path)
	if not store.resource_path:
		ParleyUtils.log.error("Unable to register Action Store: no resource path defined")
		return
	var id: int = ResourceLoader.get_resource_uid(store.resource_path)
	if id == -1:
		ParleyUtils.log.error("Unable to get UID for Action Store with path: %s" % [store.resource_path])
		return
	var uid: String = ResourceUID.id_to_text(id)
	if not paths.has(uid):
		paths.append(uid)
		ParleySettings.set_setting(ParleyConstants.ACTION_STORE_PATHS, paths, true)
		ParleyUtils.log.info("Registered new Action Store: %s" % [store])

#endregion
#region GETTERS
# TODO: add check for these at startup
func _get_character_stores() -> Array[String]:
	var _paths: Variant = ParleySettings.get_setting(ParleyConstants.CHARACTER_STORE_PATHS)
	var paths: Array[String] = []
	for path: String in _paths:
		paths.append(path)
	return paths


func _get_fact_stores() -> Array[String]:
	var _paths: Variant = ParleySettings.get_setting(ParleyConstants.FACT_STORE_PATHS)
	var paths: Array[String] = []
	for path: String in _paths:
		paths.append(path)
	return paths


func _get_action_stores() -> Array[String]:
	var _paths: Variant = ParleySettings.get_setting(ParleyConstants.ACTION_STORE_PATHS)
	var paths: Array[String] = []
	for path: String in _paths:
		paths.append(path)
	return paths
#endregion


#region INIT
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
#endregion


# TODO: should this file be split into editor and non-editor files (e.g. ParleyManager, ParleyRuntime)
#region EDITOR
## Plugin use only
func set_current_dialogue_sequence(path: String) -> void:
	if not Engine.is_editor_hint():
		return
	ParleySettings.set_user_value(ParleyConstants.EDITOR_CURRENT_DIALOGUE_SEQUENCE_PATH, path)


## Plugin use only
func load_current_dialogue_sequence() -> Variant:
	if not Engine.is_editor_hint():
		return DialogueAst.new()
	var current_dialogue_sequence_path: Variant = ParleySettings.get_user_value(ParleyConstants.EDITOR_CURRENT_DIALOGUE_SEQUENCE_PATH)
	if current_dialogue_sequence_path:
		var path: String = current_dialogue_sequence_path
		if ResourceLoader.exists(path):
			return load(path)
	return null


## Plugin use only
func load_test_dialogue_sequence() -> DialogueAst:
	var current_dialogue_sequence_path = ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH)
	if current_dialogue_sequence_path and ResourceLoader.exists(current_dialogue_sequence_path):
		return load(current_dialogue_sequence_path)
	return DialogueAst.new()


## Plugin use only
func get_test_start_node(dialogue_ast: DialogueAst) -> Variant:
	var start_node_id_variant: Variant = ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID)
	var from_start = ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START)
	if not from_start and start_node_id_variant:
		return dialogue_ast.find_node_by_id(start_node_id_variant)
	return null


## Plugin use only
func is_test_dialogue_sequence_running() -> bool:
	if not Engine.is_editor_hint():
		return false
	if ParleySettings.get_setting(ParleyConstants.TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST):
		return true
	return false


## Plugin use only
func set_test_dialogue_sequence_running(_running: bool) -> void:
	if not Engine.is_editor_hint():
		return
	ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST, false)


## Plugin use only
func set_test_dialogue_sequence_start_node(node_id: Variant) -> void:
	if not Engine.is_editor_hint():
		return
	if is_instance_of(node_id, TYPE_STRING):
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID, node_id)
	elif node_id == null:
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID, null)


## Plugin use only
func run_test_dialogue_from_start(dialogue_ast: DialogueAst) -> void:
	if not Engine.is_editor_hint():
		return
	set_test_dialogue_sequence_running(true)
	ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH, dialogue_ast.resource_path)
	ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START, true)
	var test_dialogue_path: String = ParleySettings.get_setting(ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH)
	EditorInterface.play_custom_scene(test_dialogue_path)


## Plugin use only
func run_test_dialogue_from_selected(dialogue_ast: DialogueAst, selected_node_id: Variant) -> void:
	if not Engine.is_editor_hint():
		return
	set_test_dialogue_sequence_running(true)
	ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH, dialogue_ast.resource_path)
	ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START, null)
	if selected_node_id:
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID, selected_node_id)
	else:
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START, true)
	var test_dialogue_path: String = ParleySettings.get_setting(ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH)
	EditorInterface.play_custom_scene(test_dialogue_path)
#endregion
