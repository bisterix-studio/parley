class_name ParleyDeleteOperation
extends ParleyGraphOperation

var selected_connections: Array[ParleyGraphEdge]
var selected_node_ids: Array[String]
var deleted_node_datas: Array[NodeData]
var graph_view: ParleyGraphView

func _init(_graph_view: ParleyGraphView, _selected_connections: Array[ParleyGraphEdge], _selected_node_ids: Array[String]) -> void:
	graph_view = _graph_view
	selected_connections = _selected_connections.duplicate()
	selected_node_ids = _selected_node_ids.duplicate()
	
	
func undo() -> void:
	var graph_nodes: Dictionary = {}
	for node_data : NodeData in deleted_node_datas:
		var deleted_node : ParleyNodeAst = node_data.node_ast
		graph_view._add_node(graph_nodes, deleted_node)
		graph_view.ast.add_node_from_ast(deleted_node)
		var added_node : ParleyGraphNode = graph_nodes[deleted_node.id]
		added_node.position = deleted_node.position
	
	for node_data : NodeData in deleted_node_datas:
		for connection : ParleyGraphEdge in node_data.connections:
			connection.connect_node(graph_view)

	for connection : ParleyGraphEdge in selected_connections:
		connection.connect_node(graph_view)

	graph_view.generate()


func do() -> void:
	deleted_node_datas.clear()
	for selected_node_id : String in selected_node_ids:
		var ast : ParleyNodeAst = graph_view.ast.find_node_by_id(selected_node_id)
		if ast != null:
			var connections : Array[ParleyGraphEdge] = ParleyGraphUtils.get_connections_for_node(graph_view, selected_node_id)
			deleted_node_datas.append(NodeData.new(selected_node_id, ast, connections))

	for selected_node_id : String in selected_node_ids:
		var ast : ParleyNodeAst = graph_view.ast.find_node_by_id(selected_node_id)
		if ast != null:
			var selected_node : ParleyGraphNode = graph_view.find_node_by_id(selected_node_id)
			graph_view._on_node_deselected(selected_node)
			graph_view.remove_child(selected_node)
			graph_view.ast.remove_node(selected_node_id)

	graph_view._on_connections_deselected()
	for connection : ParleyGraphEdge in selected_connections:
		connection.disconnect_node(graph_view)

	graph_view.generate()




