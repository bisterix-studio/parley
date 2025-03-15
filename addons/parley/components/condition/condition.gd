@tool

extends VBoxContainer

@export var id: int = 0
@export var fact_name: String = "": set = _on_fact_selected
@export var operator: ConditionNodeAst.Operator = ConditionNodeAst.Operator.EQUAL
@export var value: String = ""

@onready var fact_selector: OptionButton = %FactSelector
@export var operator_editor: OptionButton
@export var value_editor: LineEdit

signal condition_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_render_fact_options()
	operator_editor.clear()
	for key in ConditionNodeAst.Operator:
		operator_editor.add_item(key.capitalize(), ConditionNodeAst.Operator[key])
	update(fact_name, operator, value)


func _render_fact_options() -> void:
	fact_selector.clear()
	if not ParleyManager.fact_store:
		return
	for fact in ParleyManager.fact_store.facts:
		fact_selector.add_item(fact.name)
	_select_fact()


func update(p_fact_name: String, p_operator: ConditionNodeAst.Operator, p_value: String) -> void:
	fact_name = p_fact_name
	operator = p_operator
	operator_editor.selected = operator
	value = p_value
	value_editor.text = value


func _on_fact_selected(new_fact_name: String) -> void:
	fact_name = new_fact_name
	_select_fact()


func _select_fact() -> void:
	if fact_selector:
		var selected_index = ParleyManager.fact_store.get_fact_index_by_name(fact_name)
		if fact_selector.selected != selected_index:
			fact_selector.select(selected_index)


#region SIGNALS
func _on_operator_editor_item_selected(selected_operator: int) -> void:
	operator = selected_operator
	_emit_condition_changed()


func _on_value_editor_text_changed(new_value: String) -> void:
	value = new_value
	_emit_condition_changed()


func _on_fact_selector_item_selected(index: int) -> void:
	var new_fact_name = fact_selector.get_item_text(index)
	fact_name = new_fact_name
	_emit_condition_changed()

func _emit_condition_changed() -> void:
	condition_changed.emit(id, fact_name, operator, value)
#endregion
