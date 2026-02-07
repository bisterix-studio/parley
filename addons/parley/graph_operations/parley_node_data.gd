class_name NodeData

var node_ast: ParleyNodeAst
var connections: Array[ParleyGraphEdge]
var node_id: String

func _init(_node_id: String, _node_ast :ParleyNodeAst, _connections: Array[ParleyGraphEdge]) -> void:
    node_id = _node_id
    node_ast = _node_ast
    connections = _connections