@tool
class_name ParleyMainPanel extends VBoxContainer


const new_file_icon: CompressedTexture2D = preload("./assets/New.svg")
const load_file_icon: CompressedTexture2D = preload("./assets/Load.svg")
const export_to_csv_icon: CompressedTexture2D = preload("./assets/Export.svg")
const insert_after_icon: CompressedTexture2D = preload("./assets/InsertAfter.svg")
const dialogue_icon: CompressedTexture2D = preload("./assets/Dialogue.svg")
const dialogue_option_icon: CompressedTexture2D = preload("./assets/DialogueOption.svg")
const condition_icon: CompressedTexture2D = preload("./assets/Condition.svg")
const action_icon: CompressedTexture2D = preload("./assets/Action.svg")
const start_node_icon: CompressedTexture2D = preload("./assets/Start.svg")
const end_node_icon: CompressedTexture2D = preload("./assets/End.svg")
const group_node_icon: CompressedTexture2D = preload("./assets/Group.svg")


@export var dialogue_ast: DialogueAst = DialogueAst.new(): set = _set_dialogue_ast
@export var action_store: ActionStore = ActionStore.new(): set = _set_action_store


# TODO: check all uses of globals and ensure that these are used minimally
# Ideally we only want to be referencing ParleyManager
# Although... does this even need to be a global if everything is now defined in the DS AST?
# TODO: use unique name (%)
@onready var graph_view: ParleyGraphView = %GraphView
@export var save_button: Button
@export var arrange_nodes_button: Button
@export var refresh_button: Button
@export var open_file_dialogue: FileDialog


@onready var file_menu: MenuButton = %FileMenu
@onready var insert_menu: MenuButton = %InsertMenu
@onready var new_dialogue_modal: Window = %NewDialogueModal
@onready var export_to_csv_modal: ParleyExportToCsvModal = %ExportToCsvModal
@onready var editor: HSplitContainer = %EditorView
@onready var sidebar: ParleySidebar = %Sidebar
@onready var bottom_panel: MarginContainer = %BottomPanel


# TODO: remove this
var selected_node_id: Variant
var selected_node_ast: NodeAst: set = _set_selected_node_ast


signal dialogue_ast_selected(dialogue_ast: DialogueAst)
signal node_selected(node_ast: NodeAst)


#region SETUP
func _ready() -> void:
	_setup()


func refresh(arrange: bool = false) -> void:
	if graph_view:
		graph_view.ast = dialogue_ast
		graph_view.action_store = action_store
		await graph_view.generate(arrange)
	if selected_node_id and is_instance_of(selected_node_id, TYPE_STRING):
		var id: String = selected_node_id
		var selected_node: Variant = graph_view.find_node_by_id(id)
		if selected_node and selected_node is Node:
			var node: Node = selected_node
			graph_view.set_selected(node)

func _exit_tree() -> void:
	if dialogue_ast and dialogue_ast.dialogue_updated.is_connected(_on_dialogue_ast_changed):
		ParleyUtils.signals.safe_disconnect(dialogue_ast.dialogue_updated, _on_dialogue_ast_changed)
	dialogue_ast = null


# TODO: move into a more formalised cache that is persistent across reloads
# TODO: do by resource ID
var dialogue_view_cache: Dictionary[DialogueAst, Dictionary] = {}


func _set_dialogue_ast(new_dialogue_ast: DialogueAst) -> void:
	# TODO: regenerate
	if dialogue_ast != new_dialogue_ast:
		dialogue_ast = new_dialogue_ast
		if dialogue_ast:
			if not dialogue_view_cache.has(dialogue_ast):
				var _result: bool = dialogue_view_cache.set(dialogue_ast, {'scroll_offset': Vector2.ZERO})
			var cache: Dictionary = dialogue_view_cache.get(dialogue_ast, {})
			var scroll_offset: Vector2 = cache.get('scroll_offset', Vector2.ZERO)
			if dialogue_ast.dialogue_updated.is_connected(_on_dialogue_ast_changed):
				dialogue_ast.dialogue_updated.disconnect(_on_dialogue_ast_changed)
			ParleyUtils.signals.safe_connect(dialogue_ast.dialogue_updated, _on_dialogue_ast_changed)
			if sidebar:
				sidebar.add_dialogue_ast(dialogue_ast)
			dialogue_ast_selected.emit(dialogue_ast)
			await refresh()
			if graph_view:
				# Seems like we have to do this twice to get it to correctly render
				# TODO: investigate further
				graph_view.scroll_offset = scroll_offset
				graph_view.scroll_offset = scroll_offset


