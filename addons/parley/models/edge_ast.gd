@tool

# TODO: prefix with Parley
class_name EdgeAst extends Resource


#region DEFS
## The ID of the Edge.
@export var id: String = "": set = _set_id


## The source Node ID.
@export var from_node: String: set = _set_from_node


## The source Node Port ID.
@export var from_slot: int: set = _set_from_slot


## The destination Node ID.
@export var to_node: String: set = _set_to_node


## The destination Node Port ID.
@export var to_slot: int: set = _set_to_slot


## Emitted when an Edge is changed. Details of the changed edge are included in the signal parameters.
signal edge_changed(edge: EdgeAst)


var ready: bool = false


const id_prefix: String = "edge:"
#endregion


#region LIFECYCLE
func _init(_id: String = "", _from_node: String = "", _from_slot: int = 0, _to_node: String = "", _to_slot: int = 0) -> void:
	id = _id
	from_node = _from_node
	from_slot = _from_slot
	to_node = _to_node
	to_slot = _to_slot
	ready = true
#endregion


#region SETTERS
func _set_id(new_id: String) -> void:
	# Once defined, id should be immutable
	if not id or id == id_prefix or not id.begins_with(id_prefix):
		id = new_id if new_id.begins_with(id_prefix) else "%s%s" % [id_prefix, new_id]


func _set_from_node(new_from_node: String) -> void:
	from_node = new_from_node if new_from_node.begins_with(NodeAst.id_prefix) else "%s%s" % [NodeAst.id_prefix, new_from_node]
	if ready:
		edge_changed.emit(self)


func _set_from_slot(new_from_slot: int) -> void:
	from_slot = new_from_slot
	if ready:
		edge_changed.emit(self)


func _set_to_node(new_to_node: String) -> void:
	to_node = new_to_node if new_to_node.begins_with(NodeAst.id_prefix) else "%s%s" % [NodeAst.id_prefix, new_to_node]
	if ready:
		edge_changed.emit(self)


func _set_to_slot(new_to_slot: int) -> void:
	to_slot = new_to_slot
	if ready:
		edge_changed.emit(self)
#endregion


#region UTILS
## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	return {
		'id': id,
		'from_node': from_node,
		'from_slot': from_slot,
		'to_node': to_node,
		'to_slot': to_slot,
	}

func _to_string() -> String:
	return "EdgeAst<%s>" % [str(to_dict())]
#endregion
