@tool
class_name NodeData

var node_ast: ParleyNodeAst
var edges: Array[ParleyGraphEdge]
var node_id: String

func _init(_node_id: String, _node_ast :ParleyNodeAst, _edges: Array[ParleyGraphEdge]) -> void:
    node_id = _node_id
    node_ast = _node_ast
    edges = _edges