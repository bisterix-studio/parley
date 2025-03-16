@tool
extends VBoxContainer

const ParleyConstants = preload("./constants.gd")
const ParleySettings = preload("./settings.gd")

const new_file_icon = preload("./assets/New.svg")
const load_file_icon = preload("./assets/Load.svg")
const export_to_csv_icon = preload("./assets/Export.svg")
const insert_after_icon = preload("./assets/InsertAfter.svg")
const dialogue_icon = preload("./assets/Dialogue.svg")
const dialogue_option_icon = preload("./assets/DialogueOption.svg")
const condition_icon = preload("./assets/Condition.svg")
const action_icon = preload("./assets/Action.svg")
const start_node_icon = preload("./assets/Start.svg")
const end_node_icon = preload("./assets/End.svg")
const group_node_icon = preload("./assets/Group.svg")


@export var dialogue_ast: DialogueAst: set = _set_dialogue_ast


@onready var dialogue_node_editor: DialogueNodeEditor = %DialogueNodeEditor
@onready var dialogue_option_node_editor: DialogueOptionNodeEditor = %DialogueOptionNodeEditor
@onready var condition_node_editor: ConditionNodeEditor = %ConditionNodeEditor
@onready var action_node_editor: ActionNodeEditor = %ActionNodeEditor
@onready var match_node_editor: MatchNodeEditor = %MatchNodeEditor
@onready var start_node_editor: StartNodeEditor = %StartNodeEditor
@onready var end_node_editor: EndNodeEditor = %EndNodeEditor
@onready var group_node_editor: GroupNodeEditor = %GroupNodeEditor

# TODO: use unique name
@export var editor_controls_container: HBoxContainer
@export var edges_editor: EdgesEditor
@onready var graph_view: ParleyGraphView = %GraphView
@export var save_button: Button
@export var arrange_nodes_button: Button
@export var refresh_button: Button
@export var delete_node_button: Button
@export var open_file_dialogue: FileDialog


@onready var file_menu: MenuButton = %FileMenu
@onready var insert_menu: MenuButton = %InsertMenu
@onready var new_dialogue_modal: Window = %NewDialogueModal
@onready var export_to_csv_modal: Window = %ExportToCsvModal
@onready var editor = %EditorView
@onready var sidebar: ParleySidebar = %Sidebar


var selected_node_id
var plugin: EditorPlugin


#region SETUP
func _ready() -> void:
	if Engine.is_editor_hint():
		plugin = Engine.get_meta(ParleyConstants.PARLEY_PLUGIN_METADATA)
	await _setup()
	# TODO: figure this out at a later date
	# ParleyManager.dialogue_imported.connect(_on_parley_manager_dialogue_imported)


# func _on_parley_manager_dialogue_imported(source_file_path):
# 	if dialogue_ast and source_file_path == dialogue_ast.resource_path:
# 		await refresh()


func refresh(arrange: bool = false) -> void:
	if graph_view:
		graph_view.ast = dialogue_ast
		await graph_view.generate(arrange)
	if selected_node_id:
		var selected_node = graph_view.find_node_by_id(selected_node_id)
		if selected_node:
			graph_view.set_selected(selected_node)


func _exit_tree() -> void:
	if dialogue_ast and dialogue_ast.dialogue_updated.is_connected(_on_dialogue_ast_changed):
		dialogue_ast.dialogue_updated.disconnect(_on_dialogue_ast_changed)
	dialogue_ast = null
	# if Engine.is_editor_hint():
	# 	if ParleyManager.dialogue_imported.is_connected(_on_parley_manager_dialogue_imported):
	# 		ParleyManager.dialogue_imported.disconnect(_on_parley_manager_dialogue_imported)


func _set_dialogue_ast(new_dialogue_ast) -> void:
	dialogue_ast = new_dialogue_ast
	if dialogue_ast:
		if dialogue_ast.dialogue_updated.is_connected(_on_dialogue_ast_changed):
			dialogue_ast.dialogue_updated.disconnect(_on_dialogue_ast_changed)
		dialogue_ast.dialogue_updated.connect(_on_dialogue_ast_changed)
		if sidebar:
			sidebar.add_dialogue_ast(dialogue_ast)


