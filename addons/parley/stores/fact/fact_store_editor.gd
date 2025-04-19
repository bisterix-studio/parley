@tool
class_name ParleyFactStoreEditor extends PanelContainer


#region DEFS
const FactEditor: PackedScene = preload("../../components/fact/fact_editor.tscn")


var dialogue_sequence_ast: DialogueAst: set = _set_dialogue_sequence_ast
var available_fact_store_paths: Array[String]: get = _get_available_fact_store_paths
var available_fact_stores: Dictionary[String, FactStore] = {}
var fact_filter: String = "": set = _set_fact_filter
var selected_fact_stores: Array[String] = []: set = _set_selected_fact_stores
var facts: Array[Fact] = []: set = _set_facts
var filtered_facts: Array[Fact] = []


@onready var available_fact_store_label: Label = %AvailableFactStoresLabel
@onready var available_fact_store_menu: MenuButton = %AvailableFactStores
@onready var fact_store_selector_label: Label = %FactStoreSelectorLabel
@onready var fact_store_selector: OptionButton = %FactStoreSelector
@onready var facts_container: VBoxContainer = %FactsContainer
@onready var dialogue_sequence_container: ParleyResourceEditor = %DialogueSequenceContainer
@onready var add_fact_button: Button = %AddFactButton


signal dialogue_sequence_ast_selected(dialogue_sequence_ast: DialogueAst)
signal dialogue_sequence_ast_changed(dialogue_sequence_ast: DialogueAst)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_setup()
	_render()


func _setup() -> void:
	_setup_available_fact_stores()


func _clear_facts() -> void:
	for child: Node in facts_container.get_children():
		child.queue_free()
#endregion


#region SETTERS
func _update_facts() -> void:
	if fact_store_selector and fact_store_selector.selected != -1:
		# The first item is always the combined view
		if fact_store_selector.selected == 0:
			var all_facts: Array[Fact] = []
			# TODO: there is the chance of duplicates here but let's allow this for now
			for fact_store: FactStore in available_fact_stores.values():
				all_facts.append_array(fact_store.facts)
			facts = all_facts
		else:
			var selected_fact_store_ref: String = selected_fact_stores[fact_store_selector.selected - 1]
			var selected_fact_store: FactStore = available_fact_stores.get(selected_fact_store_ref)
			facts = selected_fact_store.facts


func _setup_available_fact_stores() -> void:
	available_fact_stores = {}
	for fact_store_path: String in available_fact_store_paths:
		var fact_store: FactStore = load(fact_store_path)
		if fact_store.resource_path and not available_fact_stores.has(fact_store.resource_path):
			var _set_ok: bool = available_fact_stores.set(fact_store.resource_path, fact_store)


func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: DialogueAst) -> void:
	if dialogue_sequence_ast != new_dialogue_sequence_ast:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		_render_dialogue_sequence()
		var new_selected_fact_stores: Array[String] = []
		for store: FactStore in dialogue_sequence_ast.stores.fact:
			new_selected_fact_stores.append(store.resource_path)
		selected_fact_stores = new_selected_fact_stores


func _set_selected_fact_stores(new_selected_fact_stores: Array[String]) -> void:
	if selected_fact_stores != new_selected_fact_stores:
		selected_fact_stores = new_selected_fact_stores
		_render_available_fact_store_menu()
		_render_selected_fact_stores()
		_update_facts()


func _set_selected_fact_store(index: int) -> void:
	var new_fact_stores: Array[String] = selected_fact_stores.duplicate(true)
	var selected_fact_store: FactStore = available_fact_stores.values()[index]
	var selected_fact_store_index: int = selected_fact_stores.find(selected_fact_store.resource_path)
	if selected_fact_store_index == -1:
		new_fact_stores.append(selected_fact_store.resource_path)
	else:
		new_fact_stores.remove_at(selected_fact_store_index)
	selected_fact_stores = new_fact_stores


