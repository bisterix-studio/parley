# DeleteShortcut.gd
extends GraphOperation
class_name DeleteOperation

var selectedConnections: Array[GraphConnection]
var selectedNodes: Array[GraphNode]
var graph_edit: GraphEdit

func _init(_graph_edit: GraphEdit, _selected_connections: Array[GraphConnection], _selected_nodes: Array[GraphNode]) -> void:
	graph_edit = _graph_edit
	selectedConnections = _selected_connections.duplicate()
	selectedNodes = _selected_nodes.duplicate()

func undo() -> void:
	# Re-add deleted nodes
	for connection : GraphConnection in selectedConnections:
		var result: int = connection.connect_node(graph_edit)
		if result == FAILED:
			print("Couldn't delete connection: ", connection.as_string())
	
	for node : GraphNode in selectedNodes:
		graph_edit.add_child(node)

func do() -> void:
	# Remove deleted nodes
	for connection : GraphConnection in selectedConnections:
		connection.disconnect_node(graph_edit)

	for selectedNode : GraphNode in selectedNodes:
		if graph_edit.has_node(NodePath(selectedNode.name)):
			graph_edit.remove_child(selectedNode)
