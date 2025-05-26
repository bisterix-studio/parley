@tool
class_name ParleyNodeEditor extends PanelContainer


#region DEFS
const DialogueNodeEditorScene: PackedScene = preload('../components/dialogue/dialogue_node_editor.tscn')
const DialogueOptionNodeEditorScene: PackedScene = preload('../components/dialogue_option/dialogue_option_node_editor.tscn')
const ConditionNodeEditorScene: PackedScene = preload('../components/condition/condition_node_editor.tscn')
const ActionNodeEditorScene: PackedScene = preload('../components/action/action_node_editor.tscn')
const MatchNodeEditorScene: PackedScene = preload('../components/match/match_node_editor.tscn')
const StartNodeEditorScene: PackedScene = preload('../components/start/start_node_editor.tscn')
const EndNodeEditorScene: PackedScene = preload('../components/end/end_node_editor.tscn')
const GroupNodeEditorScene: PackedScene = preload('../components/group/group_node_editor.tscn')


var dialogue_sequence_ast: DialogueAst: set = _set_dialogue_sequence_ast
var action_store: ActionStore: set = _set_action_store
var fact_store: FactStore: set = _set_fact_store
var character_store: CharacterStore: set = _set_character_store
var node_ast: NodeAst: set = _set_node_ast


@onready var node_editor_container: VBoxContainer = %NodeEditorContainer


signal node_changed(node_ast: NodeAst)
signal delete_node_button_pressed(id: String)
#endregion


#region SETTERS
func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: DialogueAst) -> void:
	dialogue_sequence_ast = new_dialogue_sequence_ast


func _set_node_ast(new_node_ast: NodeAst) -> void:
	node_ast = new_node_ast
	_render_node()


func _set_action_store(new_action_store: ActionStore) -> void:
	action_store = new_action_store
	_render_node()


func _set_fact_store(new_fact_store: FactStore) -> void:
	fact_store = new_fact_store
	_render_node()


func _set_character_store(new_character_store: CharacterStore) -> void:
	character_store = new_character_store
	_render_node()
#endregion


#region RENDERERS
func _render_node() -> void:
	for child: Node in node_editor_container.get_children():
		child.queue_free()
	if node_ast:
		match node_ast.type:
			DialogueAst.Type.DIALOGUE: _render_dialogue_node_editor()
			DialogueAst.Type.DIALOGUE_OPTION: _render_dialogue_option_node_editor()
			DialogueAst.Type.CONDITION: _render_condition_node_editor()
			DialogueAst.Type.MATCH: _render_match_node_editor()
			DialogueAst.Type.ACTION: _render_action_node_editor()
			DialogueAst.Type.GROUP: _render_group_node_editor()
			DialogueAst.Type.START: _render_start_node_editor()
			DialogueAst.Type.END: _render_end_node_editor()
			_:
				ParleyUtils.log.error("Unsupported Node type: %s for Node with ID: %s" % [DialogueAst.get_type_name(node_ast.type), node_ast.id])
				return


