@tool
extends PanelContainer

#region VARIABLES
const FactEditor = preload("../../components/fact/fact_editor.tscn")

var available_fact_store_paths: Array[String]: get = _get_available_fact_store_paths
var available_fact_stores: Array[FactStore] = []
var selected_fact_stores: Array[FactStore] = []: set = _set_selected_fact_stores
var facts: Array[Fact] = []: set = _set_facts
var filtered_facts: Array[Fact] = []
var fact_filter: String = "": set = _set_fact_filter

@onready var available_fact_store_label: Label = %AvailableFactStoresLabel
@onready var available_fact_store_menu: MenuButton = %AvailableFactStores
@onready var fact_store_selector_label: Label = %FactStoreSelectorLabel
@onready var fact_store_selector: OptionButton = %FactStoreSelector
@onready var facts_filter: LineEdit = %FilterFacts
@onready var facts_container: VBoxContainer = %FactsContainer
#endregion

#region LIFECYCLE
func _ready() -> void:
	_setup()
	_render_available_fact_store_menu()
	_render_selected_fact_stores()
	_update_facts()
	_render_facts()

func _setup() -> void:
	for fact_store_path in available_fact_store_paths:
		available_fact_stores.append(load(fact_store_path))

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
			for fact_store: FactStore in available_fact_stores:
				all_facts.append_array(fact_store.facts)
			facts = all_facts
		else:
			var selected_fact_store: FactStore = selected_fact_stores[fact_store_selector.selected - 1]
			facts = selected_fact_store.facts

func _set_selected_fact_stores(new_selected_fact_stores: Array[FactStore]) -> void:
	selected_fact_stores = new_selected_fact_stores
	_render_available_fact_store_menu()
	_render_selected_fact_stores()
	_update_facts()

func _set_selected_fact_store(index: int) -> void:
	var new_fact_stores = selected_fact_stores
	var selected_fact_store = available_fact_stores[index]
	var selected_fact_store_index = selected_fact_stores.find(selected_fact_store)
	if selected_fact_store_index == -1:
		new_fact_stores.append(selected_fact_store)
	else:
		new_fact_stores.remove_at(selected_fact_store_index)
	selected_fact_stores = new_fact_stores

func _set_facts(new_facts: Array[Fact]) -> void:
	facts = new_facts
	filtered_facts = []
	for fact in facts:
		var raw_fact_string = str(inst_to_dict(fact))
		if not fact_filter or raw_fact_string.containsn(fact_filter):
			filtered_facts.append(fact)
	_render_facts()

func _set_fact_filter(new_fact_filter: String) -> void:
	fact_filter = new_fact_filter
	_set_facts(facts)
#endregion

#region RENDERERS
func _render_available_fact_store_menu() -> void:
	if not available_fact_store_menu:
		return
	var popup: PopupMenu = available_fact_store_menu.get_popup()
	popup.clear()
	var index: int = 0
	for available_fact_store in available_fact_stores:
		popup.add_check_item(str(available_fact_store.id).capitalize())
		var checked: bool = selected_fact_stores.filter(func(c: FactStore) -> bool: return c.id == available_fact_store.id).size() > 0
		popup.set_item_checked(index, checked)
		index += 1
	if not popup.id_pressed.is_connected(_on_available_fact_store_pressed):
		popup.id_pressed.connect(_on_available_fact_store_pressed)
	popup.hide_on_checkable_item_selection = false
	available_fact_store_label.text = "Available:"
	available_fact_store_menu.text = "%s/%s Selected" % [selected_fact_stores.size(), available_fact_stores.size()]
	fact_store_selector_label.text = "Selected:"

func _render_available_fact_stores() -> void:
	if not fact_store_selector:
		return
	fact_store_selector.clear()
	if not available_fact_stores:
		return
	for available_fact_store: FactStore in available_fact_stores:
		fact_store_selector.add_item(str(available_fact_store.id).capitalize())
	fact_store_selector.select(0 if available_fact_stores.size() > 0 else -1)

func _render_selected_fact_stores() -> void:
	if not fact_store_selector:
		return
	fact_store_selector.clear()
	fact_store_selector.add_item('All')
	for fact_store: FactStore in selected_fact_stores:
		fact_store_selector.add_item(str(fact_store.id).capitalize())
	# TODO: account for current selected to make for better UX rather than
	# just taking the first item all the time
	fact_store_selector.select(0)

func _render_facts() -> void:
	if facts_container:
		_clear_facts()
		var index: int = 0
		for fact: Fact in filtered_facts:
			var fact_editor = FactEditor.instantiate()
			fact_editor.fact_id = fact.id
			fact_editor.fact_name = fact.name
			fact_editor.fact_ref = fact.ref
			fact_editor.fact_changed.connect(_on_fact_changed.bind(fact))
			facts_container.add_child(fact_editor)
			if index != filtered_facts.size() - 1:
				var horizontal_separator: HSeparator = HSeparator.new()
				facts_container.add_child(horizontal_separator)
			index += 1
#endregion

#region SIGNALS
func _on_fact_changed(id: String, name: String, resource: Resource, fact: Fact) -> void:
	fact.id = id
	fact.name = name
	fact.ref = resource
	fact.emit_changed()

func _on_available_fact_store_pressed(id: int) -> void:
	var popup: PopupMenu = available_fact_store_menu.get_popup()
	var index: int = popup.get_item_index(id)
	popup.set_item_checked(index, not popup.is_item_checked(index))
	_set_selected_fact_store(index)

func _on_fact_store_selector_item_selected(index: int) -> void:
	_update_facts()

func _on_filter_facts_text_changed(new_fact_filter: String) -> void:
	fact_filter = new_fact_filter

func _on_save_fact_store_button_pressed() -> void:
	if fact_store_selector and fact_store_selector.selected != -1:
		if fact_store_selector.selected == 0:
			for fact_store: FactStore in selected_fact_stores:
				ResourceSaver.save(fact_store)
		else:
			var fact_store: FactStore = selected_fact_stores[fact_store_selector.selected - 1]
			# TODO: maybe use emit changed at the resource level?
			ResourceSaver.save(fact_store)
#endregion

#region UTILS
func _get_available_fact_store_paths() -> Array[String]:
	return ParleyManager.fact_stores
#endregion
