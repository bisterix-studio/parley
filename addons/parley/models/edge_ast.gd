# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyEdgeAst extends Resource


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


## The indicator for whether the Edge colour should be overridden.
@export var should_override_colour: bool = false: set = _set_should_override_colour


## The colour override of the Edge.
@export var colour_override: Color = default_colour_override: set = _set_colour_override


const default_colour_override: Color = Color(0.4118, 0.4118, 0.4118, 1.0)


## Emitted when an Edge is changed. Details of the changed edge are included in the signal parameters.
signal edge_changed(edge: ParleyEdgeAst)


var ready: bool = false


const id_prefix: String = "edge:"
#endregion


#region LIFECYCLE
func _init(
	_id: String = "",
	_from_node: String = "",
	_from_slot: int = 0,
	_to_node: String = "",
	_to_slot: int = 0,
	_should_override_colour: bool = false,
	_colour_override: Color = default_colour_override,
) -> void:
	id = _id
	from_node = _from_node
	from_slot = _from_slot
	to_node = _to_node
	to_slot = _to_slot
	should_override_colour = _should_override_colour
	colour_override = _colour_override
	ready = true
#endregion


#region SETTERS
func _set_id(new_id: String) -> void:
	# Once defined, id should be immutable
	if not id or id == id_prefix or not id.begins_with(id_prefix):
		id = new_id if new_id.begins_with(id_prefix) else "%s%s" % [id_prefix, new_id]


func _set_from_node(new_from_node: String) -> void:
	from_node = new_from_node if new_from_node.begins_with(ParleyNodeAst.id_prefix) else "%s%s" % [ParleyNodeAst.id_prefix, new_from_node]
	if ready:
		edge_changed.emit(self)


func _set_from_slot(new_from_slot: int) -> void:
	from_slot = new_from_slot
	if ready:
		edge_changed.emit(self)


func _set_to_node(new_to_node: String) -> void:
	to_node = new_to_node if new_to_node.begins_with(ParleyNodeAst.id_prefix) else "%s%s" % [ParleyNodeAst.id_prefix, new_to_node]
	if ready:
		edge_changed.emit(self)


func _set_to_slot(new_to_slot: int) -> void:
	to_slot = new_to_slot
	if ready:
		edge_changed.emit(self)


func _set_should_override_colour(new_should_override_colour: bool) -> void:
	if should_override_colour != new_should_override_colour:
		should_override_colour = new_should_override_colour
		if ready:
			edge_changed.emit(self)


func _set_colour_override(new_colour_override: Color) -> void:
	if str(new_colour_override) != str(colour_override):
		colour_override = new_colour_override
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
		'should_override_colour': should_override_colour,
		'colour_override': colour_override,
	}

func _to_string() -> String:
	return "ParleyEdgeAst<%s>" % [str(to_dict())]
#endregion
