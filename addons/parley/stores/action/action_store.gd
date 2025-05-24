@tool
# TODO: prefix with Parley
class_name ActionStore extends ParleyStore


#region DEFS
@export var actions: Array[Action] = []: set = _set_actions


signal action_added(action: Action)
signal action_removed(action_id: String)
#endregion


#region LIFECYCLE
func _init(_id: String = "", _actions: Array[Action] = []) -> void:
	id = _id
	actions = _actions
#endregion


#region SETTERS
func _set_actions(new_actions: Array[Action]) -> void:
	actions = new_actions
#endregion


#region CRUD
func add_action(name: String = "") -> Action:
	var action: Action = Action.new(ParleyUtils.generate.id(actions, id, name), name)
	action_added.emit(action)
	emit_changed()
	return action


func get_action_index_by_ref(ref: String) -> int:
	var idx: int = 0
	for action: Action in actions:
		if ParleyUtils.resource.get_uid(action.ref) == ref:
			return idx
		idx += 1
	return -1


func remove_action(action_id: String) -> void:
	var index_to_remove: int = actions.find_custom(func(action: Action) -> bool: return action.id == action_id)
	actions.remove_at(index_to_remove)
	action_removed.emit(action_id)
	emit_changed()


# TODO: docs


func get_action_by_ref(ref: String) -> Action:
	var filtered_actions: Array = actions.filter(func(action: Action) -> bool:
		return action.ref and ParleyUtils.resource.get_uid(action.ref) == ref)
	if filtered_actions.size() == 0:
		if ref != "":
			ParleyUtils.log.warn("Action with ref not found in store (store:%s, ref:%s), returning an empty Action" % [id, ref])
		return Action.new()
	return filtered_actions.front()
#endregion


#region HELPERS
func _to_string() -> String:
	return "ActionStore<%s>" % [str(to_dict())]
#endregion
