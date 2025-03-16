@tool

# TODO: prefix with Parley
class_name EdgesEditor extends VBoxContainer

@export var edges: Array[EdgeAst] = []
@export var node_id: String = ""


const EdgeEditorScene: PackedScene = preload('../components/edge/edge_editor.tscn')


signal edge_deleted(edge: EdgeAst)
signal mouse_entered_edge(edge: EdgeAst)
signal mouse_exited_edge(edge: EdgeAst)


func _ready() -> void:
	set_edges(edges, node_id)


func clear() -> void:
	var children: Array[EdgeEditor] = []
	edges = []
	for edge in get_children():
		if edge is EdgeEditor:
			edge.queue_free()
			children.append(edge)
	for child in children:
		await child.tree_exited


## Set the edges rendered by the editor
## Example: editor.set_edges(dialogue_ast.edges, node.id)
func set_edges(all_edges: Array[EdgeAst], p_node_id: String) -> void:
	clear()
	node_id = p_node_id
	var index: int = 0
	# FROM SELECTED NODE
	edges.append_array(all_edges.filter(func(edge: EdgeAst): return edge.from_node == node_id))
	# TO SELECTED NODE
	edges.append_array(all_edges.filter(func(edge: EdgeAst): return edge.to_node == node_id))
	for edge in edges:
		var edge_editor: EdgeEditor = EdgeEditorScene.instantiate()
		edge_editor.edge = edge
		edge_editor.edge_deleted.connect(_on_edge_deleted)
		edge_editor.mouse_entered_edge.connect(_build_on_mouse_entered_edge(edge))
		edge_editor.mouse_exited_edge.connect(_build_on_mouse_exited_edge(edge))
		add_child(edge_editor)
		index += 1


func _remove_edge(r_edge: EdgeAst) -> void:
	var new_edges: Array[EdgeAst] = []
	for edge in edges:
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
