@tool
# TODO: prefix with Parley
class_name EdgeEditor extends VBoxContainer

@export var edge: EdgeAst: set = _set_edge

@export var from_node_value: Label
@export var from_slot_value: Label
@export var to_node_value: Label
@export var to_slot_value: Label
@export var delete_edge_button: Button


signal edge_deleted(edge: EdgeAst)
signal mouse_entered_edge(edge: EdgeAst)
signal mouse_exited_edge(edge: EdgeAst)

func _ready() -> void:
	_set_edge(edge)
	apply_theme()


#region SETTERS
func _set_edge(new_edge: EdgeAst) -> void:
	if new_edge != edge:
		if edge:
			ParleyUtils.signals.safe_disconnect(edge.edge_changed, _on_edge_changed)
		edge = new_edge
		if edge:
			ParleyUtils.signals.safe_connect(edge.edge_changed, _on_edge_changed)
		else:
			_render("", 0, "", 0)
			return
	if edge:
		_render(edge.from_node, edge.from_slot, edge.to_node, edge.to_slot)
#endregion


#region RENDERERS
func _render(from_node: String, from_slot: int, to_node: String, to_slot: int) -> void:
	if from_node_value:
		from_node_value.text = from_node.replace(NodeAst.id_prefix, '')
	if from_slot_value:
		from_slot_value.text = str(from_slot)
	if to_node_value:
		to_node_value.text = to_node.replace(NodeAst.id_prefix, '')
	if to_slot_value:
		to_slot_value.text = str(to_slot)


## Applies the edge editor theme
## Example: editor.apply_theme()
func apply_theme() -> void:
	delete_edge_button.tooltip_text = "Delete the selected edge."
#endregion


#region SIGNALS
func _on_delete_edge_button_pressed() -> void:
	edge_deleted.emit(edge)


func _on_mouse_entered() -> void:
	mouse_entered_edge.emit()


func _on_mouse_exited() -> void:
	mouse_exited_edge.emit()


func _on_edge_changed(new_edge: EdgeAst) -> void:
	edge = new_edge
#endregion
