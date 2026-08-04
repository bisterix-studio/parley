# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool


#region General
# TODO: figure out better way of getting this version as it is duplicated
const VERSION: StringName = &"2.2.0"
const AST_VERSION: StringName = &"1.1.0"
const USER_CONFIG_PATH: StringName = &"user://parley_user_config.json"
const DIALOGUE_SEQUENCE_EXTENSION: StringName = &"ds"
#endregion


#region Parley Plugin
const PLUGIN_NAME: StringName = &"Parley"
const PARLEY_PLUGIN_METADATA: StringName = &"ParleyPlugin"
const PARLEY_RUNTIME_AUTOLOAD: StringName = &"Parley"
const PARLEY_MANAGER_SINGLETON: StringName = &"ParleyManager"
const PARLEY_RUNTIME_SINGLETON: StringName = &"ParleyRuntime"
#endregion


#region Editor
# User settings
const EDITOR_CURRENT_DIALOGUE_SEQUENCE_PATH: StringName = &"parley/editor/current_dialogue_sequence_path"
const EDITOR_IS_KEYBOARD_SHORTCUTS_ACTIVE: StringName = &"parley/editor/keyboard_shortcuts"
#endregion


#region Dialogue
# Project settings
const DIALOGUE_BALLOON_PATH: StringName = &"parley/dialogue/dialogue_balloon_path"
#endregion


#region Internationalisation
# Project settings
const TRANSLATION_MODE: StringName = &"parley/translations/mode"
const TRANSLATION_CSV_HEADER_KEY: StringName = &"parley/translations/csv_header_key"
const TRANSLATION_FILES: StringName = &"internationalization/locale/translations"
const TRANSLATIONS_POT_FILES: StringName = &"internationalization/locale/translations_pot_files"
const TRANSLATION_LOCALE_TEST: StringName = &"internationalization/locale/test"
const TRANSLATION_LOCALE_FALLBACK: StringName = &"internationalization/locale/fallback"
#endregion


#region Stores
# Project settings
const ACTION_STORE_PATH: StringName = &"parley/stores/action_store_path"
const CHARACTER_STORE_PATH: StringName = &"parley/stores/character_store_path"
const FACT_STORE_PATH: StringName = &"parley/stores/fact_store_path"
#endregion


#region Test Dialogue Sequence
# Project settings
const TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH: StringName = &"parley/test_dialogue_sequence/test_scene_path"
const TEST_DEFAULT_LOCALE: StringName = &"parley/test_dialogue_sequence/default_locale"
# User settings
const TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST: StringName = &"parley/test_dialogue_sequence/is_running_test_scene"
const TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH: StringName = &"parley/test_dialogue_sequence/dialogue_ast_resource_path"
const TEST_DIALOGUE_SEQUENCE_FROM_START: StringName = &"parley/test_dialogue_sequence/from_start"
const TEST_DIALOGUE_SEQUENCE_START_NODE_ID: StringName = &"parley/test_dialogue_sequence/start_node_id"
const TEST_LOCALE: StringName = &"parley/test_dialogue_sequence/locale"
#endregion


#region Effects
#project settings
const TYPEWRITER_EFFECT : StringName = &"parley/effects/typewriter_effect"
const BEEP_SPEECH_EFFECT : StringName = &"parley/effects/beep_speech_effect"
