@tool
# TODO: prefix with Parley
class_name EdgeEditor extends VBoxContainer

@export var edge: EdgeAst: set = _on_edge_changed

@export var from_node_value: Label
@export var from_slot_value: Label
@export var to_node_value: Label
@export var to_slot_value: Label
@export var delete_edge_button: Button


signal edge_deleted(edge: EdgeAst)
signal mouse_entered_edge(edge: EdgeAst)
signal mouse_exited_edge(edge: EdgeAst)

func _ready() -> void:
	_on_edge_changed(edge)
	apply_theme()


func _on_edge_changed(new_edge: EdgeAst) -> void:
	if new_edge != edge:
		if edge:
			edge.edge_changed.disconnect(_on_edge_changed)
		edge = new_edge
		if edge:
			edge.edge_changed.connect(_on_edge_changed)
		else:
			_update("", 0, "", 0)
			return
	if edge:
		_update(edge.from_node, edge.from_slot, edge.to_node, edge.to_slot)


func _update(from_node: String, from_slot: int, to_node: String, to_slot: int):
	if from_node_value:
		from_node_value.text = from_node
	if from_slot_value:
		from_slot_value.text = str(from_slot)
	if to_node_value:
		to_node_value.text = to_node
	if to_slot_value:
		to_slot_value.text = str(to_slot)


## Applies the edge editor theme
## Example: editor.apply_theme()
func apply_theme() -> void:
	delete_edge_button.tooltip_text = "Delete the selected edge."


func _on_delete_edge_button_pressed() -> void:
	edge_deleted.emit(edge)


func _on_mouse_entered() -> void:
	mouse_entered_edge.emit()


func _on_mouse_exited() -> void:
	mouse_exited_edge.emit()
