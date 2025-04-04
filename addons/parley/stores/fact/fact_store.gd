@tool
# TODO: prefix with Parley
class_name FactStore extends StoreAst

@export var facts: Array[Fact] = []

signal fact_added(fact: Fact)

func _init(_id: String = "", _facts: Array[Fact] = []) -> void:
	id = _id
	facts = _facts

func add_fact(name: String = "") -> Fact:
	var fact: Fact = Fact.new(_generate_id(name), name)
	facts.append(fact)
	fact_added.emit(fact)
	return fact

func get_fact_id_by_index(index: int) -> String:
	var fact = facts.get(index)
	return fact.id if fact else _generate_id('unknown')

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
		ParleyUtils.log.error("Fact with name %s not found in store" % [name])
		return Fact.new()
	return filtered_facts.front()

func get_fact_by_ref(ref: String) -> Fact:
	var filtered_facts = facts.filter(func(fact): return fact.ref.resource_path == ref)
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
