@tool
class_name ParleyDeleteOperation
extends ParleyGraphOperation

var selected_edges: Array[ParleyGraphEdge]
var selected_node_ids: Array[String]
var deleted_node_datas: Array[NodeData]
var graph_view: ParleyGraphView

func _init(_graph_view: ParleyGraphView, _selected_edges: Array[ParleyGraphEdge], _selected_node_ids: Array[String]) -> void:
	graph_view = _graph_view
	selected_edges = _selected_edges.duplicate()
	selected_node_ids = _selected_node_ids.duplicate()
	
	
func undo() -> void:
	var graph_nodes: Dictionary = {}
	var created_node_list: Array[String]

	for node_data : NodeData in deleted_node_datas:
		var deleted_node : ParleyNodeAst = node_data.node_ast
		graph_view._add_node(graph_nodes, deleted_node)
		graph_view.ast.add_node_from_ast(deleted_node)
		var added_node : ParleyGraphNode = graph_nodes[deleted_node.id]
		added_node.position = deleted_node.position
		created_node_list.append(added_node.id)
	
	for node_data : NodeData in deleted_node_datas:
		for edge : ParleyGraphEdge in node_data.edges:
			edge.connect_node()

	for edge : ParleyGraphEdge in selected_edges:
		edge.connect_node()

	await graph_view.generate()

	for i: int in range(created_node_list.size()):
		var node_id: String = created_node_list[i]
		var node : ParleyGraphNode = graph_view.find_node_by_id(node_id)
		node.set_selected(true)

	for edge : ParleyGraphEdge in selected_edges:
		edge.unselect()
	for edge : ParleyGraphEdge in selected_edges:
		edge.select()

func do() -> void:
	deleted_node_datas.clear()
	for selected_node_id : String in selected_node_ids:
		var ast : ParleyNodeAst = graph_view.ast.find_node_by_id(selected_node_id)
		if ast != null:
			var edges : Array[ParleyGraphEdge] = ParleyGraphUtils.get_edges_for_node(graph_view, selected_node_id)
			deleted_node_datas.append(NodeData.new(selected_node_id, ast, edges))

	for selected_node_id : String in selected_node_ids:
		var ast : ParleyNodeAst = graph_view.ast.find_node_by_id(selected_node_id)
		if ast != null:
			var selected_node : ParleyGraphNode = graph_view.find_node_by_id(selected_node_id)
			graph_view._on_node_deselected(selected_node)
			graph_view.remove_child(selected_node)
			graph_view.ast.remove_node(selected_node_id)

	graph_view._on_edges_deselected()
	for edge : ParleyGraphEdge in selected_edges:
		edge.disconnect_node()

	graph_view.generate()




