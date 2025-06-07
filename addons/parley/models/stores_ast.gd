@tool
class_name StoresAst extends Resource


## The Character Stores for the Dialogue Sequence
@export var character: Array[ParleyCharacterStore] = []


## The Fact Stores for the Dialogue Sequence
@export var fact: Array[ParleyFactStore] = []


func _init(_character: Array = [], _fact: Array = []) -> void:
	_add_character_stores(_character)
	_add_fact_stores(_fact)


## Register an existing character store
func register_character_store(character_store: ParleyCharacterStore) -> void:
	character.append(character_store)
	emit_changed()


## Register a new character store
func new_character_store(id: String, ref: String, characters: Array[ParleyCharacter] = []) -> Variant:
	var character_store: ParleyCharacterStore = ParleyCharacterStore.new(id, characters)
	var save_result: int = ResourceSaver.save(character_store, ref)
	if save_result != OK:
		push_error("Error registering new character store: %s" % [save_result])
		return null
	character.append(character_store)
	emit_changed()
	return character_store


## Register an existing fact store
func register_fact_store(fact_store: ParleyFactStore) -> void:
	fact.append(fact_store)
	emit_changed()


## Register a new fact store
func new_fact_store(id: String, ref: String, facts: Array[ParleyFact] = []) -> Variant:
	var fact_store: ParleyFactStore = ParleyFactStore.new(id, facts)
	var save_result: int = ResourceSaver.save(fact_store, ref)
	if save_result != OK:
		push_error("Error registering new fact store: %s" % [save_result])
		return null
	fact.append(fact_store)
	emit_changed()
	return fact_store


## Add character stores from a dictionary
func _add_character_stores(_character: Array) -> void:
	character = []
	for character_store: Dictionary in _character:
		var ref: String = character_store.get('ref')
		var store: ParleyCharacterStore = load(ref)
		# TODO: should we check the ID at this point to see if it has loaded correctly?
		character.append(store)


## Add fact stores from a dictionary
func _add_fact_stores(_fact: Array) -> void:
	fact = []
	for fact_store: Dictionary in _fact:
		var ref: String = fact_store.get('ref')
		var store: ParleyFactStore = load(ref)
		# TODO: should we check the ID at this point to see if it has loaded correctly?
		fact.append(store)


## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	var node_dict: Dictionary = inst_to_dict(self)
	var _ok_path: bool = node_dict.erase('@path')
	var _ok_subpath: bool = node_dict.erase('@subpath')
	node_dict['character'] = character.map(func(c: ParleyCharacterStore) -> Dictionary: return c.to_dict())
	node_dict['fact'] = fact.map(func(f: ParleyFactStore) -> Dictionary: return f.to_dict())
	return node_dict


## Convert this resource into a String for logging
func _to_string() -> String:
	return "StoresAst<%s>" % [str(to_dict())]
