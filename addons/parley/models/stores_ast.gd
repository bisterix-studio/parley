@tool
class_name StoresAst extends Resource

## The Character Stores for the Dialogue Sequence
@export var character: Array[CharacterStore] = []

func _init(_character: Array = []) -> void:
	_add_character_stores(_character)

func _add_character_stores(_character: Array) -> void:
	character = []
	for character_store: Dictionary in _character:
		var ref: String = character_store.get('ref')
		var store: CharacterStore = load(ref)
		# TODO: should we check the ID at this point to see if it has loaded correctly?
		character.append(store)

## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	var node_dict: Dictionary = inst_to_dict(self)
	node_dict.erase('@path')
	node_dict.erase('@subpath')
	node_dict['character'] = character.map(func(c: CharacterStore) -> Dictionary: return c.to_dict())
	return node_dict

## Convert this resource into a String for logging
func _to_string() -> String:
	return "StoresAst<%s>" % [str(to_dict())]
