# ParleyGraphEdge.gd
# Represents a connection between two GraphNodes in a GraphEdit

extends Object
class_name ParleyGraphEdge
var from_node: ParleyGraphNode
var from_node_id: String
var from_slot: int
var from_port: int
var to_node: ParleyGraphNode
var to_node_id: String
var to_slot: int
var to_port: int
var to_node_name: String
var from_node_name: String
var edge_ast: ParleyEdgeAst

var previousFromColor: Color
var previousToColor: Color
var selected: bool

# Duplicate should not be used on this class. The class is generated one time only at runtime when it is needed
func _init(_edge_ast: ParleyEdgeAst, _from_node: ParleyGraphNode, _from_port: int, _to_node: ParleyGraphNode, _to_port: int) -> void:
	from_node = _from_node
	from_port = _from_port
	to_node = _to_node
	to_port = _to_port
	from_slot = from_node.get_output_port_slot(from_port)
	to_slot = to_node.get_input_port_slot(to_port)
	from_node_id = from_node.id
	to_node_id = to_node.id
	from_node_name = from_node.name
	to_node_name = to_node.name
	edge_ast = _edge_ast


func disconnect_node(graph_view: ParleyGraphView) -> void:
	if not graph_view:
		return

	graph_view.ast.remove_edge(from_node_id, from_port, to_node_id, to_port)
	graph_view.disconnect_node(from_node_name, from_port, to_node_name, to_port)


func connect_node(graph_view: ParleyGraphView) -> int:
	if not graph_view:
		return FAILED
	
	graph_view.ast.edges.append(edge_ast)
	return graph_view.connect_node(from_node_name, from_port, to_node_name, to_port)


func select() -> void:
	if selected:
		return
	selected = true
	if not is_instance_valid(from_node) or not is_instance_valid(to_node):
		return
	if edge_ast.should_override_colour:
		previousFromColor = edge_ast.colour_override
		previousToColor = edge_ast.colour_override
	else:
		previousFromColor = Color.LAWN_GREEN
		previousToColor = Color.LAWN_GREEN
		
	from_node.set_slot_color_right(from_slot, Color.DEEP_SKY_BLUE)
	to_node.set_slot_color_left(to_slot, Color.DEEP_SKY_BLUE)


func unselect() -> void:
	if not selected:
		return
	selected = false
	if not is_instance_valid(from_node) or not is_instance_valid(to_node):
		return
	from_node.set_slot_color_right(from_slot, previousFromColor)
	to_node.set_slot_color_left(to_slot, previousToColor)


func as_string() -> String:
	return "%s:%d -> %s:%d" % [from_node_name, from_port, to_node_name, to_port]