func _set_facts(new_facts: Array[Fact]) -> void:
	facts = new_facts
	filtered_facts = []
	for fact: Fact in facts:
		var raw_fact_string: String = str(inst_to_dict(fact))
		if not fact_filter or raw_fact_string.containsn(fact_filter):
			filtered_facts.append(fact)
	_render_facts()


func _set_fact_filter(new_fact_filter: String) -> void:
	fact_filter = new_fact_filter
	_set_facts(facts)
#endregion


#region RENDERERS
func _render() -> void:
	_render_available_fact_store_menu()
	_render_dialogue_sequence()
	_render_selected_fact_stores()
	_render_add_fact_button()
	_update_facts()
	_render_facts()


func _render_available_fact_store_menu() -> void:
	if not available_fact_store_menu:
		return
	var popup: PopupMenu = available_fact_store_menu.get_popup()
	popup.clear()
	var index: int = 0
	for available_fact_store: FactStore in available_fact_stores.values():
		popup.add_check_item(str(available_fact_store.id).capitalize())
		var checked: bool = selected_fact_stores.filter(func(ref: String) -> bool:
				var fact_store: FactStore = available_fact_stores.get(ref)
				return fact_store.id == available_fact_store.id).size() > 0
		popup.set_item_checked(index, checked)
		index += 1
	ParleyUtils.safe_connect(popup.id_pressed, _on_available_fact_store_pressed)
	popup.hide_on_checkable_item_selection = false
	available_fact_store_label.text = "Available:"
	available_fact_store_menu.text = "%s/%s Selected" % [selected_fact_stores.size(), available_fact_stores.size()]
	fact_store_selector_label.text = "Selected:"


func _render_dialogue_sequence() -> void:
	if dialogue_sequence_container and dialogue_sequence_ast and dialogue_sequence_ast.resource_path:
		dialogue_sequence_container.base_type = DialogueAst.type_name
		dialogue_sequence_container.resource = dialogue_sequence_ast


func _render_available_fact_stores() -> void:
	if not fact_store_selector:
		return
	fact_store_selector.clear()
	if not available_fact_stores:
		return
	for available_fact_store: FactStore in available_fact_stores.values():
		fact_store_selector.add_item(str(available_fact_store.id).capitalize())
	fact_store_selector.select(0 if available_fact_stores.size() > 0 else -1)


func _render_add_fact_button() -> void:
	if add_fact_button and fact_store_selector:
		add_fact_button.tooltip_text = "Add Fact to the currently selected store. If no store is explicitly set, this button will not be activated."
		if fact_store_selector:
			# This is because the first option is always the "All" option
			add_fact_button.disabled = [0, -1].has(fact_store_selector.selected)


func _render_selected_fact_stores() -> void:
	if not fact_store_selector:
		return
	var current_text: String = fact_store_selector.get_item_text(fact_store_selector.selected) if fact_store_selector.selected != -1 else ""
	fact_store_selector.clear()
	fact_store_selector.add_item('All')
	var items: Array[String] = []
	for fact_store_ref: String in selected_fact_stores:
		var fact_store: FactStore = load(fact_store_ref)
		var text: String = str(fact_store.id).capitalize()
		items.append(text)
		fact_store_selector.add_item(text)
	var current_index: int = items.find(current_text)
	if current_index == -1:
		current_index = 0
	else:
		current_index += 1
	fact_store_selector.select(current_index)


func _render_facts() -> void:
	if facts_container:
		_clear_facts()
		var index: int = 0
		for fact: Fact in filtered_facts:
			var fact_editor: ParleyFactEditor = FactEditor.instantiate()
			fact_editor.fact_id = fact.id
			fact_editor.fact_name = fact.name
			fact_editor.fact_ref = fact.ref
			ParleyUtils.safe_connect(fact_editor.fact_changed, _on_fact_changed.bind(fact))
			ParleyUtils.safe_connect(fact_editor.fact_removed, _on_fact_removed.bind(fact))
			facts_container.add_child(fact_editor)
			if index != filtered_facts.size() - 1:
				var horizontal_separator: HSeparator = HSeparator.new()
				facts_container.add_child(horizontal_separator)
			index += 1
