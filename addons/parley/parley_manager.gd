@tool
class_name ParleyManager extends Node


#region DEFS
const ParleyConstants = preload('./constants.gd')

# TODO: deprecated
var character_store: CharacterStore = CharacterStore.new()
# TODO: deprecated
var fact_store: FactStore = FactStore.new()
# TODO: rename to character store paths
var character_stores: Array[String]: get = get_character_stores
var fact_stores: Array[String]: get = get_fact_stores
var action_store: ActionStore: get = _get_action_store

# TODO: expose settings in here to avoid circular dependencies
#endregion


#region LIFECYCLE
func _init() -> void:
	if Engine.is_editor_hint():
		ParleySettings.prepare()
	_init_character_store()
	_init_fact_store()
#endregion


#region REGISTRATIONS
static func get_instance() -> ParleyManager:
	if Engine.has_singleton("ParleyManager"):
		return Engine.get_singleton("ParleyManager")
	var parley_manager: ParleyManager = ParleyManager.new()
	Engine.register_singleton("ParleyManager", parley_manager)
	return parley_manager

func register_action_store(store: ActionStore) -> void:
	var path: String = ParleySettings.get_setting(ParleyConstants.ACTION_STORE_PATH)
	var uid: String = ParleyUtils.resource.get_uid(store)
	if not uid:
		ParleyUtils.log.error("Unable to get UID for Action Store")
		return
	if path != uid:
		ParleySettings.set_setting(ParleyConstants.ACTION_STORE_PATH, uid, true)
		ParleyUtils.log.info("Registered new Action Store: %s" % [store])


func register_fact_store(store: FactStore) -> void:
	var _paths: Variant = ParleySettings.get_setting(ParleyConstants.FACT_STORE_PATHS)
	var paths: Array[String] = []
	for path: String in _paths:
		paths.append(path)
	var uid: String = ParleyUtils.resource.get_uid(store)
	if not uid:
		ParleyUtils.log.error("Unable to get UID for Fact Store")
		return
	if not paths.has(uid):
		paths.append(uid)
		ParleySettings.set_setting(ParleyConstants.FACT_STORE_PATHS, paths, true)
		ParleyUtils.log.info("Registered new Fact Store: %s" % [store])


func register_character_store(store: CharacterStore) -> void:
	var _paths: Variant = ParleySettings.get_setting(ParleyConstants.CHARACTER_STORE_PATHS)
	var paths: Array[String] = []
	for path: String in _paths:
		paths.append(path)
	var uid: String = ParleyUtils.resource.get_uid(store)
	if not uid:
		ParleyUtils.log.error("Unable to get UID for Character Store")
		return
	if not paths.has(uid):
		paths.append(uid)
		ParleySettings.set_setting(ParleyConstants.CHARACTER_STORE_PATHS, paths, true)
		ParleyUtils.log.info("Registered new Character Store: %s" % [store])
#endregion


#region GETTERS
# TODO: add check for these at startup
func get_character_stores() -> Array[String]:
	var _paths: Variant = ParleySettings.get_setting(ParleyConstants.CHARACTER_STORE_PATHS)
	var paths: Array[String] = []
	for path: String in _paths:
		paths.append(path)
	return paths


func get_fact_stores() -> Array[String]:
	var _paths: Variant = ParleySettings.get_setting(ParleyConstants.FACT_STORE_PATHS)
	var paths: Array[String] = []
	for path: String in _paths:
		paths.append(path)
	return paths


static func _get_action_store() -> ActionStore:
	var path: String = ParleySettings.get_setting(ParleyConstants.ACTION_STORE_PATH)
	if not ResourceLoader.exists(path):
		ParleyUtils.log.warn("Parley Action Store is not registered (path: %s), please register via the ParleyStores Dock. Returning in-memory Action Store, data within this Action Store will be lost upon reload." % path)
		return ActionStore.new()
	return load(path)
#endregion


#region INIT
func _init_character_store() -> void:
	var character_store_path: String = ParleySettings.get_setting(ParleyConstants.CHARACTER_STORE_PATH)
	if ResourceLoader.exists(character_store_path):
		character_store = ResourceLoader.load(character_store_path)
	else:
		character_store = CharacterStore.new()
		var _result: bool = ResourceSaver.save(character_store, character_store_path)


func _init_fact_store() -> void:
	var fact_store_path: String = ParleySettings.get_setting(ParleyConstants.FACT_STORE_PATH)
	if ResourceLoader.exists(fact_store_path):
		fact_store = ResourceLoader.load(fact_store_path)
	else:
		fact_store = FactStore.new()
		var _result: bool = ResourceSaver.save(fact_store, fact_store_path)
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
	var current_dialogue_sequence_path: String = ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH)
	if current_dialogue_sequence_path and ResourceLoader.exists(current_dialogue_sequence_path):
		return load(current_dialogue_sequence_path)
	return DialogueAst.new()


## Plugin use only
func get_test_start_node(dialogue_ast: DialogueAst) -> Variant:
	var start_node_id_variant: Variant = ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID)
	var from_start: Variant = ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START)
	if not from_start and start_node_id_variant and is_instance_of(start_node_id_variant, TYPE_STRING):
		var start_node_id: String = start_node_id_variant
		return dialogue_ast.find_node_by_id(start_node_id)
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