# TODO: move to the correct region
func _on_dialogue_ast_changed(new_dialogue_ast: DialogueAst) -> void:
	if sidebar:
		sidebar.current_dialogue_ast = new_dialogue_ast


func _load_current_dialogue_sequence():
	var current_dialogue_sequence_path = ParleySettings.get_user_value(ParleyConstants.EDITOR_CURRENT_DIALOGUE_SEQUENCE_PATH)
	if current_dialogue_sequence_path and ResourceLoader.exists(current_dialogue_sequence_path):
		dialogue_ast = load(current_dialogue_sequence_path)
#endregion

#region SETUP
func _setup() -> void:
	_setup_file_menu()
	_setup_insert_menu()
	_setup_theme()
	_load_current_dialogue_sequence()
	await refresh()


func _setup_theme() -> void:
	# TODO: we might need to register this dynamically at a later date
	# it seems that it only does this at the project level atm.
	save_button.tooltip_text = "Save the current dialogue sequence."
	arrange_nodes_button.tooltip_text = "Arrange the current dialogue sequence nodes."
	refresh_button.tooltip_text = "Refresh the current dialogue sequence."
	delete_node_button.tooltip_text = "Delete the selected node."


## Set up the file menu
func _setup_file_menu() -> void:
	var popup: PopupMenu = file_menu.get_popup()
	popup.clear()
	popup.add_icon_item(new_file_icon, "New Dialogue Sequence...", 0)
	popup.add_icon_item(load_file_icon, "Open Dialogue Sequence...", 1)
	popup.add_separator("Export")
	popup.add_icon_item(export_to_csv_icon, "Export to CSV...", 2)
	popup.id_pressed.connect(_on_file_id_pressed)


## Set up the insert menu
func _setup_insert_menu() -> void:
	var popup: PopupMenu = insert_menu.get_popup()
	popup.clear()
	popup.add_separator("Dialogue")
	popup.add_icon_item(dialogue_icon, DialogueAst.get_type_name(DialogueAst.Type.DIALOGUE), DialogueAst.Type.DIALOGUE)
	popup.add_icon_item(dialogue_option_icon, DialogueAst.get_type_name(DialogueAst.Type.DIALOGUE_OPTION), DialogueAst.Type.DIALOGUE_OPTION)
	popup.add_separator("Conditions")
	popup.add_icon_item(condition_icon, DialogueAst.get_type_name(DialogueAst.Type.CONDITION), DialogueAst.Type.CONDITION)
	popup.add_icon_item(condition_icon, DialogueAst.get_type_name(DialogueAst.Type.MATCH), DialogueAst.Type.MATCH)
	popup.add_separator("Actions")
	popup.add_icon_item(action_icon, DialogueAst.get_type_name(DialogueAst.Type.ACTION), DialogueAst.Type.ACTION)
	popup.add_separator("Misc")
	popup.add_icon_item(start_node_icon, DialogueAst.get_type_name(DialogueAst.Type.START), DialogueAst.Type.START)
	popup.add_icon_item(end_node_icon, DialogueAst.get_type_name(DialogueAst.Type.END), DialogueAst.Type.END)
	popup.add_icon_item(group_node_icon, DialogueAst.get_type_name(DialogueAst.Type.GROUP), DialogueAst.Type.GROUP)
	popup.id_pressed.connect(_on_insert_id_pressed)
#endregion


#region ACTIONS
func _on_file_id_pressed(id: int) -> void:
	match id:
		0:
			new_dialogue_modal.show()
		1:
			open_file_dialogue.show()
			# TODO: get this from config (note, see the Node inspector as well)
			open_file_dialogue.current_dir = "res://dialogue"
		2:
			export_to_csv_modal.dialogue_ast = dialogue_ast
			export_to_csv_modal.render()
		_:
			print("PARLEY_DBG: Unknown option ID pressed: {id}".format({'id': id}))


