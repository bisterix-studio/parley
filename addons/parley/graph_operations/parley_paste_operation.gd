@tool

extends ParleyGraphOperation
class_name ParleyPasteOperation

var node_ids: Array[String]
var graph_view: ParleyGraphView
var created_node_datas: Array[NodeData]

func _init(_graph_view: ParleyGraphView, _node_ids: Array[String]) -> void:
	graph_view = _graph_view
	node_ids = _node_ids.duplicate()


func do() -> void:
	graph_view._clear_selected_nodes()
	var created_node_list: Array[String]
	var node_names: Array[String]

	var node_asts : Array[ParleyNodeAst] = _get_node_asts()
	var center_position: Vector2 = Vector2.ZERO

	for node_ast: ParleyNodeAst in node_asts:
		center_position += node_ast.position
	center_position /= node_asts.size()

	for node_ast: ParleyNodeAst in node_asts:
		if node_ast:
			var new_ast_node : ParleyNodeAst = graph_view.ast.copy_node_ast(node_ast)
			var diff: Vector2 = ParleyGraphUtils.get_cursor_pos_at_graph_view(graph_view) - center_position
			new_ast_node.position = new_ast_node.position + diff
			# TODO: if we want to duplicate the connections create edges and pass them to the edge list later
			created_node_datas.append(NodeData.new(new_ast_node.id, new_ast_node, []))
			created_node_list.append(new_ast_node.id)
			node_names.append(graph_view.get_ast_node_name(new_ast_node))

	await graph_view.generate()

	for i: int in range(created_node_list.size()):
		var node_id: String = created_node_list[i]
		var node_name: String = node_names[i]
		var node : ParleyGraphNode = graph_view.find_node_by_id(node_id)
		node.set_selected(true)
		node.name = node_name

func undo() -> void:
	for node_data: NodeData in created_node_datas:
		for edge: ParleyGraphEdge in node_data.edges:
			edge.disconnect_node()

		var selected_node : ParleyGraphNode = graph_view.find_node_by_id(node_data.node_id)
		if selected_node:
			graph_view._on_node_deselected(selected_node)
			graph_view.remove_child(selected_node)
		
		graph_view.ast.remove_node(node_data.node_id)

	await graph_view.generate()

func _get_node_asts() -> Array[ParleyNodeAst]:
	var result: Array[ParleyNodeAst]
	for node_id: String in node_ids:
		result.append(graph_view.ast.find_node_by_id(node_id))
	return result