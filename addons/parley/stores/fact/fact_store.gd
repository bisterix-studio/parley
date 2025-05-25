@tool
# TODO: prefix with Parley
class_name FactStore extends ParleyStore


#region DEFS
@export var facts: Array[Fact] = []: set = _set_facts


const store_metadata_key: String = "fact_store"


signal fact_added(fact: Fact)
signal fact_removed(fact_id: String)
#endregion


#region LIFECYCLE
func _init(_id: String = "", _facts: Array[Fact] = []) -> void:
	id = _id
	facts = _facts
#endregion


#region SETTERS
func _set_facts(new_facts: Array[Fact]) -> void:
	var facts_with_metadata: Array[Fact] = []
	for fact: Fact in new_facts:
		facts_with_metadata.append(_set_fact_metadata(fact))
	facts = facts_with_metadata


func _set_fact_metadata(fact: Fact) -> Fact:
	if fact and not fact.has_meta(store_metadata_key) and self.resource_path:
		fact.set_meta(store_metadata_key, self.resource_path)
	return fact
#endregion


#region CRUD
static func get_fact_store_ref(fact: Fact) -> String:
	if fact.has_meta(store_metadata_key):
		var store: Variant = fact.get_meta(store_metadata_key)
		if is_instance_of(store, TYPE_STRING) and len(store) > 0:
			return store
	return ""


func add_fact(name: String = "") -> Fact:
	var fact: Fact = Fact.new(ParleyUtils.generate.id(facts, id, name), name)
	facts.append(_set_fact_metadata(fact))
	fact_added.emit(fact)
	emit_changed()
	return fact


func get_fact_id_by_index(index: int) -> String:
	var fact: Variant = facts.get(index)
	return fact.id if fact and is_instance_of(fact, Fact) else ParleyUtils.generate.id(facts, id, 'unknown')


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
		ParleyUtils.log.warn("Fact with name '%s' not found in store, returning an empty Fact" % [name])
		return Fact.new()
	return filtered_facts.front()


func get_fact_by_ref(ref: String) -> Fact:
	var filtered_facts: Array = facts.filter(func(fact: Fact) -> bool: return fact.ref and fact.ref.resource_path == ref)
	if filtered_facts.size() == 0:
		# TODO: is there a better way of handling this error here?
		ParleyUtils.log.warn("Fact with ref '%s' not found in store, returning an empty Fact" % [ref])
		return Fact.new()
	return filtered_facts.front()
#endregion


#region HELPERS
func _to_string() -> String:
	return "FactStore<%s>" % [str(to_dict())]
#endregion
