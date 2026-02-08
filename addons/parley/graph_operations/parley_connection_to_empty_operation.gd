class_name ParleyConnectionToEmptyOperation
extends ParleyGraphOperation

var node_type: ParleyDialogueSequenceAst.Type
var graph_view: ParleyGraphView
var position: Vector2
var node_id: String
var from_node_name: StringName
var from_slot: int

func _init(_graph_view: ParleyGraphView, _node_type: ParleyDialogueSequenceAst.Type, _position: Vector2, _from_node_name: StringName, _from_slot: int) -> void:
    graph_view = _graph_view
    node_type = _node_type
    position = _position
    from_node_name = _from_node_name
    from_slot = _from_slot
    

func undo() -> void:
    var connections : Array[ParleyGraphEdge] = ParleyGraphUtils.get_connections_for_node(graph_view, node_id)

    for connection: ParleyGraphEdge in connections:
        connection.disconnect_node()

    var ast : ParleyNodeAst = graph_view.ast.find_node_by_id(node_id)
    if ast != null:
        graph_view.ast.remove_node(node_id)

    var node : ParleyGraphNode = graph_view.find_node_by_id(node_id)
    if node:
        graph_view._on_node_deselected(node)
        graph_view.remove_child(node)


func do() -> void:
    var ast_node: ParleyNodeAst = graph_view.ast.add_new_node(node_type, position)
    if ast_node:
        node_id = ast_node.id
        await graph_view.generate()

        var to_node_name: String = graph_view.get_ast_node_name(ast_node)
        # TODO: This is the entry slot for a Dialogue AST Node, it may be better to create a helper function for this
        var to_slot: int = 0
        _add_edge(to_node_name, to_slot)

func _add_edge(to_node_name: StringName, to_slot: int) -> void:
    var from_node_id: String = from_node_name.split('-')[1]
    var to_node_id: String = to_node_name.split('-')[1]
    var added_edge: ParleyEdgeAst = graph_view.ast.add_new_edge(from_node_id, from_slot, to_node_id, to_slot)
    if added_edge:
        graph_view.add_edge(added_edge, from_node_name, to_node_name)