func _set_action_store(new_action_store: ActionStore) -> void:
	if action_store != new_action_store:
		if new_action_store:
			ParleyUtils.signals.safe_disconnect(action_store.changed, _on_action_store_changed)
		action_store = new_action_store
		if action_store:
			ParleyUtils.signals.safe_connect(action_store.changed, _on_action_store_changed)
	if graph_view:
		graph_view.action_store = action_store


func _set_selected_node_ast(new_selected_node_ast: NodeAst) -> void:
	selected_node_ast = new_selected_node_ast
	if not _is_selected_node(new_selected_node_ast.id):
		return
	_set_node_ast(selected_node_ast)


func _set_node_ast(new_node_ast: NodeAst) -> void:
	match new_node_ast.type:
		DialogueAst.Type.DIALOGUE:
			var dialogue_node_ast: DialogueNodeAst = new_node_ast
			_on_dialogue_node_editor_dialogue_node_changed(dialogue_node_ast.id, dialogue_node_ast.character, dialogue_node_ast.text)
		DialogueAst.Type.DIALOGUE_OPTION:
			var dialogue_option_node_ast: DialogueOptionNodeAst = new_node_ast
			_on_dialogue_option_node_editor_dialogue_option_node_changed(dialogue_option_node_ast.id, dialogue_option_node_ast.character, dialogue_option_node_ast.text)
		DialogueAst.Type.CONDITION:
			var condition_node_ast: ConditionNodeAst = new_node_ast
			_on_condition_node_editor_condition_node_changed(condition_node_ast.id, condition_node_ast.description, condition_node_ast.combiner, condition_node_ast.conditions)
		DialogueAst.Type.MATCH:
			var match_node_ast: MatchNodeAst = new_node_ast
			# TODO: can we get rid of this global ref?
			var fact_name: String = ParleyManager.get_instance().fact_store.get_fact_by_ref(match_node_ast.fact_ref).name
			_on_match_node_editor_match_node_changed(match_node_ast.id, match_node_ast.description, fact_name, match_node_ast.cases)
		DialogueAst.Type.ACTION:
			var action_node_ast: ActionNodeAst = new_node_ast
			_on_action_node_editor_action_node_changed(action_node_ast.id, action_node_ast.description, action_node_ast.action_type, action_node_ast.action_script_ref, action_node_ast.values)
		DialogueAst.Type.GROUP:
			var group_node_ast: GroupNodeAst = new_node_ast
			_on_group_node_editor_group_node_changed(group_node_ast.id, group_node_ast.name, group_node_ast.colour)
		_:
			ParleyUtils.log.error("Unsupported Node type: %s for Node with ID: %s" % [DialogueAst.get_type_name(selected_node_ast.type), selected_node_ast.id])
			return


# TODO: move to the correct region in this file
func _on_dialogue_ast_changed(new_dialogue_ast: DialogueAst) -> void:
	if sidebar:
		sidebar.current_dialogue_ast = new_dialogue_ast
#endregion

#region SETUP
func _setup() -> void:
	_setup_file_menu()
	_setup_insert_menu()
	_setup_theme()

func _setup_theme() -> void:
	# TODO: we might need to register this dynamically at a later date
	# it seems that it only does this at the project level atm.
	save_button.tooltip_text = "Save the current dialogue sequence."
	arrange_nodes_button.tooltip_text = "Arrange the current dialogue sequence nodes."
	refresh_button.tooltip_text = "Refresh the current dialogue sequence."


## Set up the file menu
func _setup_file_menu() -> void:
	var popup: PopupMenu = file_menu.get_popup()
	popup.clear()
	popup.add_icon_item(new_file_icon, "New Dialogue Sequence...", 0)
	popup.add_icon_item(load_file_icon, "Open Dialogue Sequence...", 1)
	popup.add_separator("Export")
	popup.add_icon_item(export_to_csv_icon, "Export to CSV...", 2)
	ParleyUtils.signals.safe_connect(popup.id_pressed, _on_file_id_pressed)


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
	ParleyUtils.signals.safe_connect(popup.id_pressed, _on_insert_id_pressed)
#endregion


#region ACTIONS
func _on_file_id_pressed(id: int) -> void:
	match id:
		0:
			new_dialogue_modal.show()
		1:
			open_file_dialogue.show()
			# TODO: get this from config (note, see the Node inspector as well)
			open_file_dialogue.current_dir = "res://dialogue_sequences"
		2:
			export_to_csv_modal.dialogue_ast = dialogue_ast
			export_to_csv_modal.render()
		_:
			ParleyUtils.log.info("Unknown option ID pressed: {id}".format({'id': id}))


