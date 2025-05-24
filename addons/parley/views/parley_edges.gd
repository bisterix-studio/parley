@tool
class_name ParleyEdgesEditor extends PanelContainer

@export var edges: Array[EdgeAst] = []
@export var node_id: String = ""

@onready var edges_container: VBoxContainer = %EdgesContainer

const EdgeEditorScene: PackedScene = preload('../components/edge/edge_editor.tscn')


signal edge_deleted(edge: EdgeAst)
signal mouse_entered_edge(edge: EdgeAst)
signal mouse_exited_edge(edge: EdgeAst)


func _ready() -> void:
	set_edges(edges, node_id)


func clear() -> void:
	var children: Array[EdgeEditor] = []
	edges = []
	if edges_container:
		for edge: Node in edges_container.get_children():
			if edge is EdgeEditor:
				edge.queue_free()
				children.append(edge)
		for child: EdgeEditor in children:
			await child.tree_exited


## Set the edges rendered by the editor
## Example: editor.set_edges(dialogue_ast.edges, node.id)
func set_edges(all_edges: Array[EdgeAst], p_node_id: String) -> void:
	clear()
	node_id = p_node_id
	# FROM SELECTED NODE
	edges.append_array(all_edges.filter(func(edge: EdgeAst) -> bool: return edge.from_node == node_id))
	# TO SELECTED NODE
	edges.append_array(all_edges.filter(func(edge: EdgeAst) -> bool: return edge.to_node == node_id))
	for edge: EdgeAst in edges:
		var edge_editor: EdgeEditor = EdgeEditorScene.instantiate()
		edge_editor.edge = edge
		ParleyUtils.signals.safe_connect(edge_editor.edge_deleted, _on_edge_deleted)
		ParleyUtils.signals.safe_connect(edge_editor.mouse_entered_edge, _build_on_mouse_entered_edge(edge))
		ParleyUtils.signals.safe_connect(edge_editor.mouse_exited_edge, _build_on_mouse_exited_edge(edge))
		if edges_container:
			edges_container.add_child(edge_editor)


func _remove_edge(r_edge: EdgeAst) -> void:
	var new_edges: Array[EdgeAst] = []
	for edge: EdgeAst in edges:
		if edge.from_node == r_edge.from_node and edge.from_slot == r_edge.from_slot and edge.to_node == r_edge.to_node and edge.to_slot == r_edge.to_slot:
			continue
		new_edges.append(edge)
	set_edges(new_edges, node_id)


func _on_edge_deleted(edge: EdgeAst) -> void:
	_remove_edge(edge)
	edge_deleted.emit(edge)


func _build_on_mouse_entered_edge(edge: EdgeAst) -> Callable:
	return func() -> void:
		mouse_entered_edge.emit(edge)


func _build_on_mouse_exited_edge(edge: EdgeAst) -> Callable:
	return func() -> void:
		mouse_exited_edge.emit(edge)
