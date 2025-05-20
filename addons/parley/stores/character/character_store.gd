@tool
# TODO: prefix with Parley
class_name CharacterStore extends StoreAst

#region DEFS
@export var characters: Array[Character] = []


const store_metadata_key: String = "character_store"


signal character_added(character: Character)
signal character_removed(character_id: String)
#endregion


#region LIFECYCLE
func _init(_id: String = "", _characters: Array[Character] = []) -> void:
	id = _id
	characters = _characters
#endregion


#region SETTERS
func _set_characters(new_characters: Array[Character]) -> void:
	var characters_with_metadata: Array[Character] = []
	for character: Character in new_characters:
		characters_with_metadata.append(_set_character_metadata(character))
	characters = characters_with_metadata


func _set_character_metadata(character: Character) -> Character:
	if character and not character.has_meta(store_metadata_key) and self.resource_path:
		character.set_meta(store_metadata_key, self.resource_path)
	return character
#endregion


#region CRUD
static func get_character_store_ref(character: Character) -> String:
	if character.has_meta(store_metadata_key):
		var store: Variant = character.get_meta(store_metadata_key)
		if is_instance_of(store, TYPE_STRING) and len(store) > 0:
			return store
	return ""


func add_character(name: String = "") -> Character:
	var character: Character = Character.new(ParleyUtils.generate.id(characters, id, name), name)
	characters.append(_set_character_metadata(character))
	character_added.emit(character)
	emit_changed()
	return character


func get_character_id_by_index(index: int) -> String:
	var character: Variant = characters.get(index)
	return character.id if character and is_instance_of(character, Character) else ParleyUtils.generate.id(characters, id, 'unknown')


func get_character_name_by_id(character_id: String) -> String:
	var filtered_characters: Array = characters.filter(func(character: Character) -> bool: return character.id == character_id)
	if filtered_characters.size() == 0:
		return 'Unknown'
	return filtered_characters.front().name


func get_character_index_by_name(name: String) -> int:
	var idx: int = 0
	for character: Character in characters:
		if character.name == name:
			return idx
		idx += 1
	return -1


func remove_character(character_id: String) -> void:
	var index_to_remove: int = characters.find_custom(func(character: Character) -> bool: return character.id == character_id)
	characters.remove_at(index_to_remove)
	character_removed.emit(character_id)
	emit_changed()

# TODO: docs

func has_character_name(name: String) -> bool:
	var filtered_characters: Array = characters.filter(func(character: Character) -> bool: return character.name == name)
	return filtered_characters.size() > 0


func get_character_by_name(name: String) -> Character:
	var filtered_characters: Array = characters.filter(func(character: Character) -> bool: return character.name == name)
	if filtered_characters.size() == 0:
		ParleyUtils.log.warn("Character with name '%s' not found in store, returning an empty Character" % [name])
		return Character.new()
	return filtered_characters.front()
#endregion


#region HELPERS
func _to_string() -> String:
	return "CharacterStore<%s>" % [str(to_dict())]
#endregion
