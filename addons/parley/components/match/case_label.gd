@tool
class_name CaseLabel extends MarginContainer

@export var case: String = "": set = _on_set_case

@onready var case_label: Button = %Case

const fallback_icon = preload("../../assets/Fallback.svg")

#region LIFECYCLE
func _ready() -> void:
	_render()

func _render() -> void:
	# TODO: add well-known value from Dialogue AST
	if is_node_ready():
		case_label.text = case.capitalize()
		case_label.icon = fallback_icon if case == MatchNodeAst.fallback_key else null
#endregion

#region SETTERS
func _on_set_case(new_case: String) -> void:
	case = new_case
	_render()
#endregion
