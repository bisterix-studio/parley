# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyManager extends Node


#region DEFS
const ParleyConstants = preload('./constants.gd')

var fact_store: ParleyFactStore:
	set = _set_fact_store,
	get = _get_fact_store
var character_store: ParleyCharacterStore:
	set = _set_character_store,
	get = _get_character_store
var action_store: ParleyActionStore:
	set = _set_action_store,
	get = _get_action_store
#endregion


#region LIFECYCLE
func _init() -> void:
	if Engine.is_editor_hint():
		ParleySettings.prepare()
#endregion


#region REGISTRATIONS
static func get_instance() -> ParleyManager:
	if Engine.has_singleton(ParleyConstants.PARLEY_MANAGER_SINGLETON):
		return Engine.get_singleton(ParleyConstants.PARLEY_MANAGER_SINGLETON)
	var parley_manager: ParleyManager = ParleyManager.new()
	Engine.register_singleton(ParleyConstants.PARLEY_MANAGER_SINGLETON, parley_manager)
	return parley_manager

func register_action_store(store: ParleyActionStore) -> void:
	var path: String = ParleySettings.get_setting(ParleyConstants.ACTION_STORE_PATH)
	var uid: String = ParleyUtils.resource.get_uid(store)
	if not uid:
		ParleyUtils.log.error("Unable to get UID for Action Store")
		return
	if path != uid:
		ParleySettings.set_setting(ParleyConstants.ACTION_STORE_PATH, uid, true)
		ParleyUtils.log.info("Registered new Action Store: %s" % [store])
	action_store = store


func register_fact_store(store: ParleyFactStore) -> void:
	var path: String = ParleySettings.get_setting(ParleyConstants.FACT_STORE_PATH)
	var uid: String = ParleyUtils.resource.get_uid(store)
	if not uid:
		ParleyUtils.log.error("Unable to get UID for Fact Store")
		return
	if path != uid:
		ParleySettings.set_setting(ParleyConstants.FACT_STORE_PATH, uid, true)
		ParleyUtils.log.info("Registered new Fact Store: %s" % [store])
	fact_store = store


func register_character_store(store: ParleyCharacterStore) -> void:
	var path: String = ParleySettings.get_setting(ParleyConstants.CHARACTER_STORE_PATH)
	var uid: String = ParleyUtils.resource.get_uid(store)
	if not uid:
		ParleyUtils.log.error("Unable to get UID for Character Store")
		return
	if path != uid:
		ParleySettings.set_setting(ParleyConstants.CHARACTER_STORE_PATH, uid, true)
		ParleyUtils.log.info("Registered new Character Store: %s" % [store])
	character_store = store
#endregion


#region SETTERS
func _set_action_store(new_action_store: ParleyActionStore) -> void:
	action_store = new_action_store


func _set_fact_store(new_fact_store: ParleyFactStore) -> void:
	fact_store = new_fact_store


func _set_character_store(new_character_store: ParleyCharacterStore) -> void:
	character_store = new_character_store
#endregion


#region GETTERS
func _get_action_store() -> ParleyActionStore:
	var path: String = ParleySettings.get_setting(ParleyConstants.ACTION_STORE_PATH)
	if not ResourceLoader.exists(path):
		if not action_store:
			ParleyUtils.log.warn("Parley Action Store is not registered (path: %s), please register via the ParleyStores Dock. Returning in-memory Action Store, data within this Action Store will be lost upon reload." % path)
			action_store = ParleyActionStore.new()
		return action_store
	if not action_store:
		action_store = load(path)
	# Ensure that the store path is resilient to changes
	if path == ParleySettings.DEFAULT_SETTINGS[ParleyConstants.ACTION_STORE_PATH]:
		register_action_store(action_store)
	return action_store


func _get_character_store() -> ParleyCharacterStore:
	var path: String = ParleySettings.get_setting(ParleyConstants.CHARACTER_STORE_PATH)
	if not ResourceLoader.exists(path):
		if not character_store:
			ParleyUtils.log.warn("Parley Character Store is not registered (path: %s), please register via the ParleyStores Dock. Returning in-memory Character Store, data within this Character Store will be lost upon reload." % path)
			character_store = ParleyCharacterStore.new()
		return character_store
	if not character_store:
		character_store = load(path)
	# Ensure that the store path is resilient to changes
	if path == ParleySettings.DEFAULT_SETTINGS[ParleyConstants.CHARACTER_STORE_PATH]:
		register_character_store(character_store)
	return character_store


func _get_fact_store() -> ParleyFactStore:
	var path: String = ParleySettings.get_setting(ParleyConstants.FACT_STORE_PATH)
	if not ResourceLoader.exists(path):
		if not fact_store:
			ParleyUtils.log.warn("Parley Fact Store is not registered (path: %s), please register via the ParleyStores Dock. Returning in-memory Fact Store, data within this Fact Store will be lost upon reload." % path)
			fact_store = ParleyFactStore.new()
		return fact_store
	if not fact_store:
		fact_store = load(path)
	# Ensure that the store path is resilient to changes
	if path == ParleySettings.DEFAULT_SETTINGS[ParleyConstants.FACT_STORE_PATH]:
		register_fact_store(fact_store)
	return fact_store
#endregion


# TODO: should this file be split into editor and non-editor files (e.g. ParleyManager, ParleyRuntime)
#region EDITOR
## Plugin use only
func set_current_dialogue_sequence(path: Variant) -> void:
	if not Engine.is_editor_hint():
		return
	ParleySettings.set_user_value(ParleyConstants.EDITOR_CURRENT_DIALOGUE_SEQUENCE_PATH, path)


## Plugin use only
func load_current_dialogue_sequence() -> Variant:
	if not Engine.is_editor_hint():
		return ParleyDialogueSequenceAst.new()
	var current_dialogue_sequence_path: Variant = ParleySettings.get_user_value(ParleyConstants.EDITOR_CURRENT_DIALOGUE_SEQUENCE_PATH)
	if current_dialogue_sequence_path:
		var path: String = current_dialogue_sequence_path
		if ResourceLoader.exists(path):
			return load(path)
	return null


## Plugin use only
func load_test_dialogue_sequence() -> ParleyDialogueSequenceAst:
	var current_dialogue_sequence_path: String = ParleySettings.get_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH)
	if current_dialogue_sequence_path and ResourceLoader.exists(current_dialogue_sequence_path):
		return load(current_dialogue_sequence_path)
	return ParleyDialogueSequenceAst.new()


## Plugin use only
func get_test_start_node(dialogue_ast: ParleyDialogueSequenceAst) -> Variant:
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
func run_test_dialogue_from_start(dialogue_ast: ParleyDialogueSequenceAst) -> void:
	if not Engine.is_editor_hint():
		return
	set_test_dialogue_sequence_running(true)
	ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH, dialogue_ast.resource_path)
	ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START, true)
	var test_dialogue_path: String = ParleySettings.get_setting(ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH)
	EditorInterface.play_custom_scene(load(test_dialogue_path).resource_path)


## Plugin use only
func run_test_dialogue_from_selected(dialogue_ast: ParleyDialogueSequenceAst, selected_node_id: Variant) -> void:
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
	EditorInterface.play_custom_scene(load(test_dialogue_path).resource_path)
#endregion
