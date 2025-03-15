@tool
extends Node

const ParleyConstants = preload("./constants.gd")

### Editor config

const DEFAULT_SETTINGS = {
	# Dialogue
	ParleyConstants.DIALOGUE_BALLOON_PATH: preload("./components/default_balloon.tscn").resource_path,
	# Stores
	ParleyConstants.ACTION_STORE_PATH: "res://actions/action_store.tres",
	ParleyConstants.CHARACTER_STORE_PATH: "res://characters/character_store.tres",
	ParleyConstants.FACT_STORE_PATH: "res://facts/fact_store.tres",
	# Test Dialogue Sequence
	# We can't preload this because of circular deps so let's
	# hardcode it for now but allow people to edit it in settings
	ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH: "res://addons/parley/views/test_dialogue_sequence_scene.tscn"
}


static func prepare() -> void:
	# Set up initial settings
	for setting_name in DEFAULT_SETTINGS:
		if not validate_setting_key(setting_name):
			continue
		if not ProjectSettings.has_setting(setting_name):
			set_setting(setting_name, DEFAULT_SETTINGS[setting_name])
		ProjectSettings.set_initial_value(setting_name, DEFAULT_SETTINGS[setting_name])
		if setting_name.ends_with("_path"):
			ProjectSettings.add_property_info({
				"name": setting_name,
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_FILE,
			})
	
	# Reset some user values upon load that might cause weirdness:
		for key in [
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST,
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH,
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START,
			ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID,
		]:
			set_user_value(key, null)

	ProjectSettings.save()


static func get_user_config() -> Dictionary:
	var user_config: Dictionary = {
		run_resource_path = "",
	}

	if FileAccess.file_exists(ParleyConstants.USER_CONFIG_PATH):
		var file: FileAccess = FileAccess.open(ParleyConstants.USER_CONFIG_PATH, FileAccess.READ)
		user_config.merge(JSON.parse_string(file.get_as_text()), true)

	return user_config


static func save_user_config(user_config: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(ParleyConstants.USER_CONFIG_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(user_config))


static func set_user_value(key: String, value) -> void:
	var user_config: Dictionary = get_user_config()
	user_config[key] = value
	save_user_config(user_config)


static func get_user_value(key: String, default = null):
	return get_user_config().get(key, default)


static func set_setting(key: String, value) -> void:
	if not validate_setting_key(key):
		return
	ProjectSettings.set_setting(key, value)
	ProjectSettings.set_initial_value(key, DEFAULT_SETTINGS[key])
	ProjectSettings.save()


static func get_setting(key: String, default = null):
	if not validate_setting_key(key):
		return

	if ProjectSettings.has_setting(key):
		return ProjectSettings.get_setting(key)
	if default:
		return default
	return DEFAULT_SETTINGS.get(key)


static func validate_setting_key(key: String) -> bool:
	if not key.begins_with("parley/"):
		printerr("PARLEY_ERR: Invalid Parley setting key. Key %s does not start with the correct scope: parley/")
		return false
	return true
