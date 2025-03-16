@tool
# TODO: prefix with Parley
class_name CharacterStore extends Resource

@export var characters: Array[Character] = []

func add_character(name: String = "") -> void:
	characters.append(Character.new(_generate_id(), name))


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
