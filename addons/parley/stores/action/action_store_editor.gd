@tool
class_name ParleyActionStoreEditor extends PanelContainer


#region DEFS
const ActionScriptEditor: PackedScene = preload("../../components/action/action_script_editor.tscn")


var dialogue_sequence_ast: DialogueAst: set = _set_dialogue_sequence_ast
var available_action_store_paths: Array[String]: get = _get_available_action_store_paths
var available_action_stores: Dictionary[String, ActionStore] = {}
var action_filter: String = "": set = _set_action_filter
var selected_action_stores: Array[String] = []: set = _set_selected_action_stores
var actions: Array[Action] = []: set = _set_actions
var filtered_actions: Array[Action] = []


@onready var available_action_store_label: Label = %AvailableActionStoresLabel
@onready var available_action_store_menu: MenuButton = %AvailableActionStores
@onready var action_store_selector_label: Label = %ActionStoreSelectorLabel
@onready var action_store_selector: OptionButton = %ActionStoreSelector
@onready var actions_container: VBoxContainer = %ActionsContainer
@onready var dialogue_sequence_container: ParleyResourceEditor = %DialogueSequenceContainer
@onready var add_action_button: Button = %AddActionButton
@onready var register_action_store: ParleyRegisterStoreModal = %RegisterActionStore


signal dialogue_sequence_ast_selected(dialogue_sequence_ast: DialogueAst)
signal dialogue_sequence_ast_changed(dialogue_sequence_ast: DialogueAst)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_setup()
	_render()


func _setup() -> void:
	_setup_available_action_stores()


func _clear_actions() -> void:
	for child: Node in actions_container.get_children():
		child.queue_free()
#endregion


#region SETTERS
func _update_actions() -> void:
	if action_store_selector and action_store_selector.selected != -1:
		# The first item is always the combined view
		if action_store_selector.selected == 0:
			var all_actions: Array[Action] = []
			# TODO: there is the chance of duplicates here but let's allow this for now
			for action_store: ActionStore in available_action_stores.values():
				all_actions.append_array(action_store.actions)
			actions = all_actions
		else:
			var selected_action_store_ref: String = selected_action_stores[action_store_selector.selected - 1]
			var selected_action_store: ActionStore = available_action_stores.get(selected_action_store_ref)
			actions = selected_action_store.actions


func _setup_available_action_stores() -> void:
	available_action_stores = {}
	for action_store_path: String in available_action_store_paths:
		var action_store: ActionStore = load(action_store_path)
		if action_store.resource_path and not available_action_stores.has(action_store.resource_path):
			var _set_ok: bool = available_action_stores.set(action_store.resource_path, action_store)


func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: DialogueAst) -> void:
	if dialogue_sequence_ast != new_dialogue_sequence_ast:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		_reload_dialogue_sequence_ast()


func _reload_dialogue_sequence_ast() -> void:
	_render_dialogue_sequence()
	var new_selected_action_stores: Array[String] = []
	for store: ActionStore in dialogue_sequence_ast.stores.action:
		new_selected_action_stores.append(store.resource_path)
	selected_action_stores = new_selected_action_stores


func _set_selected_action_stores(new_selected_action_stores: Array[String]) -> void:
	if selected_action_stores != new_selected_action_stores:
		selected_action_stores = new_selected_action_stores
		_render_available_action_store_menu()
		_render_selected_action_stores()
		_update_actions()


func _set_selected_action_store(index: int) -> void:
	var new_action_stores: Array[String] = selected_action_stores.duplicate(true)
	var selected_action_store: ActionStore = available_action_stores.values()[index]
	var selected_action_store_index: int = selected_action_stores.find(selected_action_store.resource_path)
	if selected_action_store_index == -1:
		new_action_stores.append(selected_action_store.resource_path)
		# TODO: handle deregistration
		_register_action_store(selected_action_store, false)
	else:
		new_action_stores.remove_at(selected_action_store_index)
	selected_action_stores = new_action_stores


