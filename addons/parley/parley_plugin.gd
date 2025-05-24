@tool
extends EditorPlugin


#region DEFS
const ParleyConstants = preload("./constants.gd")
const ParleyImportPlugin: GDScript = preload("./import_plugin.gd")
const StoresEditorScene: PackedScene = preload("./stores/stores_editor.tscn")
const ParleyNodeScene: PackedScene = preload("./views/parley_node.tscn")
const ParleyEdges: PackedScene = preload("./views/parley_edges.tscn")
const MainPanelScene: PackedScene = preload("./main_panel.tscn")


const PARLEY_RUNTIME_AUTOLOAD: String = "Parley"
const PARLEY_MANAGER_SINGLETON: String = "ParleyManager"
const PARLEY_RUNTIME_SINGLETON: String = "ParleyRuntime"


var main_panel_instance: ParleyMainPanel
var import_plugin: EditorImportPlugin
var stores_editor: ParleyStoresEditor
var node_editor: ParleyNodeEditor
var edges_editor: ParleyEdgesEditor


enum Component {
  MainPanel,
  StoresEditor
}
#endregion


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		Engine.set_meta(ParleyConstants.PARLEY_PLUGIN_METADATA, self)

		# Import plugin setup
		import_plugin = ParleyImportPlugin.new()
		add_import_plugin(import_plugin)
		
		# Stores Editor Dock
		stores_editor = StoresEditorScene.instantiate()
		ParleyUtils.signals.safe_connect(stores_editor.dialogue_sequence_ast_changed, _on_dialogue_sequence_ast_changed.bind(Component.StoresEditor))
		ParleyUtils.signals.safe_connect(stores_editor.dialogue_sequence_ast_selected, _on_dialogue_sequence_ast_selected.bind(Component.StoresEditor))
		add_control_to_dock(DockSlot.DOCK_SLOT_LEFT_UR, stores_editor)

		# Node Editor Dock
		node_editor = ParleyNodeScene.instantiate()
		ParleyUtils.signals.safe_connect(node_editor.node_changed, _on_node_editor_node_changed)
		ParleyUtils.signals.safe_connect(node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
		add_control_to_dock(DockSlot.DOCK_SLOT_RIGHT_UL, node_editor)

		# Edges Editor Dock
		edges_editor = ParleyEdges.instantiate()
		ParleyUtils.signals.safe_connect(edges_editor.edge_deleted, _on_edges_editor_edge_deleted)
		ParleyUtils.signals.safe_connect(edges_editor.mouse_entered_edge, _on_edges_editor_mouse_entered_edge)
		ParleyUtils.signals.safe_connect(edges_editor.mouse_exited_edge, _on_edges_editor_mouse_exited_edge)
		add_control_to_dock(DockSlot.DOCK_SLOT_RIGHT_BL, edges_editor)

		# Main Panel
		main_panel_instance = MainPanelScene.instantiate()
		ParleyUtils.signals.safe_connect(main_panel_instance.node_selected, _on_main_panel_node_selected)
		ParleyUtils.signals.safe_connect(main_panel_instance.dialogue_ast_selected, _on_main_panel_dialogue_sequence_ast_selected)
		if main_panel_instance.dialogue_ast:
			_on_dialogue_sequence_ast_changed(main_panel_instance.dialogue_ast, Component.MainPanel)
		EditorInterface.get_editor_main_screen().add_child(main_panel_instance)

		# Setup of data must be performed before setting the dialogue_ast because
		# of the refresh that happens in the dialogue_ast setter. This causes
		# the dialogue to be rendered before the stores are correctly set so
		# it is vital to setup these first.
		# TODO: it may be better to not refresh automatically upon a dialogue ast change
		# or defer the refresh so it happens after all the other setters are made.
		_setup_data()
		main_panel_instance.dialogue_ast = ParleyManager.get_instance().load_current_dialogue_sequence()

		# Hide the main panel. Very much required.
		_make_visible(false)

#region SETTERS
func _set_edges() -> void:
	if node_editor and edges_editor and node_editor.dialogue_sequence_ast and node_editor.node_ast:
		var node_ast: NodeAst = node_editor.node_ast
		var dialogue_sequence_ast: DialogueAst = node_editor.dialogue_sequence_ast
		var edges: Array[EdgeAst] = dialogue_sequence_ast.edges
		edges_editor.set_edges(edges, node_ast.id)


func _setup_data() -> void:
	var parley_manager: ParleyManager = ParleyManager.get_instance()

	if stores_editor:
		stores_editor.action_store = parley_manager.action_store

	if node_editor:
		node_editor.action_store = parley_manager.action_store

	if main_panel_instance:
		main_panel_instance.action_store = parley_manager.action_store
#endregion


#region SIGNALS
func _on_dialogue_sequence_ast_changed(new_dialogue_sequence_ast: DialogueAst, component: Component) -> void:
	if component != Component.MainPanel:
		main_panel_instance.dialogue_ast = new_dialogue_sequence_ast
	if component != Component.StoresEditor:
		stores_editor.dialogue_ast = new_dialogue_sequence_ast


func _on_dialogue_sequence_ast_selected(selected_dialogue_sequence_ast: DialogueAst, component: Component) -> void:
	if component != Component.MainPanel:
		main_panel_instance.dialogue_ast = selected_dialogue_sequence_ast
		EditorInterface.set_main_screen_editor(ParleyConstants.PLUGIN_NAME)
	if component != Component.StoresEditor:
		stores_editor.dialogue_ast = selected_dialogue_sequence_ast


func _on_node_editor_node_changed(node_ast: NodeAst) -> void:
	if main_panel_instance:
		main_panel_instance.selected_node_ast = node_ast


func _on_delete_node_button_pressed(id: String) -> void:
	if main_panel_instance:
		main_panel_instance.delete_node_by_id(id)


func _on_edges_editor_mouse_entered_edge(edge: EdgeAst) -> void:
	if main_panel_instance:
		main_panel_instance.focus_edge(edge)


func _on_edges_editor_mouse_exited_edge(edge: EdgeAst) -> void:
	if main_panel_instance:
		main_panel_instance.defocus_edge(edge)


func _on_edges_editor_edge_deleted(edge: EdgeAst) -> void:
	if main_panel_instance:
		main_panel_instance.remove_edge(edge.from_node, edge.from_slot, edge.to_node, edge.to_slot)


func _on_main_panel_node_selected(node_ast: NodeAst) -> void:
	if node_editor:
		node_editor.dialogue_sequence_ast = main_panel_instance.dialogue_ast
		node_editor.node_ast = node_ast
	_set_edges()


func _on_main_panel_dialogue_sequence_ast_selected(dialogue_sequence_ast: DialogueAst) -> void:
	if node_editor:
		node_editor.dialogue_sequence_ast = dialogue_sequence_ast
		stores_editor.dialogue_ast = dialogue_sequence_ast
	_set_edges()
#endregion


func _exit_tree() -> void:
	if is_instance_valid(main_panel_instance):
		main_panel_instance.queue_free()
		
	if import_plugin:
		remove_import_plugin(import_plugin)
		import_plugin = null
		
	if node_editor:
		remove_control_from_docks(node_editor)
		node_editor = null

	if edges_editor:
		remove_control_from_docks(edges_editor)
		edges_editor = null

	if stores_editor:
		remove_control_from_docks(stores_editor)
		stores_editor = null
	
	if Engine.has_meta(ParleyConstants.PARLEY_PLUGIN_METADATA):
		Engine.remove_meta(ParleyConstants.PARLEY_PLUGIN_METADATA)


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		main_panel_instance.visible = visible
		if visible:
			await main_panel_instance.refresh()


func _get_plugin_name() -> String:
	return "Parley"


func _get_plugin_icon() -> Texture2D:
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")


func _enable_plugin() -> void:
	add_autoload_singleton(PARLEY_RUNTIME_AUTOLOAD, "./parley_runtime.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton(PARLEY_RUNTIME_AUTOLOAD)

	if Engine.has_singleton(PARLEY_MANAGER_SINGLETON):
		Engine.unregister_singleton(PARLEY_MANAGER_SINGLETON)

	if Engine.has_singleton(PARLEY_RUNTIME_SINGLETON):
		Engine.unregister_singleton(PARLEY_RUNTIME_SINGLETON)