func _on_graph_view_node_selected(node: Node) -> void:
	if not _is_test_dialogue_sequence_running():
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID, node.id)
	if selected_node_id == node.id:
		return

	_clear_editor()
	if is_instance_of(node, DialogueNode):
		dialogue_node_editor.id = node.id
		dialogue_node_editor.character = node.character
		dialogue_node_editor.dialogue = node.dialogue
		dialogue_node_editor.show()
	elif is_instance_of(node, DialogueOptionNode):
		dialogue_option_node_editor.set_data(node)
		dialogue_option_node_editor.show()
	elif is_instance_of(node, ConditionNode):
		var ast_node = dialogue_ast.find_node_by_id(node.id)
		if not ast_node:
			printerr("PARLEY_ERR: Unable to find AST Node with ID: %s" % [node.id])
			return
		var condition: ConditionNodeAst.Combiner = ast_node.condition
		# Create a separation between layers by duplicating
		var conditions: Array = ast_node.conditions.duplicate(true).map(
			func(condition): return {
				'fact_name': ParleyManager.fact_store.get_fact_by_ref(condition['fact_ref']).name,
				'operator': condition['operator'],
				'value': condition['value'],
			}
		)
		condition_node_editor.update(node.id, node.description, condition, conditions)
		condition_node_editor.show()
	elif is_instance_of(node, MatchNode):
		match_node_editor.id = node.id
		match_node_editor.description = node.description
		# TODO: get this from the node itself and ultimately the JSON definition
		match_node_editor.fact_store = ParleyManager.fact_store
		match_node_editor.fact_name = node.fact_name
		match_node_editor.cases = node.cases
		match_node_editor.show()
	elif is_instance_of(node, ActionNode):
		action_node_editor.id = node.id
		action_node_editor.description = node.description
		action_node_editor.action_type = node.action_type
		action_node_editor.action_script_name = node.action_script_name
		action_node_editor.values = node.values
		action_node_editor.show()
	elif is_instance_of(node, StartNode):
		start_node_editor.id = node.id
		start_node_editor.show()
	elif is_instance_of(node, EndNode):
		end_node_editor.id = node.id
		end_node_editor.show()
	elif is_instance_of(node, GroupNode):
		group_node_editor.id = node.id
		group_node_editor.group_name = node.group_name
		group_node_editor.colour = node.colour
		group_node_editor.show()
	else:
		print("PARLEY_DBG: Unsupported Graph Node selected with ID: %s" % [node.id])
		return
	edges_editor.set_edges(dialogue_ast.edges, node.id)
	edges_editor.show()
	editor_controls_container.show()
	selected_node_id = node.id


func _on_graph_view_node_deselected(node: Node) -> void:
	if not _is_test_dialogue_sequence_running():
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID, null)


func _is_test_dialogue_sequence_running() -> bool:
	if ParleySettings.get_setting(ParleyConstants.TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST):
		return true
	return false
#endregion


#region BUTTONS
func _on_open_dialog_file_selected(path: String) -> void:
	dialogue_ast = load(path)
	ParleySettings.set_user_value(ParleyConstants.EDITOR_CURRENT_DIALOGUE_SEQUENCE_PATH, path)
	refresh()


func _on_new_dialogue_modal_dialogue_ast_created(new_dialogue_ast: DialogueAst) -> void:
	dialogue_ast = new_dialogue_ast
	ParleySettings.set_user_value(ParleyConstants.EDITOR_CURRENT_DIALOGUE_SEQUENCE_PATH, dialogue_ast.resource_path)
	refresh(true)


func _on_insert_id_pressed(type: DialogueAst.Type) -> void:
	var ast_node = dialogue_ast.add_new_node(type, (graph_view.scroll_offset + graph_view.size * 0.5) / graph_view.zoom)
	if ast_node:
		await refresh()


