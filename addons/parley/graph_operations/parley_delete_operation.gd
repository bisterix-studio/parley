# DeleteShortcut.gd
class_name ParleyDeleteOperation
extends ParleyGraphOperation

var selectedConnections: Array[ParleyGraphEdge]
var selectedNodes: Array[ParleyGraphNode]
var deletedNodes: Array[ParleyGraphNode]
var graph_view: ParleyGraphView

func _init(_graph_view: ParleyGraphView, _selected_connections: Array[ParleyGraphEdge], _selected_nodes: Array[ParleyGraphNode]) -> void:
	graph_view = _graph_view
	selectedConnections = _selected_connections.duplicate()
	selectedNodes = _selected_nodes.duplicate()

func undo() -> void:
	# Re-add deleted nodes

	# TODO this will be implemented shortly
	# for node : GraphNode in selectedNodes:
	# 	graph_view.add_child(node)
	# 	graph_view.ast.add_ast_node(node.)

	for connection : ParleyGraphEdge in selectedConnections:
		var result: int = connection.connect_node(graph_view)
		if result == FAILED:
			print("Couldn't delete connection: ", connection.as_string())
	

func do() -> void:
	# Remove deleted nodes
	for connection : ParleyGraphEdge in selectedConnections:
		connection.disconnect_node(graph_view)

	for selectedNode : ParleyGraphNode in selectedNodes:
		if graph_view.has_node(NodePath(selectedNode.name)):
			graph_view._on_node_deselected(selectedNode)
			graph_view.remove_child(selectedNode)
			graph_view.ast.remove_node(selectedNode.id)
			deletedNodes.append(selectedNode)

func flush() -> void:
	for deletedNode : ParleyGraphNode in deletedNodes:
		deletedNode.queue_free()
	pass