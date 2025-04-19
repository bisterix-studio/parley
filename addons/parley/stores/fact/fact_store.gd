@tool
# TODO: prefix with Parley
class_name FactStore extends StoreAst


@export var facts: Array[Fact] = []: set = _set_facts


const store_metadata_key: String = "store"


signal fact_added(fact: Fact)
signal fact_removed(fact_id: String)


func _init(_id: String = "", _facts: Array[Fact] = []) -> void:
	id = _id
	facts = _facts


func _set_facts(new_facts: Array[Fact]) -> void:
	var facts_with_metadata: Array[Fact] = []
	for fact: Fact in new_facts:
		facts_with_metadata.append(_set_fact_metadata(fact))
	facts = facts_with_metadata


func _set_fact_metadata(fact: Fact) -> Fact:
	if fact and not fact.has_meta(store_metadata_key) and self.resource_path:
		fact.set_meta(store_metadata_key, self.resource_path)
	return fact


static func get_fact_store_ref(fact: Fact) -> String:
	if fact.has_meta(store_metadata_key):
		var store: Variant = fact.get_meta(store_metadata_key)
		if is_instance_of(store, TYPE_STRING) and len(store) > 0:
			return store
	return ""


func add_fact(name: String = "") -> Fact:
	var fact: Fact = Fact.new(_generate_id(name), name)
	facts.append(_set_fact_metadata(fact))
	fact_added.emit(fact)
	emit_changed()
	return fact


func get_fact_id_by_index(index: int) -> String:
	var fact: Variant = facts.get(index)
	return fact.id if fact and is_instance_of(fact, Fact) else _generate_id('unknown')


func get_fact_name_by_id(fact_id: String) -> String:
	var filtered_facts: Array = facts.filter(func(fact: Fact) -> bool: return fact.id == fact_id)
	if filtered_facts.size() == 0:
		return 'Unknown'
	return filtered_facts.front().name


func get_fact_index_by_name(name: String) -> int:
	var idx: int = 0
	for fact: Fact in facts:
		if fact.name == name:
			return idx
		idx += 1
	return -1


func remove_fact(fact_id: String) -> void:
	var index_to_remove: int = facts.find_custom(func(fact: Fact) -> bool: return fact.id == fact_id)
	facts.remove_at(index_to_remove)
	fact_removed.emit(fact_id)
	emit_changed()

# TODO: docs

func has_fact_name(name: String) -> bool:
	var filtered_facts: Array = facts.filter(func(fact: Fact) -> bool: return fact.name == name)
	return filtered_facts.size() > 0


func get_fact_by_name(name: String) -> Fact:
	var filtered_facts: Array = facts.filter(func(fact: Fact) -> bool: return fact.name == name)
	if filtered_facts.size() == 0:
		# TODO: is there a better way of handling this error here?
		ParleyUtils.log.error("Fact with name %s not found in store" % [name])
		return Fact.new()
	return filtered_facts.front()


func get_fact_by_ref(ref: String) -> Fact:
	var filtered_facts: Array = facts.filter(func(fact: Fact) -> bool: return fact.ref and fact.ref.resource_path == ref)
	if filtered_facts.size() == 0:
		# TODO: is there a better way of handling this error here?
		ParleyUtils.log.error("Fact with ref %s not found in store" % [ref])
		return Fact.new()
	return filtered_facts.front()

#region HELPERS
# TODO: utils
func _generate_id(name: String = "") -> String:
	var local_id: String
	if not name:
		local_id = str(facts.size())
	else:
		local_id = name.to_snake_case().to_lower()
	return "%s:%s" % [id.to_snake_case().to_lower(), local_id]


func _to_string() -> String:
	return "FactStore<%s>" % [str(to_dict())]
#endregion