func _on_save_pressed() -> void:
	_save_dialogue()
	# This is needed to reset the Graph and ensure
	# that no weirdness is going to happen. For example
	# move the group nodes after a save when refresh isn't present
	await refresh()


func _save_dialogue() -> void:
	ResourceSaver.save(dialogue_ast)
	# This is needed to correctly reload upon file saves
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().reimport_files([dialogue_ast.resource_path])

func _on_arrange_nodes_button_pressed() -> void:
	selected_node_id = null
	_clear_editor()
	await refresh()


func _on_refresh_button_pressed() -> void:
	await refresh()


func _on_test_dialogue_from_start_button_pressed() -> void:
	# TODO: dialogue is technically async so we should ideally wait here
	_save_dialogue()
	if plugin:
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST, true)
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH, dialogue_ast.resource_path)
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START, true)
		var test_dialogue_path: String = ParleySettings.get_setting(ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH)
		plugin.get_editor_interface().play_custom_scene(test_dialogue_path)

func _on_test_dialogue_from_selected_button_pressed() -> void:
	# TODO: dialogue is technically async so we should ideally wait here
	_save_dialogue()
	if plugin:
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_IS_RUNNING_DIALOGUE_TEST, true)
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_DIALOGUE_AST_RESOURCE_PATH, dialogue_ast.resource_path)
		ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START, null)
		if selected_node_id:
			ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_START_NODE_ID, selected_node_id)
		else:
			ParleySettings.set_user_value(ParleyConstants.TEST_DIALOGUE_SEQUENCE_FROM_START, true)
		var test_dialogue_path: String = ParleySettings.get_setting(ParleyConstants.TEST_DIALOGUE_SEQUENCE_TEST_SCENE_PATH)
		plugin.get_editor_interface().play_custom_scene(test_dialogue_path)
#endregion


#region SIGNALS
func _on_dialogue_node_editor_dialogue_node_changed(id: String, new_character: String, new_dialogue_text: String) -> void:
	var ast_node = dialogue_ast.find_node_by_id(id)
	var selected_node = graph_view.find_node_by_id(id)
	if not ast_node or not _is_selected_node(DialogueNode, selected_node, id):
		return
	if ast_node is DialogueNodeAst:
		ast_node.update(new_character, new_dialogue_text)
	if selected_node is DialogueNode:
		selected_node.character = new_character
		selected_node.dialogue = new_dialogue_text


func _on_dialogue_option_node_editor_dialogue_option_node_changed(id, new_character, new_option_text) -> void:
	var ast_node = dialogue_ast.find_node_by_id(id)
	var selected_node = graph_view.find_node_by_id(id)
	if not ast_node or not _is_selected_node(DialogueOptionNode, selected_node, id):
		return
	ast_node.update(new_character, new_option_text)
	selected_node.update(new_character, new_option_text)


func _on_condition_node_editor_condition_node_changed(id, description, condition, conditions) -> void:
	var ast_node = dialogue_ast.find_node_by_id(id)
	var selected_node = graph_view.find_node_by_id(id)
	if not ast_node or not _is_selected_node(ConditionNode, selected_node, id):
		return
	var ast_conditions: Array = []
	for condition_def in conditions:
		var fact_name = condition_def['fact_name']
		var fact = ParleyManager.fact_store.get_fact_by_name(fact_name)
		if fact.id == -1:
			printerr("PARLEY_ERR: Unable to find Fact with name %s in the store" % [fact_name])
			return
		ast_conditions.append({
			'fact_ref': fact.ref.resource_path,
			'operator': condition_def['operator'],
			'value': condition_def['value'],
		})
	ast_node.update(description, condition, ast_conditions)
	selected_node.update(description)


