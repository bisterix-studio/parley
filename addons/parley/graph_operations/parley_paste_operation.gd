# PasteShortcut.gd
extends ParleyGraphOperation
class_name ParleyPasteOperation

var node_ids: Array[String]
var graph_view: ParleyGraphView

func _init(_graph_view: ParleyGraphView, _node_ids: Array[String]) -> void:
	graph_view = _graph_view
	node_ids = _node_ids.duplicate()


func do() -> void:
	pass

func undo() -> void:
	pass	
