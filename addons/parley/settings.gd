# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleySettings

const ParleyConstants = preload("./constants.gd")

static var DEFAULT_SETTINGS: Dictionary = {
	# Dialogue
	# Path: res://addons/parley/components/default_balloon.tscn
	# This must be hard-coded here otherwise, we get compilation errors in the autoload
	ParleyConstants.DIALOGUE_BALLOON_PATH: "uid://cf8jukut3b8qq",
	# Stores
	ParleyConstants.CHARACTER_STORE_PATH: "res://characters/character_store.tres",
	ParleyConstants.ACTION_STORE_PATH: "res://actions/action_store.tres",
	ParleyConstants.FACT_STORE_PATH: "res://facts/fact_store.tres",
	# Internationalisation
	ParleyConstants.TRANSLATION_MODE: ParleyContext.TranslationMode.keys()[ParleyContext.TranslationMode.PO],
	ParleyConstants.TRANSLATION_CSV_HEADER_KEY: &"keys",
	# Test Dialogue Sequence
	# We can't preload this because of circular deps so let's
	# hardcode it for now but allow people to edit it in settings
	ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH: "res://addons/parley/views/test_dialogue_sequence_scene.tscn",
	ParleyConstants.TEST_DEFAULT_LOCALE: "",
}


static var TYPES: Dictionary = {
	# Dialogue
	ParleyConstants.DIALOGUE_BALLOON_PATH: {
		"name": ParleyConstants.DIALOGUE_BALLOON_PATH,
		"description": "Defines the path to the default Dialogue balloon that is used to render the dialogue when testing and running Dialogue Sequences.",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
	},
	# Stores
	ParleyConstants.ACTION_STORE_PATH: {
		"name": ParleyConstants.ACTION_STORE_PATH,
		"description": "Defines the path to the Action Store resource that is used to store actions.",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
	},
	ParleyConstants.CHARACTER_STORE_PATH: {
		"name": ParleyConstants.CHARACTER_STORE_PATH,
		"description": "Defines the path to the Character Store resource that is used to store characters.",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
	},
	ParleyConstants.FACT_STORE_PATH: {
		"name": ParleyConstants.FACT_STORE_PATH,
		"description": "Defines the path to the Fact Store resource that is used to store facts.",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
	},
	# Internationalisation
	ParleyConstants.TRANSLATION_MODE: {
		"name": ParleyConstants.TRANSLATION_MODE,
		"description": "Defines the translation mode to determine how to find and interpret translations.",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(ParleyContext.TranslationMode.keys())
	},
	ParleyConstants.TRANSLATION_CSV_HEADER_KEY: {
		"name": ParleyConstants.TRANSLATION_CSV_HEADER_KEY,
		"description": "Defines the translation header key for use in CSV translation files. By default, this is 'keys'.",
		"type": TYPE_STRING_NAME,
	},
	# Testing
	ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH: {
		"name": ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH,
		"description": "Defines the path to the default test scene that is rendered when testing Dialogue Sequences.",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
	},
	ParleyConstants.TEST_DEFAULT_LOCALE: {
		"name": ParleyConstants.TEST_DEFAULT_LOCALE,
		"description": "Defines the default locale that will be used when testing Dialogue Sequences.",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_LOCALE_ID
	}
}


static func prepare(save: bool = true) -> void:
	# Set up initial settings
	for setting_name: String in DEFAULT_SETTINGS:
		if not validate_setting_key(setting_name):
			continue
		if not ProjectSettings.has_setting(setting_name):
			set_setting(setting_name, DEFAULT_SETTINGS[setting_name])
		ProjectSettings.set_initial_value(setting_name, DEFAULT_SETTINGS[setting_name])
		var info_variant: Variant = TYPES.get(setting_name)
		if is_instance_of(info_variant, TYPE_DICTIONARY):
			var info: Dictionary = info_variant
			ProjectSettings.add_property_info(info)
	
	# Reset some user values upon load that might cause weirdness:
		for key: String in [
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST,
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH,
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START,
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID,
			ParleyConstants.TEST_LOCALE,
		]:
			set_user_value(key, null)

	if save:
		var result: int = ProjectSettings.save()
		if result != OK:
			push_error(ParleyUtils.log.error_msg("Unable to save Parley project settings: %d" % [result]))


static func get_user_config() -> Dictionary:
	var user_config: Dictionary = {
		run_resource_path = "",
	}

	if FileAccess.file_exists(ParleyConstants.USER_CONFIG_PATH):
		var file: FileAccess = FileAccess.open(ParleyConstants.USER_CONFIG_PATH, FileAccess.READ)
		var parsed_string: Dictionary = JSON.parse_string(file.get_as_text())
		user_config.merge(parsed_string, true)

	return user_config


static func save_user_config(user_config: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(ParleyConstants.USER_CONFIG_PATH, FileAccess.WRITE)
	var result: bool = file.store_string(JSON.stringify(user_config))
	if not result:
		push_error(ParleyUtils.log.error_msg("Unable to save Parley user config"))


static func set_user_value(key: String, value: Variant) -> void:
	var user_config: Dictionary = get_user_config()
	user_config[key] = value
	save_user_config(user_config)


static func get_user_value(key: String, default: Variant = null) -> Variant:
	return get_user_config().get(key, default)


static func set_setting(key: String, value: Variant, save: bool = false) -> void:
	if not validate_setting_key(key):
		return
	ProjectSettings.set_setting(key, value)
	ProjectSettings.set_initial_value(key, DEFAULT_SETTINGS[key])
	if save:
		var result: int = ProjectSettings.save()
		if result != OK:
			push_error(ParleyUtils.log.error_msg("Unable to save Parley project settings: %d" % [result]))


static func get_setting(key: String, default: Variant = null) -> Variant:
	if not validate_setting_key(key):
		return

	if ProjectSettings.has_setting(key):
		return ProjectSettings.get_setting(key)
	if default:
		return default
	return DEFAULT_SETTINGS.get(key)


static func validate_setting_key(key: String) -> bool:
	if not key.begins_with("parley/"):
		push_error(ParleyUtils.log.error_msg("Invalid Parley setting key. Key %s does not start with the correct scope: parley/"))
		return false
	return true
