# PasteShortcut.gd
extends GraphOperation
class_name PasteOperation

var pasted_nodes: Array = []
var graph_edit: GraphEdit

func _init(_graph_edit: GraphEdit, nodes: Array) -> void:
	graph_edit = _graph_edit
	pasted_nodes = nodes.duplicate()

func undo() -> void:
	# Remove pasted nodes
	for node: GraphNode in pasted_nodes:
		if graph_edit.has_node(NodePath(node.name)):
			graph_edit.remove_child(node)

func do() -> void:
	# Re-add pasted nodes
	for node: GraphNode in pasted_nodes:
		graph_edit.add_child(node)