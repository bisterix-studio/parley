extends Node

#region General
const USER_CONFIG_PATH = "user://parley_user_config.json"
#endregion

#region Parley Plugin
const PARLEY_PLUGIN_METADATA = "ParleyManager"
const PARLEY_MANAGER_SINGLETON = "ParleyManager"
#endregion

#region Editor
# User settings
const EDITOR_CURRENT_DIALOGUE_SEQUENCE_PATH = "parley/editor/current_dialogue_sequence_path"
#endregion

#region Dialogue
# Project settings
const DIALOGUE_BALLOON_PATH = "parley/dialogue/dialogue_balloon_path"
#endregion

#region Stores
# Project settings
const ACTION_STORE_PATH = "parley/stores/action_store_path"
const CHARACTER_STORE_PATH = "parley/stores/character_store_path"
const CHARACTER_STORE_PATHS = "parley/stores/character_store_paths"
const FACT_STORE_PATH = "parley/stores/fact_store_path"
#endregion

#region Test Dialogue Sequence
# Project settings
const TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH = "parley/test_dialogue_sequence/test_scene_path"
# User settings
const TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST = "parley/test_dialogue_sequence/is_running_test_scene"
const TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH = "parley/test_dialogue_sequence/dialogue_ast_resource_path"
const TEST_DIALOGUE_SEQUENCE_FROM_START = "parley/test_dialogue_sequence/from_start"
const TEST_DIALOGUE_SEQUENCE_START_NODE_ID = "parley/test_dialogue_sequence/start_node_id"
#endregion
