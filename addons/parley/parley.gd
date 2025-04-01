@tool
extends EditorPlugin

const ParleyConstants = preload("./constants.gd")
const ParleyImportPlugin: Script = preload("./import_plugin.gd")
# TODO: remove
# const ParleyInspectorPlugin: Script = preload("./inspector_plugin.gd")
const StoresEditor: PackedScene = preload("./stores/stores_editor.tscn")
const NodeEditor: PackedScene = preload("./views/node_editor.tscn")
const EdgesEditor: PackedScene = preload("./views/edges_editor.tscn")
const MainPanel: PackedScene = preload("./main_panel.tscn")

const PARLEY_MANAGER_SINGLETON = "ParleyManager"

var main_panel_instance: Node
var import_plugin: EditorImportPlugin
# TODO: remove
# var inspector_plugin: EditorInspectorPlugin
var stores_editor: PanelContainer
var node_editor: PanelContainer
var edges_editor: PanelContainer

func _enter_tree():
	if Engine.is_editor_hint():
		Engine.set_meta(ParleyConstants.PARLEY_PLUGIN_METADATA, self)

		# Import plugin setup
		import_plugin = ParleyImportPlugin.new()
		add_import_plugin(import_plugin)
		
		# TODO: remove
		# inspector_plugin = ParleyInspectorPlugin.new()
		# add_inspector_plugin(inspector_plugin)
		
		# Stores Editor Dock
		stores_editor = StoresEditor.instantiate()
		add_control_to_dock(DockSlot.DOCK_SLOT_LEFT_UR, stores_editor)

		# Node Editor Dock
		node_editor = NodeEditor.instantiate()
		node_editor.node_changed.connect(_on_node_editor_node_changed)
		add_control_to_dock(DockSlot.DOCK_SLOT_RIGHT_UL, node_editor)

		# Edges Editor Dock
		edges_editor = EdgesEditor.instantiate()
		add_control_to_dock(DockSlot.DOCK_SLOT_RIGHT_BL, edges_editor)

		# Main Panel
		main_panel_instance = MainPanel.instantiate()
		main_panel_instance.node_selected.connect(_on_main_panel_node_selected)
		main_panel_instance.dialogue_ast_selected.connect(_on_main_panel_dialogue_sequence_ast_selected)
		EditorInterface.get_editor_main_screen().add_child(main_panel_instance)

		# Hide the main panel. Very much required.
		_make_visible(false)

func _on_node_editor_node_changed(node_ast: NodeAst) -> void:
	if main_panel_instance:
		main_panel_instance.selected_node_ast = node_ast

func _on_main_panel_node_selected(node_ast: NodeAst) -> void:
	if node_editor:
		node_editor.node_ast = node_ast
	_set_edges()

func _set_edges() -> void:
	if node_editor and edges_editor and node_editor.dialogue_sequence_ast and node_editor.node_ast:
		var node_ast: NodeAst = node_editor.node_ast
		var dialogue_sequence_ast: DialogueAst = node_editor.dialogue_sequence_ast
		var edges: Array[EdgeAst] = dialogue_sequence_ast.edges
		edges_editor.set_edges(edges, node_ast.id)

func _on_main_panel_dialogue_sequence_ast_selected(dialogue_sequence_ast: DialogueAst) -> void:
	if node_editor:
		node_editor.dialogue_sequence_ast = dialogue_sequence_ast
	_set_edges()

func _exit_tree():
	if is_instance_valid(main_panel_instance):
		main_panel_instance.queue_free()
		
	if import_plugin:
		remove_import_plugin(import_plugin)
		import_plugin = null

	# TODO: remove
	# if inspector_plugin:
	# 	remove_inspector_plugin(inspector_plugin)
	# 	inspector_plugin = null
		
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

func _has_main_screen():
	return true

func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
		if visible:
			await main_panel_instance.refresh()

func _get_plugin_name():
	return "Parley"

func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

func _enable_plugin():
	add_autoload_singleton(PARLEY_MANAGER_SINGLETON, "./parley_manager.gd")

func _disable_plugin():
	remove_autoload_singleton(PARLEY_MANAGER_SINGLETON)
