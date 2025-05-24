@tool
class_name ParleyActionStoreEditor extends PanelContainer


#region DEFS
const ActionScriptEditor: PackedScene = preload("../../components/action/action_script_editor.tscn")


var action_store: ActionStore = ActionStore.new(): set = _set_action_store
var dialogue_sequence_ast: DialogueAst: set = _set_dialogue_sequence_ast
var action_filter: String = "": set = _set_action_filter
var actions: Array[Action] = []: set = _set_actions
var filtered_actions: Array[Action] = []


@onready var actions_container: VBoxContainer = %ActionsContainer
@onready var action_store_editor: ParleyResourceEditor = %ActionStore
@onready var dialogue_sequence_container: ParleyResourceEditor = %DialogueSequenceContainer
@onready var add_action_button: Button = %AddActionButton
@onready var save_action_store_button: Button = %SaveActionStoreButton
@onready var invalid_action_store_button: Button = %InvalidActionStoreButton
@onready var new_action_store_button: Button = %NewActionStoreButton
@onready var register_action_store: ParleyRegisterStoreModal = %RegisterActionStoreModal


signal dialogue_sequence_ast_selected(dialogue_sequence_ast: DialogueAst)
signal dialogue_sequence_ast_changed(dialogue_sequence_ast: DialogueAst)
#endregion


#region LIFECYCLE
func _ready() -> void:
	action_store_editor.resource = action_store
	actions = action_store.actions
	_render()


func _clear_actions() -> void:
	for child: Node in actions_container.get_children():
		child.queue_free()
#endregion


#region SETTERS
func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: DialogueAst) -> void:
	if dialogue_sequence_ast != new_dialogue_sequence_ast:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		_reload_dialogue_sequence_ast()


func _reload_dialogue_sequence_ast() -> void:
	_render_dialogue_sequence()


func _set_action_store(new_action_store: ActionStore) -> void:
	if action_store != new_action_store:
		action_store = new_action_store
		if action_store_editor.resource != action_store:
			action_store_editor.resource = action_store
		if action_store:
			actions = action_store.actions
		else:
			actions = []
	_render_save_action_store_button()
	_render_invalid_action_store_button()

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
	_render_action_store_editor()
	_render_dialogue_sequence()
	_render_add_action_button()
	_render_new_action_store_button()
	_render_save_action_store_button()
	_render_invalid_action_store_button()
	_render_actions()

func _render_dialogue_sequence() -> void:
	if dialogue_sequence_container and dialogue_sequence_ast and dialogue_sequence_ast.resource_path:
		dialogue_sequence_container.base_type = DialogueAst.type_name
		dialogue_sequence_container.resource = dialogue_sequence_ast


func _render_add_action_button() -> void:
	if add_action_button:
		add_action_button.tooltip_text = "Add Action to the currently selected store."


func _render_action_store_editor() -> void:
	if action_store_editor and (not action_store or not action_store.resource_path):
		action_store_editor.resource = null


func _render_save_action_store_button() -> void:
	if save_action_store_button:
		save_action_store_button.tooltip_text = "Save Action Store."
		if not action_store or not action_store.resource_path:
			save_action_store_button.hide()
		else:
			save_action_store_button.show()


func _render_invalid_action_store_button() -> void:
	if invalid_action_store_button:
		invalid_action_store_button.tooltip_text = "Invalid Action Store because it does not contain a resource path, please rectify or create and register a new Action Store."
		if action_store and action_store.resource_path:
			invalid_action_store_button.hide()
		else:
			invalid_action_store_button.show()


func _render_new_action_store_button() -> void:
	if new_action_store_button:
		new_action_store_button.tooltip_text = "Create and register new Action Store."


func _render_actions() -> void:
	if actions_container:
		_clear_actions()
		var index: int = 0
		for action: Action in filtered_actions:
			var action_script_editor: ParleyActionScriptEditor = ActionScriptEditor.instantiate()
			action_script_editor.action_id = action.id
			action_script_editor.action_name = action.name
			action_script_editor.action_ref = action.ref
			ParleyUtils.signals.safe_connect(action_script_editor.action_changed, _on_action_changed.bind(action))
			ParleyUtils.signals.safe_connect(action_script_editor.action_removed, _on_action_removed.bind(action))
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
	action_store.emit_changed()


func _on_action_removed(action_id: String, _action: Action) -> void:
	action_store.remove_action(action_id)
	actions = action_store.actions


func _on_add_action_button_pressed() -> void:
	var _new_action: Action = action_store.add_action()
	actions = action_store.actions


func _on_filter_actions_text_changed(new_action_filter: String) -> void:
	action_filter = new_action_filter


func _on_save_action_store_button_pressed() -> void:
	_save()


func _on_new_action_store_button_pressed() -> void:
	register_action_store.show()
	register_action_store.clear()
	register_action_store.file_mode = FileDialog.FileMode.FILE_MODE_SAVE_FILE
	register_action_store.resource_editor.resource = ActionStore.new()
	# TODO: get from config
	register_action_store.path_edit.text = "res://actions/new_action_store.tres"
	register_action_store.id_valid = true
	register_action_store.script_valid = true
	register_action_store.resource_exists = true


func _on_dialogue_sequence_container_resource_changed(new_dialogue_sequence_ast: Resource) -> void:
	if new_dialogue_sequence_ast is DialogueAst:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		dialogue_sequence_ast_changed.emit(dialogue_sequence_ast)


func _on_dialogue_sequence_container_resource_selected(selected_dialogue_sequence_ast: Resource, _inspect: bool) -> void:
	if dialogue_sequence_ast is DialogueAst:
		dialogue_sequence_ast_selected.emit(selected_dialogue_sequence_ast)


func _on_register_action_store_modal_store_registered(store: ParleyStore) -> void:
	_register_action_store(store, true)


func _on_action_store_resource_changed(store: Resource) -> void:
	prints(store, store is ActionStore)
	if store is ActionStore:
		_register_action_store(store as ActionStore, true)
	else:
		action_store = null
#endregion


#region ACTIONS
func _register_action_store(store: ParleyStore, new: bool) -> void:
	if store is ActionStore:
		action_store = store
		if new:
			# TODO: can we get rid of this global ref?
			ParleyManager.get_instance().register_action_store(action_store)
		_render()


func _save() -> void:
	var result: int = ResourceSaver.save(action_store)
	if result != OK:
		ParleyUtils.log.error("Error saving action store [ID: %s]. Code: %d" % [action_store.id, result])
		return
#endregion


#region UTILS
func _get_available_action_store() -> ActionStore:
	# TODO: populate from plugin
	# TODO: can we get rid of this global ref?
	return ParleyManager.get_instance().action_store
#endregion
