# DeleteShortcut.gd
class_name ParleyDeleteOperation
extends ParleyGraphOperation

var selected_connections: Array[ParleyGraphEdge]
var selected_nodes: Array[ParleyGraphNode]
var deleted_node_datas: Array[NodeData]
var graph_view: ParleyGraphView

func _init(_graph_view: ParleyGraphView, _selected_connections: Array[ParleyGraphEdge], _selected_nodes: Array[ParleyGraphNode]) -> void:
	graph_view = _graph_view
	selected_connections = _selected_connections.duplicate()
	selected_nodes = _selected_nodes.duplicate()

func undo() -> void:
	pass
	# Re-add deleted nodes

	selected_nodes.clear()
	var graph_nodes: Dictionary = {}
	for node_data : NodeData in deleted_node_datas:
		var deleted_node : ParleyNodeAst = node_data.node_ast
		graph_view._add_node(graph_nodes, deleted_node)
		graph_view.ast.add_node_from_ast(deleted_node)
		var added_node : ParleyGraphNode = graph_nodes[deleted_node.id]
		added_node.position = deleted_node.position
	
	for node_data : NodeData in deleted_node_datas:
		for connection : ParleyGraphEdge in node_data.connections:
			connection.to_node = graph_view.get_node(NodePath(connection.to_node_name)) as ParleyGraphNode
			connection.from_node = graph_view.get_node(NodePath(connection.from_node_name)) as ParleyGraphNode
			if node_data.node_name == connection.to_node_name:
				selected_nodes.append(connection.to_node)
				pass
			elif node_data.node_name == connection.from_node_name:
				selected_nodes.append(connection.from_node)
				pass
			connection.connect_node(graph_view)

	for connection : ParleyGraphEdge in selected_connections:
		connection.to_node = graph_view.get_node(NodePath(connection.to_node_name)) as ParleyGraphNode
		connection.from_node = graph_view.get_node(NodePath(connection.from_node_name)) as ParleyGraphNode
		connection.connect_node(graph_view)

	graph_view.generate()

func do() -> void:
	for selected_node : ParleyGraphNode in selected_nodes:
		if graph_view.has_node(NodePath(selected_node.name)):
			var ast : ParleyNodeAst = graph_view.ast.find_node_by_id(selected_node.id)
			var connections : Array[ParleyGraphEdge] = get_connections_for_node(graph_view, selected_node)
			deleted_node_datas.append(NodeData.new(selected_node.name, ast, connections))

	for selected_node : ParleyGraphNode in selected_nodes:
		if graph_view.has_node(NodePath(selected_node.name)):
			print("remove node")
			var ast : ParleyNodeAst = graph_view.ast.find_node_by_id(selected_node.id)
			graph_view._on_node_deselected(selected_node)
			graph_view.remove_child(selected_node)
			graph_view.ast.remove_node(selected_node.id)

	for connection : ParleyGraphEdge in selected_connections:
		print("disconnect connection")
		connection.disconnect_node(graph_view)
		
	graph_view.generate()

func get_connections_for_node(graph_edit: GraphEdit, node: GraphNode) -> Array[ParleyGraphEdge]:
	var result: Array[ParleyGraphEdge] = []
	var connections: Array[Dictionary] = graph_edit.get_connection_list()
	
	for conn: Dictionary in connections:
		var from_name: String = conn.get("from_node")
		var to_name: String = conn.get("to_node")
		var from_port: int = conn.get("from_port")
		var to_port: int = conn.get("to_port")
		var to_node: ParleyGraphNode = graph_view.get_node(NodePath(to_name)) as ParleyGraphNode
		var from_node: ParleyGraphNode = graph_view.get_node(NodePath(from_name)) as ParleyGraphNode

		if from_name == node.name or to_name == node.name:
			result.append(ParleyGraphEdge.new(from_node, from_port, to_node, to_port))
	
	return result


class NodeData:
	var node_ast: ParleyNodeAst
	var connections: Array[ParleyGraphEdge]
	var node_name: String

	func _init(_node_name: String, _node_ast :ParleyNodeAst, _connections: Array[ParleyGraphEdge]) -> void:
		node_name = _node_name
		node_ast = _node_ast
		connections = _connections