func _set_actions(new_actions: Array[Action]) -> void:
	actions = new_actions
	filtered_actions = []
	for action: Action in actions:
		var raw_action_string: String = str(inst_to_dict(action))
		if not action_filter or raw_action_string.containsn(action_filter):
			filtered_actions.append(action)
	_render_actions()


func _set_action_filter(new_action_filter: String) -> void:
	action_filter = new_action_filter
	_set_actions(actions)
#endregion


#region RENDERERS
func _render() -> void:
	_render_available_action_store_menu()
	_render_dialogue_sequence()
	_render_selected_action_stores()
	_render_add_action_button()
	_update_actions()
	_render_actions()


func _render_available_action_store_menu() -> void:
	if not available_action_store_menu:
		return
	var popup: PopupMenu = available_action_store_menu.get_popup()
	popup.clear()
	var index: int = 0
	for available_action_store: ActionStore in available_action_stores.values():
		popup.add_check_item(str(available_action_store.id).capitalize())
		var checked: bool = selected_action_stores.filter(func(ref: String) -> bool:
				var action_store: ActionStore = available_action_stores.get(ref)
				return action_store.id == available_action_store.id).size() > 0
		popup.set_item_checked(index, checked)
		index += 1
	ParleyUtils.safe_connect(popup.id_pressed, _on_available_action_store_pressed)
	popup.hide_on_checkable_item_selection = false
	available_action_store_label.text = "Available:"
	available_action_store_menu.text = "%s/%s Selected" % [selected_action_stores.size(), available_action_stores.size()]
	action_store_selector_label.text = "Selected:"


func _render_dialogue_sequence() -> void:
	if dialogue_sequence_container and dialogue_sequence_ast and dialogue_sequence_ast.resource_path:
		dialogue_sequence_container.base_type = DialogueAst.type_name
		dialogue_sequence_container.resource = dialogue_sequence_ast


func _render_available_action_stores() -> void:
	if not action_store_selector:
		return
	action_store_selector.clear()
	if not available_action_stores:
		return
	for available_action_store: ActionStore in available_action_stores.values():
		action_store_selector.add_item(str(available_action_store.id).capitalize())
	action_store_selector.select(0 if available_action_stores.size() > 0 else -1)


func _render_add_action_button() -> void:
	if add_action_button and action_store_selector:
		add_action_button.tooltip_text = "Add Action to the currently selected store. If no store is explicitly set, this button will not be activated."
		# This is because the first option is always the "All" option
		add_action_button.disabled = [0, -1].has(action_store_selector.selected)


func _render_selected_action_stores() -> void:
	if not action_store_selector:
		return
	var current_text: String = action_store_selector.get_item_text(action_store_selector.selected) if action_store_selector.selected != -1 else ""
	action_store_selector.clear()
	action_store_selector.add_item('All')
	var items: Array[String] = []
	for action_store_ref: String in selected_action_stores:
		var action_store: ActionStore = load(action_store_ref)
		var text: String = str(action_store.id).capitalize()
		items.append(text)
		action_store_selector.add_item(text)
	var current_index: int = items.find(current_text)
	if current_index == -1:
		current_index = 0
	else:
		current_index += 1
	action_store_selector.select(current_index)


func _render_actions() -> void:
	if actions_container:
		_clear_actions()
		var index: int = 0
		for action: Action in filtered_actions:
			var action_script_editor: ParleyActionScriptEditor = ActionScriptEditor.instantiate()
			action_script_editor.action_id = action.id
			action_script_editor.action_name = action.name
			action_script_editor.action_ref = action.ref
			ParleyUtils.safe_connect(action_script_editor.action_changed, _on_action_changed.bind(action))
			ParleyUtils.safe_connect(action_script_editor.action_removed, _on_action_removed.bind(action))
			actions_container.add_child(action_script_editor)
			if index != filtered_actions.size() - 1:
				var horizontal_separator: HSeparator = HSeparator.new()
				actions_container.add_child(horizontal_separator)
			index += 1
#endregion