func _render_dialogue_node_editor() -> void:
	if not dialogue_sequence_ast:
		ParleyUtils.log.error("No dialogue sequence AST selected for %s, unable to render node editor" % [node_ast])
		return
	var dialogue_node_ast: DialogueNodeAst = node_ast
	var dialogue_node_editor: DialogueNodeEditor = DialogueNodeEditorScene.instantiate()
	dialogue_node_editor.character_store = character_store
	dialogue_node_editor.id = dialogue_node_ast.id
	dialogue_node_editor.character = dialogue_node_ast.character
	dialogue_node_editor.dialogue = dialogue_node_ast.text
	ParleyUtils.signals.safe_connect(dialogue_node_editor.dialogue_node_changed, _on_dialogue_node_editor_dialogue_node_changed)
	ParleyUtils.signals.safe_connect(dialogue_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(dialogue_node_editor)


func _render_dialogue_option_node_editor() -> void:
	if not dialogue_sequence_ast:
		ParleyUtils.log.error("No dialogue sequence AST selected for %s, unable to render node editor" % [node_ast])
		return
	var dialogue_option_node_ast: DialogueOptionNodeAst = node_ast
	var dialogue_option_node_editor: DialogueOptionNodeEditor = DialogueOptionNodeEditorScene.instantiate()
	dialogue_option_node_editor.character_store = character_store
	dialogue_option_node_editor.id = dialogue_option_node_ast.id
	dialogue_option_node_editor.selected_character_stores = dialogue_sequence_ast.stores.character
	dialogue_option_node_editor.character = dialogue_option_node_ast.character
	dialogue_option_node_editor.option = dialogue_option_node_ast.text
	ParleyUtils.signals.safe_connect(dialogue_option_node_editor.dialogue_option_node_changed, _on_dialogue_option_node_editor_dialogue_option_node_changed)
	ParleyUtils.signals.safe_connect(dialogue_option_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(dialogue_option_node_editor)


func _render_condition_node_editor() -> void:
	if not dialogue_sequence_ast:
		ParleyUtils.log.error("No dialogue sequence AST selected for %s, unable to render node editor" % [node_ast])
		return
	var condition_node_ast: ConditionNodeAst = node_ast
	var combiner: ConditionNodeAst.Combiner = condition_node_ast.combiner
	# Create a separation between layers by duplicating
	var conditions: Array = condition_node_ast.conditions.duplicate(true).map(
		func(condition_item: Dictionary) -> Dictionary:
			var fact_ref: String = condition_item['fact_ref']
			var exists: bool = ResourceLoader.exists(fact_ref)
			if not exists:
				ParleyUtils.log.warn("Condition fact ref '%s' does not exist within the file system meaning this dialogue sequence will likely fail at runtime." % fact_ref)
			return {
				'fact_ref': fact_ref,
				'operator': condition_item['operator'],
				'value': condition_item['value'],
			}
	)
	var condition_node_editor: ParleyConditionNodeEditor = ConditionNodeEditorScene.instantiate()
	condition_node_editor.fact_store = fact_store
	condition_node_editor.id = condition_node_ast.id
	condition_node_editor.description = condition_node_ast.description
	condition_node_editor.combiner = condition_node_ast.combiner
	condition_node_editor.conditions = condition_node_ast.conditions
	ParleyUtils.signals.safe_connect(condition_node_editor.condition_node_changed, _on_condition_node_editor_condition_node_changed)
	ParleyUtils.signals.safe_connect(condition_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(condition_node_editor)


func _render_match_node_editor() -> void:
	if not dialogue_sequence_ast:
		ParleyUtils.log.error("No dialogue sequence AST selected for %s, unable to render node editor" % [node_ast])
		return
	var match_node_ast: MatchNodeAst = node_ast
	## TODO: create from ast
	var match_node_editor: ParleyMatchNodeEditor = MatchNodeEditorScene.instantiate()
	match_node_editor.fact_store = fact_store
	match_node_editor.id = match_node_ast.id
	match_node_editor.description = match_node_ast.description
	match_node_editor.fact_ref = match_node_ast.fact_ref
	match_node_editor.cases = match_node_ast.cases
	ParleyUtils.signals.safe_connect(match_node_editor.match_node_changed, _on_match_node_editor_match_node_changed)
	ParleyUtils.signals.safe_connect(match_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(match_node_editor)


func _render_action_node_editor() -> void:
	if not dialogue_sequence_ast:
		ParleyUtils.log.error("No dialogue sequence AST selected for %s, unable to render node editor" % [node_ast])
		return
	var action_node_ast: ActionNodeAst = node_ast
	var exists: bool = ResourceLoader.exists(action_node_ast.action_script_ref)
	if not exists and action_node_ast.action_script_ref != "":
		ParleyUtils.log.warn("Action script ref '%s' does not exist within the file system meaning this dialogue sequence will likely fail at runtime." % action_node_ast.action_script_ref)

	## TODO: create from ast
	var action_node_editor: ActionNodeEditor = ActionNodeEditorScene.instantiate()
	action_node_editor.action_store = action_store
	action_node_editor.id = action_node_ast.id
	action_node_editor.description = action_node_ast.description
	action_node_editor.action_type = action_node_ast.action_type
	action_node_editor.action_script_ref = action_node_ast.action_script_ref
	action_node_editor.values = action_node_ast.values
	ParleyUtils.signals.safe_connect(action_node_editor.action_node_changed, _on_action_node_editor_action_node_changed)
	ParleyUtils.signals.safe_connect(action_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(action_node_editor)


func _render_group_node_editor() -> void:
	if not dialogue_sequence_ast:
		ParleyUtils.log.error("No dialogue sequence AST selected for %s, unable to render node editor" % [node_ast])
		return
	var group_node_ast: GroupNodeAst = node_ast
	## TODO: create from ast
	var group_node_editor: GroupNodeEditor = GroupNodeEditorScene.instantiate()
	group_node_editor.id = group_node_ast.id
	group_node_editor.group_name = group_node_ast.name
	group_node_editor.colour = group_node_ast.colour
	ParleyUtils.signals.safe_connect(group_node_editor.group_node_changed, _on_group_node_editor_group_node_changed)
	ParleyUtils.signals.safe_connect(group_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(group_node_editor)


func _render_start_node_editor() -> void:
	if not dialogue_sequence_ast:
		ParleyUtils.log.error("No dialogue sequence AST selected for %s, unable to render node editor" % [node_ast])
		return
	var start_node_ast: StartNodeAst = node_ast
	## TODO: create from ast
	var start_node_editor: StartNodeEditor = StartNodeEditorScene.instantiate()
	start_node_editor.id = start_node_ast.id
	ParleyUtils.signals.safe_connect(start_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(start_node_editor)


func _render_end_node_editor() -> void:
	if not dialogue_sequence_ast:
		ParleyUtils.log.error("No dialogue sequence AST selected for %s, unable to render node editor" % [node_ast])
		return
	var end_node_ast: EndNodeAst = node_ast
	## TODO: create from ast
	var end_node_editor: EndNodeEditor = EndNodeEditorScene.instantiate()
	end_node_editor.id = end_node_ast.id
	ParleyUtils.signals.safe_connect(end_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(end_node_editor)
#endregion


# TODO: check ID exists in the dialogue sequence ast and is of the correct type
#region SIGNALS
func _on_dialogue_node_editor_dialogue_node_changed(_id: String, character: String, dialogue: String) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: DialogueNodeAst = node_ast.duplicate(true)
	new_node_ast.character = character
	new_node_ast.text = dialogue
	node_changed.emit(new_node_ast)


func _on_delete_node_button_pressed(id: String) -> void:
	delete_node_button_pressed.emit(id)


func _on_dialogue_option_node_editor_dialogue_option_node_changed(_id: String, character: String, option: String) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: DialogueOptionNodeAst = node_ast.duplicate(true)
	new_node_ast.character = character
	new_node_ast.text = option
	node_changed.emit(new_node_ast)


func _on_condition_node_editor_condition_node_changed(_id: String, description: String, combiner: ConditionNodeAst.Combiner, conditions: Array) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: ConditionNodeAst = node_ast.duplicate(true)
	var ast_conditions: Array = []
	for condition_def: Dictionary in conditions:
		# TODO: this seems pointless, isn't fact_ref the same as uid?
		var fact_ref: String = condition_def['fact_ref']
		var fact: Fact = fact_store.get_fact_by_ref(fact_ref)
		var uid: String = ""
		if fact.id != "":
			uid = ParleyUtils.resource.get_uid(fact.ref)
		ast_conditions.append({
			'fact_ref': uid,
			'operator': condition_def['operator'],
			'value': condition_def['value'],
		})
	# TODO: use setters
	new_node_ast.update(description, combiner, ast_conditions)
	node_changed.emit(new_node_ast)


func _on_match_node_editor_match_node_changed(_id: String, description: String, fact_ref: String, cases: Array[Variant]) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: MatchNodeAst = node_ast.duplicate(true)
	# TODO: this seems pointless, isn't fact_ref the same as uid?
	var fact: Fact = fact_store.get_fact_by_ref(fact_ref)
	var uid: String = ""
	if fact.id != "":
		uid = ParleyUtils.resource.get_uid(fact.ref)
	new_node_ast.description = description
	new_node_ast.fact_ref = uid
	new_node_ast.cases = cases.duplicate()
	node_changed.emit(new_node_ast)


func _on_action_node_editor_action_node_changed(_id: String, description: String, action_type: ActionNodeAst.ActionType, action_script_ref: String, values: Array) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: ActionNodeAst = node_ast.duplicate(true)
	# TODO: this seems pointless, isn't action_script_ref the same as uid?
	var action: Action = action_store.get_action_by_ref(action_script_ref)
	var uid: String = ""
	if action.id != "":
		uid = ParleyUtils.resource.get_uid(action.ref)
	new_node_ast.update(description, action_type, uid, values)
	node_changed.emit(new_node_ast)


func _on_group_node_editor_group_node_changed(_id: String, group_name: String, colour: Color) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: GroupNodeAst = node_ast.duplicate(true)
	new_node_ast.name = group_name
	new_node_ast.colour = colour
	node_changed.emit(new_node_ast)
#endregion
