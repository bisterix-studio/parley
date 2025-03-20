@tool
# TODO: prefix with Parley
class_name CharacterStore extends StoreAst

@export var characters: Array[Character] = []

signal character_added(character: Character)

func _init(_id: String = "", _characters: Array[Character] = []) -> void:
	id = _id
	characters = _characters

func add_character(name: String = "") -> void:
	var character: Character = Character.new(_generate_id(), name)
	characters.append(character)
	character_added.emit(character)

func get_character_name_by_id(id: int) -> String:
	var filtered_characters = characters.filter(func(character): return character.id == id)
	if filtered_characters.size() == 0:
		return 'Unknown'
	return filtered_characters.front().name

#region HELPERS
func _generate_id() -> int:
	if characters.size() == 0:
		return 0
	return characters.map(func(character): return character.id).max() + 1
#endregion

func _to_string() -> String:
	return "CharacterStore<%s>" % [str(to_dict())]
