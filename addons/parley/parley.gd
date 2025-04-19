@tool
extends EditorPlugin


#region DEFS
const ParleyConstants = preload("./constants.gd")
const ParleyImportPlugin: GDScript = preload("./import_plugin.gd")
const StoresEditorScene: PackedScene = preload("./stores/stores_editor.tscn")
const ParleyNodeScene: PackedScene = preload("./views/parley_node.tscn")
const ParleyEdges: PackedScene = preload("./views/parley_edges.tscn")
const MainPanelScene: PackedScene = preload("./main_panel.tscn")


const PARLEY_MANAGER_SINGLETON: String = "ParleyManager"


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
		ParleyUtils.safe_connect(stores_editor.dialogue_sequence_ast_changed, _on_dialogue_sequence_ast_changed.bind(Component.StoresEditor))
		ParleyUtils.safe_connect(stores_editor.dialogue_sequence_ast_selected, _on_dialogue_sequence_ast_selected.bind(Component.StoresEditor))
		add_control_to_dock(DockSlot.DOCK_SLOT_LEFT_UR, stores_editor)

		# Node Editor Dock
		node_editor = ParleyNodeScene.instantiate()
		ParleyUtils.safe_connect(node_editor.node_changed, _on_node_editor_node_changed)
		add_control_to_dock(DockSlot.DOCK_SLOT_RIGHT_UL, node_editor)

		# Edges Editor Dock
		edges_editor = ParleyEdges.instantiate()
		add_control_to_dock(DockSlot.DOCK_SLOT_RIGHT_BL, edges_editor)

		# Main Panel
		main_panel_instance = MainPanelScene.instantiate()
		ParleyUtils.safe_connect(main_panel_instance.node_selected, _on_main_panel_node_selected)
		ParleyUtils.safe_connect(main_panel_instance.dialogue_ast_selected, _on_main_panel_dialogue_sequence_ast_selected)
		if main_panel_instance.dialogue_ast:
			_on_dialogue_sequence_ast_changed(main_panel_instance.dialogue_ast, Component.MainPanel)
		EditorInterface.get_editor_main_screen().add_child(main_panel_instance)

		# Hide the main panel. Very much required.
		_make_visible(false)


func _set_edges() -> void:
	if node_editor and edges_editor and node_editor.dialogue_sequence_ast and node_editor.node_ast:
		var node_ast: NodeAst = node_editor.node_ast
		var dialogue_sequence_ast: DialogueAst = node_editor.dialogue_sequence_ast
		var edges: Array[EdgeAst] = dialogue_sequence_ast.edges
		edges_editor.set_edges(edges, node_ast.id)


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
	add_autoload_singleton(PARLEY_MANAGER_SINGLETON, "./parley_manager.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton(PARLEY_MANAGER_SINGLETON)