func _on_match_node_editor_match_node_changed(id: String, description: String, fact_name: String, cases: Array[Variant]) -> void:
	var _ast_node: NodeAst = dialogue_ast.find_node_by_id(id)
	var _selected_node: ParleyGraphNode = graph_view.find_node_by_id(id)
	if _ast_node is not MatchNodeAst or not _is_selected_node(MatchNode, _selected_node, id):
		return
	var ast_node: MatchNodeAst = _ast_node
	var selected_node: MatchNode = _selected_node
	var fact: Fact = ParleyManager.fact_store.get_fact_by_name(fact_name)
	if fact.id == -1:
		printerr("PARLEY_ERR: Unable to find Fact with name %s in the store" % [fact_name])
		return
	# Handle any necessary edge changes
	var edges_to_delete: Array[EdgeAst] = []
	var edges_to_create: Array[EdgeAst] = []
	if cases.hash() != ast_node.cases.hash():
		# Calculate edges to delete
		var relevant_edges: Array[EdgeAst] = dialogue_ast.edges.filter(func(edge: EdgeAst) -> bool: return edge.from_node == id)
		for edge: EdgeAst in relevant_edges:
			var slot: int = edge.from_slot
			if slot >= cases.size() or cases[slot] != ast_node.cases[slot]:
				edges_to_delete.append(edge)
		# Calculate edges to create
		for edge: EdgeAst in relevant_edges:
			var slot: int = edge.from_slot
			if slot < ast_node.cases.size() and cases.has(ast_node.cases[slot]):
				var current_case: Variant = ast_node.cases[slot]
				var case_index: int = cases.find(current_case)
				if case_index != -1:
					var new_edge: EdgeAst = EdgeAst.new(edge.from_node, case_index, edge.to_node, edge.to_slot)
					edges_to_create.append(new_edge)

	if ast_node is MatchNodeAst:
		ast_node.description = description
		ast_node.fact_ref = fact.ref.resource_path
		ast_node.cases = cases.duplicate()
	if selected_node is MatchNode:
		selected_node.description = description
		selected_node.fact_name = fact_name
		for edge: EdgeAst in edges_to_delete:
			_remove_edge(edge.from_node, edge.from_slot, edge.to_node, edge.to_slot)
		selected_node.cases = cases.duplicate()
		for edge: EdgeAst in edges_to_create:
			var from_node_name: StringName = graph_view.get_ast_node_name(ast_node)
			var to_node_name: StringName = graph_view.get_ast_node_name(dialogue_ast.find_node_by_id(edge.to_node))
			_add_edge(from_node_name, edge.from_slot, to_node_name, edge.to_slot)


func _on_action_node_editor_action_node_changed(id: String, description: String, action_type: ActionNodeAst.ActionType, action_script_name: String, values: Array) -> void:
	var ast_node = dialogue_ast.find_node_by_id(id)
	var selected_node = graph_view.find_node_by_id(id)
	if ast_node is not ActionNodeAst or not _is_selected_node(ActionNode, selected_node, id):
		return
	var action = ParleyManager.action_store.get_action_by_name(action_script_name)
	if action.id == -1:
		printerr("PARLEY_ERR: Unable to find Action with script name %s in the store" % [action_script_name])
		return
	if ast_node is ActionNodeAst:
		ast_node.update(description, action_type, action.ref.resource_path, values)
	if selected_node is ActionNode:
		selected_node.description = description
		selected_node.action_type = action_type
		selected_node.action_script_name = action.name
		selected_node.values = values


func _on_group_node_editor_group_node_changed(id: String, group_name: String, colour: Color) -> void:
	var ast_node = dialogue_ast.find_node_by_id(id)
	var selected_node = graph_view.find_node_by_id(id)
	if ast_node is not GroupNodeAst or not _is_selected_node(GroupNode, selected_node, id):
		return
	if ast_node is GroupNodeAst:
		ast_node.name = group_name
		ast_node.colour = colour
	if selected_node is GroupNode:
		selected_node.group_name = group_name
		selected_node.colour = colour


func _on_graph_view_connection_request(from_node_name: StringName, from_slot: int, to_node_name: StringName, to_slot: int) -> void:
	_add_edge(from_node_name, from_slot, to_node_name, to_slot)