func _on_graph_view_node_selected(node: ParleyGraphNode) -> void:
	# TODO: can we get rid of this global ref?
	if not ParleyManager.get_instance().is_test_dialogue_sequence_running():
		# TODO: can we get rid of this global ref?
		ParleyManager.get_instance().set_test_dialogue_sequence_start_node(node.id)
	if selected_node_id == node.id:
		return
	var node_ast: NodeAst = dialogue_ast.find_node_by_id(node.id)
	node_selected.emit(node_ast)
	selected_node_id = node.id


func _on_graph_view_node_deselected(_node: Node) -> void:
	# TODO: can we get rid of this global ref?
	if not ParleyManager.get_instance().is_test_dialogue_sequence_running():
		# TODO: can we get rid of this global ref?
		ParleyManager.get_instance().set_test_dialogue_sequence_start_node(null)
#endregion


#region BUTTONS
func _on_open_dialog_file_selected(path: String) -> void:
	dialogue_ast = load(path)
	# TODO: can we get rid of this global ref?
	# TODO: emit as a signal and handle in the plugin
	ParleyManager.get_instance().set_current_dialogue_sequence(path)


func _on_new_dialogue_modal_dialogue_ast_created(new_dialogue_ast: DialogueAst) -> void:
	dialogue_ast = new_dialogue_ast
	# TODO: can we get rid of this global ref?
	# TODO: emit as a signal and handle in the plugin
	ParleyManager.get_instance().set_current_dialogue_sequence(dialogue_ast.resource_path)
	refresh(true)


func _on_insert_id_pressed(type: DialogueAst.Type) -> void:
	var ast_node: Variant = dialogue_ast.add_new_node(type, (graph_view.scroll_offset + graph_view.size * 0.5) / graph_view.zoom)
	if ast_node:
		await refresh()


func _on_save_pressed() -> void:
	_save_dialogue()
	# This is needed to reset the Graph and ensure
	# that no weirdness is going to happen. For example
	# move the group nodes after a save when refresh isn't present
	await refresh()


func _save_dialogue() -> void:
	var ok: int = ResourceSaver.save(dialogue_ast)
	if ok != OK:
		ParleyUtils.log.warn("Error saving the Dialogue AST: %d" % [ok])
		return
	# This is needed to correctly reload upon file saves
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().reimport_files([dialogue_ast.resource_path])

func _on_arrange_nodes_button_pressed() -> void:
	selected_node_id = null
	await refresh()


func _on_refresh_button_pressed() -> void:
	await refresh()


func _on_test_dialogue_from_start_button_pressed() -> void:
	# TODO: dialogue is technically async so we should ideally wait here
	_save_dialogue()
	# TODO: can we get rid of this global ref?
	ParleyManager.get_instance().run_test_dialogue_from_start(dialogue_ast)

func _on_test_dialogue_from_selected_button_pressed() -> void:
	# TODO: dialogue is technically async so we should ideally wait here
	_save_dialogue()
	# TODO: can we get rid of this global ref?
	ParleyManager.get_instance().run_test_dialogue_from_selected(dialogue_ast, selected_node_id)
#endregion


#region SIGNALS
func _on_action_store_changed() -> void:
	if action_store:
		var nodes: Array[NodeAst] = dialogue_ast.find_nodes_by_type(DialogueAst.Type.ACTION)
		for node_ast: ActionNodeAst in nodes:
			_set_node_ast(node_ast)
		

func _on_node_editor_node_changed(new_node_ast: NodeAst) -> void:
	selected_node_ast = new_node_ast


func _on_graph_view_scroll_offset_changed(offset: Vector2) -> void:
	if dialogue_ast:
		if dialogue_view_cache.has(dialogue_ast):
			var cache: Dictionary = dialogue_view_cache.get(dialogue_ast)
			var _result: bool = cache.set('scroll_offset', offset)


# TODO: remove ast stuff
func _on_dialogue_node_editor_dialogue_node_changed(id: String, new_character: String, new_dialogue_text: String) -> void:
	var _ast_node: NodeAst = dialogue_ast.find_node_by_id(id)
	var _selected_node: ParleyGraphNode = graph_view.find_node_by_id(id)
	if not _ast_node or not _selected_node:
		return
	if _ast_node is DialogueNodeAst:
		var ast_node: DialogueNodeAst = _ast_node
		ast_node.update(new_character, new_dialogue_text)
	if _selected_node is DialogueNode:
		var selected_node: DialogueNode = _selected_node
		selected_node.character = new_character
		selected_node.dialogue = new_dialogue_text


