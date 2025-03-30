@tool
extends EditorPlugin

const ParleyConstants = preload("./constants.gd")
const ParleyImportPlugin: Script = preload("./import_plugin.gd")
const ParleyInspectorPlugin: Script = preload("./inspector_plugin.gd")
const MainPanel: PackedScene = preload("./main_panel.tscn")

const PARLEY_MANAGER_SINGLETON = "ParleyManager"

var main_panel_instance: Node
var import_plugin: EditorImportPlugin
var inspector_plugin: EditorInspectorPlugin

func _enter_tree():
	if Engine.is_editor_hint():
		Engine.set_meta(ParleyConstants.PARLEY_PLUGIN_METADATA, self)

		import_plugin = ParleyImportPlugin.new()
		add_import_plugin(import_plugin)
		
		inspector_plugin = ParleyInspectorPlugin.new()
		add_inspector_plugin(inspector_plugin)

		main_panel_instance = MainPanel.instantiate()
		main_panel_instance.node_selected.connect(_on_node_selected)
	
		# Add the main panel to the editor's main viewport.
		EditorInterface.get_editor_main_screen().add_child(main_panel_instance)

		# Hide the main panel. Very much required.
		_make_visible(false)

func _on_node_selected(node_ast: NodeAst) -> void:
	EditorInterface.get_inspector().edit(node_ast)

func _exit_tree():
	if is_instance_valid(main_panel_instance):
		main_panel_instance.queue_free()
		
	if import_plugin:
		remove_import_plugin(import_plugin)
		import_plugin = null

	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)
		inspector_plugin = null
	
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
