@tool
# TODO: prefix with Parley
class_name CharacterStore extends ParleyStore

#region DEFS
@export var characters: Array[Character] = []


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
	characters = new_characters
#endregion


#region CRUD
func add_character(name: String = "") -> Character:
	var character: Character = Character.new(ParleyUtils.generate.id(characters, id, name), name)
	characters.append(character)
	character_added.emit(character)
	emit_changed()
	return character


func get_character_index_by_id(character_id: String) -> int:
	var idx: int = 0
	for character: Character in characters:
		if character.id == character_id:
			return idx
		idx += 1
	return -1


func remove_character(character_id: String) -> void:
	var index_to_remove: int = characters.find_custom(func(character: Character) -> bool: return character.id == character_id)
	characters.remove_at(index_to_remove)
	character_removed.emit(character_id)
	emit_changed()

# TODO: docs


func get_character_by_id(character_id: String) -> Character:
	var filtered_characters: Array = characters.filter(func(character: Character) -> bool: return character.id == character_id)
	if filtered_characters.size() == 0:
		if character_id != "":
			ParleyUtils.log.warn("Character with ID '%s' not found in store, returning an empty Character" % [character_id])
		return Character.new()
	return filtered_characters.front()
#endregion


#region HELPERS
func _to_string() -> String:
	return "CharacterStore<%s>" % [str(to_dict())]
#endregion
