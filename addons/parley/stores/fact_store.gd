@tool
# TODO: prefix with Parley
class_name FactStore extends Resource

@export var facts: Array[Fact] = []

func add_fact(name: String = "") -> void:
	facts.append(Fact.new(_generate_id(), name))


func get_fact_name_by_id(id: int) -> String:
	var filtered_facts = facts.filter(func(fact): return fact.id == id)
	if filtered_facts.size() == 0:
		return 'Unknown'
	return filtered_facts.front().name


func get_fact_index_by_name(name: String) -> int:
	var idx = 0
	for fact in facts:
		if fact.name == name:
			return idx
		idx += 1
	return -1

# TODO: docs


func has_fact_name(name: String) -> bool:
	var filtered_facts = facts.filter(func(fact): return fact.name == name)
	return filtered_facts.size() > 0


func get_fact_by_name(name: String) -> Fact:
	var filtered_facts = facts.filter(func(fact): return fact.name == name)
	if filtered_facts.size() == 0:
		# TODO: is there a better way of handling this error here?
		printerr("PARLEY_ERR: Fact with name %s not found in store" % [name])
		return Fact.new(-1)
	return filtered_facts.front()


func get_fact_by_ref(ref: String) -> Fact:
	var filtered_facts = facts.filter(func(fact): return fact.ref.resource_path == ref)
	if filtered_facts.size() == 0:
		# TODO: is there a better way of handling this error here?
		printerr("PARLEY_ERR: Fact with ref %s not found in store" % [ref])
		return Fact.new(-1)
	return filtered_facts.front()


#region HELPERS
func _generate_id() -> int:
	if facts.size() == 0:
		return 0
	return facts.map(func(fact): return fact.id).max() + 1
#endregion