func _on_graph_view_disconnection_request(from_node: StringName, from_slot: int, to_node: StringName, to_slot: int) -> void:
	var from_node_id: String = from_node.split('-')[1]
	var to_node_id: String = to_node.split('-')[1]
	_remove_edge(from_node_id, from_slot, to_node_id, to_slot)
	if selected_node_id == from_node_id or selected_node_id == to_node_id:
		edges_editor.set_edges(dialogue_ast.edges, selected_node_id)


func _on_edges_editor_edge_deleted(edge: EdgeAst) -> void:
	_remove_edge(edge.from_node, edge.from_slot, edge.to_node, edge.to_slot)


func _on_edges_editor_mouse_entered_edge(edge: EdgeAst) -> void:
	var nodes: Array[ParleyGraphNode] = graph_view.get_nodes_for_edge(edge)
	for node in nodes:
		if node.id == edge.from_node:
			node.select_from_slot(edge.from_slot)
		if node.id == edge.to_node:
			node.select_to_slot(edge.to_slot)


func _on_edges_editor_mouse_exited_edge(edge: EdgeAst) -> void:
	var nodes: Array[ParleyGraphNode] = graph_view.get_nodes_for_edge(edge)
	for node in nodes:
		if node.id == edge.from_node:
			node.unselect_from_slot(edge.from_slot)
		if node.id == edge.to_node:
			node.unselect_to_slot(edge.to_slot)


func _on_delete_node_button_pressed() -> void:
	if not selected_node_id:
		print("PARLEY_DBG: No node is selected, not deleting anything")
		return
	var selected_node = graph_view.find_node_by_id(selected_node_id)
	graph_view.remove_child(selected_node)
	dialogue_ast.remove_node(selected_node_id)
	_clear_editor()
	selected_node_id = null


func _on_sidebar_node_selected(node: NodeAst) -> void:
	graph_view.set_selected_by_id(node.id)


func _on_sidebar_dialogue_ast_selected(selected_dialogue_ast: DialogueAst) -> void:
	if dialogue_ast.resource_path != selected_dialogue_ast.resource_path:
		dialogue_ast = selected_dialogue_ast
		await refresh()


func _on_bottom_panel_sidebar_toggled(is_sidebar_open: bool) -> void:
	if sidebar:
		if is_sidebar_open:
			sidebar.show()
		else:
			sidebar.hide()
#endregion


#region HELPERS
func _remove_edge(from_node: String, from_slot: int, to_node: String, to_slot: int) -> void:
	dialogue_ast.remove_edge(from_node, from_slot, to_node, to_slot)
	graph_view.ast = dialogue_ast
	graph_view.generate_edges()

func _add_edge(from_node_name: StringName, from_slot: int, to_node_name: StringName, to_slot: int) -> void:
	var from_node_id: String = from_node_name.split('-')[1]
	var to_node_id: String = to_node_name.split('-')[1]
	dialogue_ast.add_new_edge(from_node_id, from_slot, to_node_id, to_slot)
	graph_view.connect_node(from_node_name, from_slot, to_node_name, to_slot)
	if selected_node_id and (selected_node_id == from_node_id or selected_node_id == to_node_id):
		edges_editor.set_edges(dialogue_ast.edges, selected_node_id)

func _is_selected_node(type: Object, selected_node: Variant, id: String) -> bool:
	var is_selected_node: bool = selected_node and is_instance_of(selected_node, type) and selected_node_id == id
	if not is_selected_node:
		print("PARLEY_DBG: Selected node {selected_node} is not a valid node for ID: {id}".format({'selected_node': selected_node, 'id': id}))
	return is_selected_node


func _clear_editor() -> void:
	# TODO: set a selected node editor to simplify this
	editor_controls_container.hide()
	dialogue_node_editor.hide()
	dialogue_option_node_editor.hide()
	condition_node_editor.hide()
	match_node_editor.hide()
	action_node_editor.hide()
	start_node_editor.hide()
	end_node_editor.hide()
	group_node_editor.hide()
	edges_editor.clear()
	edges_editor.hide()
#endregion
