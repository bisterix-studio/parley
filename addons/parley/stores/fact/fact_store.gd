# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyFactStore extends ParleyStore


#region DEFS
@export var facts: Array[ParleyFact] = []: set = _set_facts


signal fact_added(fact: ParleyFact)
signal fact_removed(fact_id: String)
#endregion


#region LIFECYCLE
func _init(_id: String = "", _facts: Array[ParleyFact] = []) -> void:
	id = _id
	facts = _facts
#endregion


#region SETTERS
func _set_facts(new_facts: Array[ParleyFact]) -> void:
	facts = new_facts
#endregion


#region CRUD
func add_fact(name: String = "") -> ParleyFact:
	var fact: ParleyFact = ParleyFact.new(ParleyUtils.generate.id(facts, id, name), name)
	facts.append(fact)
	fact_added.emit(fact)
	emit_changed()
	return fact


func get_fact_index_by_ref(ref: String) -> int:
	var idx: int = 0
	for fact: ParleyFact in facts:
		if ParleyUtils.resource.get_uid(fact.ref) == ref:
			return idx
		idx += 1
	return -1


func remove_fact(fact_id: String) -> void:
	var index_to_remove: int = facts.find_custom(func(fact: ParleyFact) -> bool: return fact.id == fact_id)
	facts.remove_at(index_to_remove)
	fact_removed.emit(fact_id)
	emit_changed()


# TODO: docs


func get_fact_by_ref(ref: String) -> ParleyFact:
	var filtered_facts: Array = facts.filter(func(fact: ParleyFact) -> bool:
		return fact.ref and ParleyUtils.resource.get_uid(fact.ref) == ref)
	if filtered_facts.size() == 0:
		if ref != "":
			push_warning(ParleyUtils.log.warn_msg("Fact with ref not found in store (store:%s, ref:%s), returning an empty Fact" % [id, ref]))
		return ParleyFact.new()
	return filtered_facts.front()
#endregion


#region HELPERS
func _to_string() -> String:
	return "ParleyFactStore<%s>" % [str(to_dict())]
#endregion
