class_name ParleyGraphUtils
extends Node

static func get_connections_for_node(graph_view: ParleyGraphView, node_id: String) -> Array:
	var result: Array[ParleyGraphEdge] = []
	var connections: Array[Dictionary] = graph_view.get_connection_list()

	for conn: Dictionary in connections:
		var from_name: String = conn.get("from_node")
		var to_name: String = conn.get("to_node")
		var from_port: int = conn.get("from_port")
		var to_port: int = conn.get("to_port")
		var to_node: ParleyGraphNode = graph_view.get_node(NodePath(to_name)) as ParleyGraphNode
		var from_node: ParleyGraphNode = graph_view.get_node(NodePath(from_name)) as ParleyGraphNode

		if to_node.id == node_id or from_node.id == node_id:
			var edge_ast: ParleyEdgeAst = graph_view.ast.get_edge_ast(from_node.id, from_port, to_node.id, to_port)
			result.append(ParleyGraphEdge.new(graph_view, edge_ast, from_node, from_port, to_node, to_port))

	return result

static func get_cursor_pos_at_graph_view(graph_view: ParleyGraphView) -> Vector2:
	var viewport_mouse : Vector2 = graph_view.get_viewport().get_mouse_position()
	var local_mouse : Vector2 = viewport_mouse - graph_view.get_global_rect().position
	return (local_mouse + graph_view.scroll_offset) / graph_view.zoom
