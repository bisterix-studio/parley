@tool
# TODO: prefix with Parley
class_name ActionStore extends StoreAst


#region DEFS
@export var actions: Array[Action] = []: set = _set_actions


const store_metadata_key: String = "action_store"


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
	var actions_with_metadata: Array[Action] = []
	for action: Action in new_actions:
		actions_with_metadata.append(_set_action_metadata(action))
	actions = actions_with_metadata


func _set_action_metadata(action: Action) -> Action:
	if action and not action.has_meta(store_metadata_key) and self.resource_path:
		action.set_meta(store_metadata_key, self.resource_path)
	return action
#endregion


#region CRUD
static func get_action_store_ref(action: Action) -> String:
	if action.has_meta(store_metadata_key):
		var store: Variant = action.get_meta(store_metadata_key)
		if is_instance_of(store, TYPE_STRING) and len(store) > 0:
			return store
	return ""


func add_action(name: String = "") -> Action:
	var action: Action = Action.new(ParleyUtils.generate.id(actions, id, name), name)
	actions.append(_set_action_metadata(action))
	action_added.emit(action)
	emit_changed()
	return action


func get_action_id_by_index(index: int) -> String:
	var action: Variant = actions.get(index)
	return action.id if action and is_instance_of(action, Action) else ParleyUtils.generate.id(actions, id, 'unknown')


func get_action_name_by_id(action_id: String) -> String:
	var filtered_actions: Array = actions.filter(func(action: Action) -> bool: return action.id == action_id)
	if filtered_actions.size() == 0:
		return 'Unknown'
	return filtered_actions.front().name


func get_action_index_by_name(name: String) -> int:
	var idx: int = 0
	for action: Action in actions:
		if action.name == name:
			return idx
		idx += 1
	return -1


func remove_action(action_id: String) -> void:
	var index_to_remove: int = actions.find_custom(func(action: Action) -> bool: return action.id == action_id)
	actions.remove_at(index_to_remove)
	action_removed.emit(action_id)
	emit_changed()

# TODO: docs

func has_action_name(name: String) -> bool:
	var filtered_actions: Array = actions.filter(func(action: Action) -> bool: return action.name == name)
	return filtered_actions.size() > 0


func get_action_by_name(name: String) -> Action:
	var filtered_actions: Array = actions.filter(func(action: Action) -> bool: return action.name == name)
	if filtered_actions.size() == 0:
		# TODO: is there a better way of handling this error here?
		ParleyUtils.log.error("Action with name %s not found in store" % [name])
		return Action.new()
	return filtered_actions.front()


func get_action_by_ref(ref: String) -> Action:
	var filtered_actions: Array = actions.filter(func(action: Action) -> bool: return action.ref and action.ref.resource_path == ref)
	if filtered_actions.size() == 0:
		# TODO: is there a better way of handling this error here?
		ParleyUtils.log.error("Action with ref %s not found in store" % [ref])
		return Action.new()
	return filtered_actions.front()
#endregion


#region HELPERS
func _to_string() -> String:
	return "ActionStore<%s>" % [str(to_dict())]
#endregion
