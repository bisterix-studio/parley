# ParleyGraphEdge.gd
# Represents a connection between two GraphNodes in a GraphEdit

extends Object
class_name ParleyGraphEdge
var from_node: ParleyGraphNode
var from_slot: int
var from_port: int
var to_node: ParleyGraphNode
var to_slot: int
var to_port: int
var to_node_name: String
var from_node_name: String

var previousFromColor: Color
var previousToColor: Color
var selected: bool

func _init(_from_node: ParleyGraphNode, _from_port: int, _to_node: ParleyGraphNode, _to_port: int) -> void:
	from_node = _from_node
	from_port = _from_port
	to_node = _to_node
	to_port = _to_port
	from_slot = from_node.get_output_port_slot(from_port)
	to_slot = to_node.get_input_port_slot(to_port)
	from_node_name = from_node.name
	to_node_name = to_node.name

func disconnect_node(graph_view: ParleyGraphView) -> void:
	if not graph_view:
		return
	graph_view.disconnect_node(from_node_name, from_port, to_node_name, to_port)
	graph_view.ast.remove_edge(from_node_name, from_port, to_node_name, to_port)

func connect_node(graph_view: ParleyGraphView) -> int:
	if not graph_view:
		return FAILED
	return graph_view.connect_node(from_node_name, from_port, to_node_name, to_port)

func select() -> void:
	if selected:
		return
	selected = true

	previousFromColor = from_node.get_slot_color_right(from_slot)
	previousToColor = to_node.get_slot_color_left(to_slot)
	from_node.set_slot_color_right(from_slot, Color.DEEP_SKY_BLUE) # "output_port_count + from_port - 1" is this a bug i really don't know but only this works
	to_node.set_slot_color_left(to_slot, Color.DEEP_SKY_BLUE)

func unselect() -> void:
	if not selected:
		return

	selected = false

	from_node.set_slot_color_right(from_slot, previousFromColor)
	to_node.set_slot_color_left(to_slot, previousToColor)

func as_string() -> String:
	return "%s:%d -> %s:%d" % [from_node, from_port, to_node, to_port]
