@tool

# TODO: prefix with Parley
class_name EdgeAst extends Resource


## The source Node ID.
@export var from_node: String: set = _on_from_node_changed


## The source Node Port ID.
@export var from_slot: int: set = _on_from_slot_changed


## The destination Node ID.
@export var to_node: String: set = _on_to_node_changed


## The destination Node Port ID.
@export var to_slot: int: set = _on_to_slot_changed


## Emitted when an Edge is changed. Details of the changed edge are included in the signal parameters.
signal edge_changed(edge: EdgeAst)


var ready: bool = false


func _init(p_from_node: String = "", p_from_slot: int = 0, p_to_node: String = "", p_to_slot: int = 0) -> void:
	from_node = p_from_node
	from_slot = p_from_slot
	to_node = p_to_node
	to_slot = p_to_slot
	ready = true


#region SETTERS
func _on_from_node_changed(new_from_node: String) -> void:
	from_node = new_from_node
	if ready:
		edge_changed.emit(self)


func _on_from_slot_changed(new_from_slot: int) -> void:
	from_slot = new_from_slot
	if ready:
		edge_changed.emit(self)


func _on_to_node_changed(new_to_node: String) -> void:
	to_node = new_to_node
	if ready:
		edge_changed.emit(self)


func _on_to_slot_changed(new_to_slot: int) -> void:
	to_slot = new_to_slot
	if ready:
		edge_changed.emit(self)
#endregion

## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	return {
		'from_node': from_node,
		'from_slot': from_slot,
		'to_node': to_node,
		'to_slot': to_slot,
	}

func _to_string() -> String:
	return "EdgeAst<%s>" % [str(to_dict())]