#region SIGNALS
func _on_action_changed(new_id: String, new_name: String, new_resource: Resource, action: Action) -> void:
	action.id = new_id
	action.name = new_name
	action.ref = new_resource
	var store_ref: String = ActionStore.get_action_store_ref(action)
	if available_action_stores.has(store_ref):
		var store: ActionStore = available_action_stores.get(store_ref)
		if store.resource_path == store_ref:
			store.emit_changed()


func _on_action_removed(action_id: String, action: Action) -> void:
	var store_ref: String = ActionStore.get_action_store_ref(action)
	if available_action_stores.has(store_ref):
		var store: ActionStore = available_action_stores.get(store_ref)
		if store.resource_path == store_ref:
			store.remove_action(action_id)
	_render_selected_action_stores()
	_render_add_action_button()
	_update_actions()
	_render_actions()


func _on_add_action_button_pressed() -> void:
	if action_store_selector and not [-1, 0].has(action_store_selector.selected):
		var action_store_ref: String = selected_action_stores[action_store_selector.selected - 1]
		if available_action_stores.has(action_store_ref):
			var store: ActionStore = available_action_stores.get(action_store_ref)
			if store.resource_path == action_store_ref:
				var _new_action: Action = store.add_action()
		_render_selected_action_stores()
		_render_add_action_button()
		_update_actions()
		_render_actions()


func _on_available_action_store_pressed(id: int) -> void:
	var popup: PopupMenu = available_action_store_menu.get_popup()
	var index: int = popup.get_item_index(id)
	var selected: bool = not popup.is_item_checked(index)
	popup.set_item_checked(index, selected)
	_set_selected_action_store(index)


func _on_action_store_selector_item_selected(_index: int) -> void:
	_render_add_action_button()
	_update_actions()


func _on_filter_actions_text_changed(new_action_filter: String) -> void:
	action_filter = new_action_filter


func _on_save_action_store_button_pressed() -> void:
	_save()


func _on_new_action_store_button_pressed() -> void:
	register_action_store.show()
	register_action_store.clear()
	register_action_store.file_mode = FileDialog.FileMode.FILE_MODE_SAVE_FILE


func _on_dialogue_sequence_container_resource_changed(new_dialogue_sequence_ast: Resource) -> void:
	if new_dialogue_sequence_ast is DialogueAst:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		dialogue_sequence_ast_changed.emit(dialogue_sequence_ast)


func _on_dialogue_sequence_container_resource_selected(selected_dialogue_sequence_ast: Resource, _inspect: bool) -> void:
	if dialogue_sequence_ast is DialogueAst:
		dialogue_sequence_ast_selected.emit(selected_dialogue_sequence_ast)


func _on_register_action_store_store_registered(store: StoreAst) -> void:
	_register_action_store(store, true)
#endregion


#region ACTIONS
func _register_action_store(store: StoreAst, new: bool) -> void:
	if store is ActionStore:
		var action_store: ActionStore = store
		if new:
			ParleyManager.register_action_store(action_store)
		if dialogue_sequence_ast:
			dialogue_sequence_ast.stores.register_action_store(action_store)
			var _ok: int = ResourceSaver.save(dialogue_sequence_ast)
		_reload_dialogue_sequence_ast()
		_setup()
		_render()
		# TODO: Select this as the current action store


func _save() -> void:
	if action_store_selector and action_store_selector.selected != -1:
		if action_store_selector.selected == 0:
			for action_store_ref: String in selected_action_stores:
				var action_store: ActionStore = available_action_stores.get(action_store_ref)
				var result: int = ResourceSaver.save(action_store)
				if result != OK:
					ParleyUtils.log.error("Error saving action store [ID: %s]. Code: %d" % [action_store.id, result])
					return
		else:
			var action_store_ref: String = selected_action_stores[action_store_selector.selected - 1]
			var action_store: ActionStore = load(action_store_ref)
			# TODO: maybe use emit changed at the resource level?
			var result: int = ResourceSaver.save(action_store)
			if result != OK:
				ParleyUtils.log.error("Error saving action store [ID: %s]. Code: %d" % [action_store.id, result])
				return
#endregion


#region UTILS
func _get_available_action_store_paths() -> Array[String]:
	return ParleyManager.action_stores
#endregion
