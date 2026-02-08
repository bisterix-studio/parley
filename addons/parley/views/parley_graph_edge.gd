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

var selected: bool
var graph_view: ParleyGraphView

# Duplicate should not be used on this class. The class is generated one time only at runtime when it is needed
func _init(_graph_view: ParleyGraphView, _edge_ast: ParleyEdgeAst, _from_node: ParleyGraphNode, _from_port: int, _to_node: ParleyGraphNode, _to_port: int) -> void:
	graph_view = _graph_view
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


func disconnect_node() -> void:
	graph_view.ast.remove_edge(from_node_id, from_port, to_node_id, to_port)
	graph_view.disconnect_node(from_node_name, from_port, to_node_name, to_port)


func connect_node() -> int:
	graph_view.ast.edges.append(edge_ast)
	return graph_view.connect_node(from_node_name, from_port, to_node_name, to_port)


func select() -> void:
	if selected:
		return
	selected = true
	
	validate_nodes()
	
	from_node.select_from_slot(edge_ast.from_slot)
	to_node.select_to_slot(edge_ast.to_slot)


func unselect() -> void:
	if not selected:
		return
	selected = false

	validate_nodes()

	if edge_ast.should_override_colour:
		from_node.deselect_from_slot(edge_ast.from_slot, edge_ast.colour_override)
	else:
		from_node.deselect_from_slot(edge_ast.from_slot)
	var from_node_colour: Color = from_node.get_from_slot_colour(edge_ast.from_slot)
	to_node.unselect_to_slot(edge_ast.to_slot, from_node_colour)


func validate_nodes() -> void:
	if not is_instance_valid(from_node):
		from_node = graph_view.find_node_by_id(from_node_id)
	if not is_instance_valid(to_node):
		to_node = graph_view.find_node_by_id(to_node_id)


func as_string() -> String:
	return "%s:%d -> %s:%d" % [from_node_name, from_port, to_node_name, to_port]