#endregion


#region SIGNALS
func _on_fact_changed(new_id: String, new_name: String, new_resource: Resource, fact: Fact) -> void:
	fact.id = new_id
	fact.name = new_name
	fact.ref = new_resource
	var store_ref: String = FactStore.get_fact_store_ref(fact)
	if available_fact_stores.has(store_ref):
		var store: FactStore = available_fact_stores.get(store_ref)
		if store.resource_path == store_ref:
			store.emit_changed()


func _on_fact_removed(fact_id: String, fact: Fact) -> void:
	var store_ref: String = FactStore.get_fact_store_ref(fact)
	if available_fact_stores.has(store_ref):
		var store: FactStore = available_fact_stores.get(store_ref)
		if store.resource_path == store_ref:
			store.remove_fact(fact_id)
	_render_selected_fact_stores()
	_render_add_fact_button()
	_update_facts()
	_render_facts()


func _on_add_fact_button_pressed() -> void:
	if fact_store_selector and not [-1, 0].has(fact_store_selector.selected):
		var fact_store_ref: String = selected_fact_stores[fact_store_selector.selected - 1]
		if available_fact_stores.has(fact_store_ref):
			var store: FactStore = available_fact_stores.get(fact_store_ref)
			if store.resource_path == fact_store_ref:
				var _new_fact: Fact = store.add_fact()
		_render_selected_fact_stores()
		_render_add_fact_button()
		_update_facts()
		_render_facts()


func _on_available_fact_store_pressed(id: int) -> void:
	var popup: PopupMenu = available_fact_store_menu.get_popup()
	var index: int = popup.get_item_index(id)
	popup.set_item_checked(index, not popup.is_item_checked(index))
	_set_selected_fact_store(index)


func _on_fact_store_selector_item_selected(_index: int) -> void:
	_render_add_fact_button()
	_update_facts()


func _on_filter_facts_text_changed(new_fact_filter: String) -> void:
	fact_filter = new_fact_filter


func _on_save_fact_store_button_pressed() -> void:
	_save()


func _on_dialogue_sequence_container_resource_changed(new_dialogue_sequence_ast: Resource) -> void:
	if new_dialogue_sequence_ast is DialogueAst:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		dialogue_sequence_ast_changed.emit(dialogue_sequence_ast)


func _on_dialogue_sequence_container_resource_selected(selected_dialogue_sequence_ast: Resource, _inspect: bool) -> void:
	if dialogue_sequence_ast is DialogueAst:
		dialogue_sequence_ast_selected.emit(selected_dialogue_sequence_ast)
#endregion


#region ACTIONS
func _save() -> void:
	if fact_store_selector and fact_store_selector.selected != -1:
		if fact_store_selector.selected == 0:
			for fact_store_ref: String in selected_fact_stores:
				var fact_store: FactStore = available_fact_stores.get(fact_store_ref)
				var result: int = ResourceSaver.save(fact_store)
				if result != OK:
					ParleyUtils.log.error("Error saving fact store [ID: %s]. Code: %d" % [fact_store.id, result])
					return
		else:
			var fact_store_ref: String = selected_fact_stores[fact_store_selector.selected - 1]
			var fact_store: FactStore = load(fact_store_ref)
			# TODO: maybe use emit changed at the resource level?
			var result: int = ResourceSaver.save(fact_store)
			if result != OK:
				ParleyUtils.log.error("Error saving fact store [ID: %s]. Code: %d" % [fact_store.id, result])
				return
#endregion


#region UTILS
func _get_available_fact_store_paths() -> Array[String]:
	return ParleyManager.fact_stores
#endregion
