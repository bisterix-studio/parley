@tool
# TODO: prefix with Parley
class_name MatchNodeEditor extends NodeEditor

var fact_store: FactStore = FactStore.new(): set = _on_set_fact_store
var description: String = "": set = _on_set_description
var fact_name: String = "": set = _on_set_fact_name
var cases: Array[Variant] = []: set = _on_set_cases

@onready var description_editor: TextEdit = %MatchDescription
@onready var fact_selector: OptionButton = %FactSelector
@onready var cases_editor: VBoxContainer = %CasesEditor
@onready var add_case_button: Button = %AddCaseButton
@onready var add_fallback_case_button: Button = %AddFallbackCaseButton

const case_editor: PackedScene = preload("./case.tscn")

var available_cases: Array[Variant] = [MatchNodeAst.fallback_key]
var has_fallback: bool = false: set = _on_set_has_fallback

signal match_node_changed(id: String, description: String, fact_name: String, cases: Array[Variant])

#region LIFECYCLE
func _ready() -> void:
	set_title()
	_render_description()
	# TODO: revert the fact store input
	_render_fact()
	_render_cases()

func _render_fact() -> void:
	if not fact_selector:
		return
	fact_selector.clear()
	if not fact_store:
		return
	for fact: Fact in fact_store.facts:
		fact_selector.add_item(fact.name)
	_select_fact()

func _select_fact() -> void:
	if fact_store and fact_selector:
		var selected_index: int = fact_store.get_fact_index_by_name(fact_name)
		if fact_selector.selected != selected_index and selected_index < fact_selector.item_count:
			fact_selector.select(selected_index)
#endregion

#region SETTERS
func _on_set_fact_store(new_fact_store: FactStore) -> void:
	fact_store = new_fact_store
	_render_fact()

func _on_set_description(new_description: String) -> void:
	description = new_description
	_render_description()

func _render_description() -> void:
	if description_editor and description_editor.text != description:
		description_editor.text = description

func _on_set_has_fallback(_has_fallback: bool) -> void:
	has_fallback = _has_fallback
	if add_fallback_case_button:
		add_fallback_case_button.disabled = has_fallback

func _on_set_fact_name(new_fact_name: String) -> void:
	fact_name = new_fact_name
	_select_fact()
	if fact_store and fact_store.has_fact_name(fact_name):
		var fact: Fact = fact_store.get_fact_by_name(fact_name)
		# TODO: new may not exist
		var fact_interface: FactInterface = load(fact.ref.resource_path).new()
		# TODO: check if method exists
		var new_available_cases: Array[Variant] = []
		new_available_cases.append_array(fact_interface.available_values())
		# TODO: create a wrapper for this
		fact_interface.call_deferred("free")
		new_available_cases.append(MatchNodeAst.fallback_key)
		available_cases = new_available_cases
		var filtered_cases: Array[Variant] = []
		for case: Variant in cases:
			if available_cases.size() == 1 or available_cases.has(case):
				filtered_cases.append(case)
		cases = filtered_cases

func _on_set_cases(new_cases: Array[Variant]) -> void:
	# TODO: move to helper
	var keys: Dictionary = {}
	for case: Variant in new_cases:
		if not case in keys:
			keys[case] = case
	var filtered_cases: Array[Variant] = []
	for key: Variant in keys.keys():
		filtered_cases.append(key)
	if filtered_cases.hash() == cases.hash():
		return
	cases = filtered_cases
	_render_cases()

func _render_cases() -> void:
	if cases_editor:
		for child: Node in cases_editor.get_children():
			if child is CaseEditor:
				cases_editor.remove_child(child)
				child.queue_free()
		var index: int = 0
		var _has_fallback: bool = false
		for case: Variant in cases:
			var case_inst: CaseEditor = case_editor.instantiate()
			case_inst.available_cases = available_cases
			case_inst.value = case
			if case is String and case == MatchNodeAst.fallback_key:
				case_inst.value = MatchNodeAst.fallback_key
				case_inst.is_fallback = true
				_has_fallback = true
			else:
				case_inst.value = case

			case_inst.case_edited.connect(_on_case_edited.bind(index))
			case_inst.case_deleted.connect(_on_case_deleted.bind(index))
			cases_editor.add_child(case_inst)
			index += 1
		has_fallback = _has_fallback
#endregion

#region SIGNALS
func _on_case_edited(value: String, is_fallback: bool, index: int) -> void:
	cases[index] = MatchNodeAst.fallback_key if is_fallback else value
	_emit_match_node_changed()

func _on_case_deleted(index: int) -> void:
	var new_cases: Array[Variant] = cases.duplicate()
	new_cases.remove_at(index)
	cases = new_cases
	_emit_match_node_changed()

func _on_match_description_text_changed() -> void:
	description = description_editor.text
	_emit_match_node_changed()

func _on_fact_selector_item_selected(index: int) -> void:
	var new_fact_name: String = fact_selector.get_item_text(index)
	fact_name = new_fact_name
	_emit_match_node_changed()

func _on_add_case_button_pressed() -> void:
	var new_cases: Array[Variant] = cases.duplicate()
	var next_case: Variant
	for case: Variant in available_cases:
		if case not in cases:
			next_case = case
			break
	new_cases.append(next_case)
	cases = new_cases
	_emit_match_node_changed()

func _on_add_fallback_case_button_pressed() -> void:
	var new_cases: Array[Variant] = cases.duplicate()
	new_cases.append(MatchNodeAst.fallback_key)
	cases = new_cases
	_emit_match_node_changed()

func _emit_match_node_changed() -> void:
	match_node_changed.emit(id, description, fact_name, cases)
#endregion
