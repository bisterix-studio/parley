class_name ParleyDuplicateOperation
extends ParleyGraphOperation

var selected_node_ids: Array[String]
var created_node_datas: Array[NodeData]
var graph_view: ParleyGraphView


func _init(_graph_view: ParleyGraphView, _selected_node_ids: Array[String]) -> void:
	graph_view = _graph_view
	selected_node_ids = _selected_node_ids.duplicate()
	

func do() -> void:

	graph_view._clear_selected_nodes()
	var created_node_list: Array[String]
	var node_names: Array[String]

	for node_id: String in selected_node_ids:
		var node : ParleyGraphNode = graph_view.find_node_by_id(node_id)
		var ast_node: ParleyNodeAst = graph_view.ast.add_new_node(node.type, node.position_offset + Vector2.DOWN * 200 + Vector2.RIGHT * 200 )
		if ast_node:
			node_id = ast_node.id
			var connections : Array[ParleyGraphEdge] = ParleyGraphUtils.get_connections_for_node(graph_view, node_id)
			created_node_datas.append(NodeData.new(node_id, ast_node, connections))
			created_node_list.append(node_id)
			node_names.append(node.name)
		if ast_node is ParleyGroupNodeAst:
			(ast_node as ParleyGroupNodeAst).size = node.size
			
	await graph_view.generate()

	for i: int in range(created_node_list.size()):
		var node_id: String = created_node_list[i]
		var node_name: String = node_names[i]
		var node : ParleyGraphNode = graph_view.find_node_by_id(node_id)
		node.set_selected(true)
		node.name = node_name


func undo() -> void:
	for node_data: NodeData in created_node_datas:
		for connection: ParleyGraphEdge in node_data.connections:
			connection.disconnect_node()

		var selected_node : ParleyGraphNode = graph_view.find_node_by_id(node_data.node_id)
		if selected_node:
			graph_view._on_node_deselected(selected_node)
			graph_view.remove_child(selected_node)
			
		graph_view.ast.remove_node(node_data.node_id)

	await graph_view.generate()
	for node_id: String in selected_node_ids:
		var node : ParleyGraphNode = graph_view.find_node_by_id(node_id)
		node.set_selected(true)
	