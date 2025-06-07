# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleySettings

const ParleyConstants = preload("./constants.gd")

static var DEFAULT_SETTINGS: Dictionary = {
	# Dialogue
	ParleyConstants.DIALOGUE_BALLOON_PATH: ParleyUtils.resource.get_uid(preload("./components/default_balloon.tscn")),
	# Stores
	ParleyConstants.CHARACTER_STORE_PATH: "res://characters/character_store.tres",
	ParleyConstants.ACTION_STORE_PATH: "res://actions/action_store.tres",
	ParleyConstants.FACT_STORE_PATH: "res://facts/fact_store.tres",
	# Test Dialogue Sequence
	# We can't preload this because of circular deps so let's
	# hardcode it for now but allow people to edit it in settings
	ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH: "res://addons/parley/views/test_dialogue_sequence_scene.tscn",
}


static var TYPES: Dictionary = {
	ParleyConstants.DIALOGUE_BALLOON_PATH: {
		"name": ParleyConstants.DIALOGUE_BALLOON_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
	},
	ParleyConstants.ACTION_STORE_PATH: {
		"name": ParleyConstants.ACTION_STORE_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
	},
	ParleyConstants.CHARACTER_STORE_PATH: {
		"name": ParleyConstants.CHARACTER_STORE_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
	},
	ParleyConstants.FACT_STORE_PATH: {
		"name": ParleyConstants.FACT_STORE_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
	},
	ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH: {
		"name": ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
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
		var _info: Variant = TYPES.get(setting_name)
		if is_instance_of(_info, TYPE_DICTIONARY):
			var info: Dictionary = _info
			ProjectSettings.add_property_info(info)
	
	# Reset some user values upon load that might cause weirdness:
		for key: String in [
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST,
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH,
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START,
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID,
		]:
			set_user_value(key, null)

	if save:
		var result: int = ProjectSettings.save()
		if result != OK:
			ParleyUtils.log.error("Unable to save Parley project settings: %d" % [result])


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
		ParleyUtils.log.error("Unable to save Parley user config")


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
			ParleyUtils.log.error("Unable to save Parley project settings: %d" % [result])


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
		ParleyUtils.log.error("Invalid Parley setting key. Key %s does not start with the correct scope: parley/")
		return false
	return true