# TODO: remove ast stuff
func _on_dialogue_option_node_editor_dialogue_option_node_changed(id: String, new_character: String, new_option_text: String) -> void:
	var _ast_node: NodeAst = dialogue_ast.find_node_by_id(id)
	var _selected_node: ParleyGraphNode = graph_view.find_node_by_id(id)
	if not _ast_node or not _selected_node:
		return
	if _ast_node is DialogueOptionNodeAst:
		var ast_node: DialogueOptionNodeAst = _ast_node
		ast_node.update(new_character, new_option_text)
	if _selected_node is DialogueOptionNode:
		var selected_node: DialogueOptionNode = _selected_node
		selected_node.character = new_character
		selected_node.option = new_option_text


# TODO: remove ast stuff
func _on_condition_node_editor_condition_node_changed(id: String, description: String, combiner: ConditionNodeAst.Combiner, conditions: Array) -> void:
	var _ast_node: NodeAst = dialogue_ast.find_node_by_id(id)
	var _selected_node: ParleyGraphNode = graph_view.find_node_by_id(id)
	if not _ast_node or not _selected_node:
		return
	if _ast_node is ConditionNodeAst:
		var ast_node: ConditionNodeAst = _ast_node
		ast_node.update(description, combiner, conditions.duplicate(true))
	if _selected_node is ConditionNode:
		var selected_node: ConditionNode = _selected_node
		selected_node.update(description)

# TODO: remove ast stuff
func _on_match_node_editor_match_node_changed(id: String, description: String, fact_name: String, cases: Array[Variant]) -> void:
	var _ast_node: NodeAst = dialogue_ast.find_node_by_id(id)
	var _selected_node: ParleyGraphNode = graph_view.find_node_by_id(id)
	if _ast_node is not MatchNodeAst or not _selected_node:
		return
	var ast_node: MatchNodeAst = _ast_node
	var selected_node: MatchNode = _selected_node
	# TODO: can we get rid of this global ref?
	var fact: Fact = ParleyManager.get_instance().fact_store.get_fact_by_name(fact_name)
	
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
		if fact.id != "":
			ast_node.fact_ref = fact.ref.resource_path
		ast_node.cases = cases.duplicate()
	if selected_node is MatchNode:
		selected_node.description = description
		selected_node.fact_name = fact_name
		var changed: int = 0
		changed += dialogue_ast.remove_edges(edges_to_delete, false)
		selected_node.cases = cases.duplicate()
		changed += dialogue_ast.add_edges(edges_to_create, edges_to_delete.size() + edges_to_create.size() > 0)
		if changed > 0:
			graph_view.ast = dialogue_ast
			graph_view.generate_edges()

# TODO: remove ast stuff
# TODO: change this to ref
func _on_action_node_editor_action_node_changed(id: String, description: String, action_type: ActionNodeAst.ActionType, action_script_ref: String, values: Array) -> void:
	var ast_node: NodeAst = dialogue_ast.find_node_by_id(id)
	var parley_graph_node: Variant = graph_view.find_node_by_id(id)
	if ast_node is not ActionNodeAst or not parley_graph_node:
		return
	var action: Action = action_store.get_action_by_ref(action_script_ref)
	if ast_node is ActionNodeAst:
		var action_node_ast: ActionNodeAst = ast_node
		var uid: String = ""
		if action.id != "":
			uid = ParleyUtils.resource.get_uid(action.ref)
		action_node_ast.update(description, action_type, uid, values)
	if parley_graph_node is ActionNode:
		parley_graph_node.description = description
		parley_graph_node.action_type = action_type
		parley_graph_node.action_script_name = action.name
		parley_graph_node.values = values


func _on_group_node_editor_group_node_changed(id: String, group_name: String, colour: Color) -> void:
	var ast_node: NodeAst = dialogue_ast.find_node_by_id(id)
	var selected_node: Variant = graph_view.find_node_by_id(id)
	if ast_node is not GroupNodeAst or not selected_node:
		return
	if ast_node is GroupNodeAst:
		var group_node: GroupNodeAst = ast_node
		group_node.name = group_name
		group_node.colour = colour
	if selected_node is GroupNode:
		selected_node.group_name = group_name
		selected_node.colour = colour


