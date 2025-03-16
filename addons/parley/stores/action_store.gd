@tool
# TODO: prefix with Parley
class_name ActionStore extends Resource

@export var actions: Array[Action] = []


func add_action_script(name: String = "", path: String = "") -> void:
	if actions.find(func(a): return a.name == name) != -1:
		printerr("PARLEY_ERR: Action with name %s already exists" % [name])
		return
	var action_inst = load(path)
	if not action_inst:
		printerr("PARLEY_ERR: Action script does not exist at path: %s" % [path])
		return
	if not is_instance_of(action_inst, ActionInterface):
		printerr("PARLEY_ERR: Action script must inherit: ActionInterface")
		return
	actions.append(Action.new(_generate_id(), path))


func get_action_by_id(id: int) -> Action:
	var filtered_actions = actions.filter(func(action): return action.id == id)
	if filtered_actions.size() == 0:
		# TODO: is there a better way of handling this error here?
		printerr("PARLEY_ERR: Action with id %s not found in store" % [id])
		return Action.new(-1)
	return filtered_actions.front()


func get_action_by_name(name: String) -> Action:
	var filtered_actions = actions.filter(func(action): return action.name == name)
	if filtered_actions.size() == 0:
		# TODO: is there a better way of handling this error here?
		printerr("PARLEY_ERR: Action with name %s not found in store" % [name])
		return Action.new(-1)
	return filtered_actions.front()


func get_action_by_ref(ref: String) -> Action:
	var filtered_actions = actions.filter(func(action): return action.ref.resource_path == ref)
	if filtered_actions.size() == 0:
		# TODO: is there a better way of handling this error here?
		printerr("PARLEY_ERR: Action with ref %s not found in store" % [ref])
		return Action.new(-1)
	return filtered_actions.front()


func get_action_index_by_name(name: String) -> int:
	var idx = 0
	for action in actions:
		if action.name == name:
			return idx
		idx += 1
	return -1


#region HELPERS
func _generate_id() -> int:
	if actions.size() == 0:
		return 0
	return actions.map(func(action): return action.id).max() + 1
#endregion
