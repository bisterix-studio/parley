@tool
# TODO: prefix with Parley
class_name CharacterStore extends StoreAst

@export var characters: Array[Character] = []

signal character_added(character: Character)

func _init(_id: String = "", _characters: Array[Character] = []) -> void:
	id = _id
	characters = _characters

func add_character(name: String = "") -> Character:
	var character: Character = Character.new(_generate_id(name), name)
	characters.append(character)
	character_added.emit(character)
	return character

func get_character_id_by_index(index: int) -> String:
	var character: Variant = characters.get(index)
	return character.id if character else _generate_id('unknown')

#region HELPERS
# TODO: utils
# TODO: figure out how to make this global
func _generate_id(name: String = "") -> String:
	var local_id: String
	if not name:
		local_id = str(characters.size())
	else:
		local_id = name.to_snake_case().to_lower()
	return "%s:%s" % [id.to_snake_case().to_lower(), local_id]

func _to_string() -> String:
	return "CharacterStore<%s>" % [str(to_dict())]
#endregion
