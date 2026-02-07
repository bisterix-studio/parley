class_name ParleyCreateNodeOperation
extends ParleyGraphOperation

var node_type: ParleyDialogueSequenceAst.Type
var graph_view: ParleyGraphView
var position: Vector2
var node_id: String

func _init(_graph_view: ParleyGraphView, _node_type: ParleyDialogueSequenceAst.Type, _position: Vector2) -> void:
    graph_view = _graph_view
    node_type = _node_type
    position = _position
    

func undo() -> void:
    var ast : ParleyNodeAst = graph_view.ast.find_node_by_id(node_id)
    if ast != null:
        graph_view.ast.remove_node(node_id)

    var node : ParleyGraphNode = graph_view.find_node_by_id(node_id)
    if node:
        graph_view._on_node_deselected(node)
        graph_view.remove_child(node)


func do() -> void:
    var ast_node: Variant = graph_view.ast.add_new_node(node_type, position)
    if ast_node:
        node_id = ast_node.id
        graph_view.generate()