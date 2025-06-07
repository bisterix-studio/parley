# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool

#region General
const USER_CONFIG_PATH: String = "user://parley_user_config.json"
#endregion

#region Parley Plugin
const PLUGIN_NAME: String = "Parley"
const PARLEY_PLUGIN_METADATA: String = "ParleyPlugin"
const PARLEY_RUNTIME_AUTOLOAD: String = "Parley"
const PARLEY_MANAGER_SINGLETON: String = "ParleyManager"
const PARLEY_RUNTIME_SINGLETON: String = "ParleyRuntime"
#endregion

#region Editor
# User settings
const EDITOR_CURRENT_DIALOGUE_SEQUENCE_PATH: String = "parley/editor/current_dialogue_sequence_path"
#endregion

#region Dialogue
# Project settings
const DIALOGUE_BALLOON_PATH: String = "parley/dialogue/dialogue_balloon_path"
#endregion

#region Stores
# Project settings
const ACTION_STORE_PATH: String = "parley/stores/action_store_path"
const CHARACTER_STORE_PATH: String = "parley/stores/character_store_path"
const CHARACTER_STORE_PATHS: String = "parley/stores/character_store_paths"
const FACT_STORE_PATHS: String = "parley/stores/fact_store_paths"
const FACT_STORE_PATH: String = "parley/stores/fact_store_path"
#endregion

#region Test Dialogue Sequence
# Project settings
const TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH: String = "parley/test_dialogue_sequence/test_scene_path"
# User settings
const TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST: String = "parley/test_dialogue_sequence/is_running_test_scene"
const TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH: String = "parley/test_dialogue_sequence/dialogue_ast_resource_path"
const TEST_DIALOGUE_SEQUENCE_FROM_START: String = "parley/test_dialogue_sequence/from_start"
const TEST_DIALOGUE_SEQUENCE_START_NODE_ID: String = "parley/test_dialogue_sequence/start_node_id"
#endregion