# TODO: add to docs
func _on_graph_view_connection_request(from_node_name: StringName, from_slot: int, to_node_name: StringName, to_slot: int) -> void:
	_add_edge(from_node_name, from_slot, to_node_name, to_slot)


# TODO: add to docs
func _on_graph_view_connection_to_empty(from_node_name: StringName, from_slot: int, release_position: Vector2) -> void:
	# TODO: it may be better to create a helper for this calculation
	var ast_node_variant: Variant = dialogue_ast.add_new_node(DialogueAst.Type.DIALOGUE, ((graph_view.scroll_offset + release_position) / graph_view.zoom) + Vector2(0, -90))
	if ast_node_variant and ast_node_variant is NodeAst:
		var ast_node: NodeAst = ast_node_variant
		await refresh()
		var to_node_name: String = graph_view.get_ast_node_name(ast_node)
		# TODO: This is the entry slot for a Dialogue AST Node, it may be better to create a helper function for this
		var to_slot: int = 0
		_add_edge(from_node_name, from_slot, to_node_name, to_slot)


# TODO: add to docs
func _on_graph_view_disconnection_request(from_node: StringName, from_slot: int, to_node: StringName, to_slot: int) -> void:
	var from_node_id: String = from_node.split('-')[1]
	var to_node_id: String = to_node.split('-')[1]
	remove_edge(from_node_id, from_slot, to_node_id, to_slot)


# TODO: add to docs
func focus_edge(edge: EdgeAst) -> void:
	var nodes: Array[ParleyGraphNode] = graph_view.get_nodes_for_edge(edge)
	for node: ParleyGraphNode in nodes:
		if node.id == edge.from_node:
			node.select_from_slot(edge.from_slot)
		if node.id == edge.to_node:
			node.select_to_slot(edge.to_slot)


func defocus_edge(edge: EdgeAst) -> void:
	var nodes: Array[ParleyGraphNode] = graph_view.get_nodes_for_edge(edge)
	for node: ParleyGraphNode in nodes:
		if node.id == edge.from_node:
			node.unselect_from_slot(edge.from_slot)
		if node.id == edge.to_node:
			node.unselect_to_slot(edge.to_slot)


# TODO: add to docs
func delete_node_by_id(id: String) -> void:
	if not selected_node_id or not is_instance_of(selected_node_id, TYPE_STRING):
		ParleyUtils.log.info("No node is selected, not deleting anything")
		return
	if id != selected_node_id:
		ParleyUtils.log.info("Node ID to delete does not match the selected Node ID, not deleting anything")
		return
		
	var valid_selected_node_id: String = selected_node_id
	var selected_node_variant: Variant = graph_view.find_node_by_id(valid_selected_node_id)
	if selected_node_variant is Node:
		var selected_node: Node = selected_node_variant
		graph_view.remove_child(selected_node)
	dialogue_ast.remove_node(valid_selected_node_id)
	selected_node_id = null


func _on_sidebar_node_selected(node: NodeAst) -> void:
	graph_view.set_selected_by_id(node.id)


func _on_sidebar_dialogue_ast_selected(selected_dialogue_ast: DialogueAst) -> void:
	if ParleyUtils.resource.get_uid(dialogue_ast) != ParleyUtils.resource.get_uid(selected_dialogue_ast):
		dialogue_ast = selected_dialogue_ast


func _on_bottom_panel_sidebar_toggled(is_sidebar_open: bool) -> void:
	if sidebar:
		if is_sidebar_open:
			sidebar.show()
		else:
			sidebar.hide()
#endregion


#region HELPERS
func remove_edge(from_node: String, from_slot: int, to_node: String, to_slot: int) -> void:
	# TODO: handle _result
	var _result: int = dialogue_ast.remove_edge(from_node, from_slot, to_node, to_slot)
	graph_view.ast = dialogue_ast
	graph_view.generate_edges()

func _add_edge(from_node_name: StringName, from_slot: int, to_node_name: StringName, to_slot: int) -> void:
	var from_node_id: String = from_node_name.split('-')[1]
	var to_node_id: String = to_node_name.split('-')[1]
	var _added: int = dialogue_ast.add_edge(from_node_id, from_slot, to_node_id, to_slot)
	var _connected: int = graph_view.connect_node(from_node_name, from_slot, to_node_name, to_slot)

func _is_selected_node(id: String) -> bool:
	var is_selected_node: bool = selected_node_id == id
	if not is_selected_node:
		ParleyUtils.log.warn("Node with ID %s is not selected" % id)
	return is_selected_node
#endregion
