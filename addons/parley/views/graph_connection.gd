# GraphConnection.gd
# Represents a connection between two GraphNodes in a GraphEdit

extends Object
class_name GraphConnection
var from_node: ParleyGraphNode
var from_port: int
var to_node: ParleyGraphNode
var to_port: int

var previousFromColor: Color
var previousToColor: Color

func _init(_from_node: ParleyGraphNode, _from_port: int, _to_node: ParleyGraphNode, _to_port: int) -> void:
	from_node = _from_node
	from_port = _from_port
	to_node = _to_node
	to_port = _to_port

func disconnect_node(graph_edit: GraphEdit) -> void:
	if not graph_edit:
		return
	graph_edit.disconnect_node(from_node.name, from_port, to_node.name, to_port)

func connect_node(graph_edit: GraphEdit) -> int:
	if not graph_edit:
		return FAILED
	return graph_edit.connect_node(from_node.name, from_port, to_node.name, to_port)

func select() -> void:
	var output_port_count : int = from_node.get_output_port_count()
	previousFromColor = from_node.get_slot_color_right(output_port_count + from_port - 1)
	previousToColor = to_node.get_slot_color_left(to_port)
	from_node.set_slot_color_right(output_port_count + from_port - 1, Color.DEEP_SKY_BLUE) # "output_port_count + from_port - 1" is this a bug i really don't know but only this works
	to_node.set_slot_color_left(to_port, Color.DEEP_SKY_BLUE)

func unselect() -> void:
	var output_port_count : int = from_node.get_output_port_count()

	from_node.set_slot_color_right(output_port_count + from_port - 1,previousFromColor)
	to_node.set_slot_color_left(to_port, previousToColor)

func as_string() -> String:
	return "%s:%d -> %s:%d" % [from_node, from_port, to_node, to_port]
