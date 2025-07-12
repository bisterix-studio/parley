# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

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
const JumpNodeEditorScene: PackedScene = preload('../components/jump/jump_node_editor.tscn')


var dialogue_sequence_ast: ParleyDialogueSequenceAst: set = _set_dialogue_sequence_ast
var action_store: ParleyActionStore: set = _set_action_store
var fact_store: ParleyFactStore: set = _set_fact_store
var character_store: ParleyCharacterStore: set = _set_character_store
var node_ast: ParleyNodeAst: set = _set_node_ast


@onready var node_editor_container: VBoxContainer = %NodeEditorContainer


signal node_changed(node_ast: ParleyNodeAst)
signal delete_node_button_pressed(id: String)
signal dialogue_sequence_ast_selected(selected_dialogue_sequence_ast: ParleyDialogueSequenceAst)
#endregion


#region SETTERS
func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast = new_dialogue_sequence_ast


func _set_node_ast(new_node_ast: ParleyNodeAst) -> void:
	node_ast = new_node_ast
	_render_node()


func _set_action_store(new_action_store: ParleyActionStore) -> void:
	action_store = new_action_store
	_render_node()


func _set_fact_store(new_fact_store: ParleyFactStore) -> void:
	fact_store = new_fact_store
	_render_node()


func _set_character_store(new_character_store: ParleyCharacterStore) -> void:
	character_store = new_character_store
	_render_node()
#endregion


#region RENDERERS
func _render_node() -> void:
	for child: Node in node_editor_container.get_children():
		child.queue_free()
	if node_ast:
		match node_ast.type:
			ParleyDialogueSequenceAst.Type.DIALOGUE: _render_dialogue_node_editor()
			ParleyDialogueSequenceAst.Type.DIALOGUE_OPTION: _render_dialogue_option_node_editor()
			ParleyDialogueSequenceAst.Type.CONDITION: _render_condition_node_editor()
			ParleyDialogueSequenceAst.Type.MATCH: _render_match_node_editor()
			ParleyDialogueSequenceAst.Type.ACTION: _render_action_node_editor()
			ParleyDialogueSequenceAst.Type.GROUP: _render_group_node_editor()
			ParleyDialogueSequenceAst.Type.START: _render_start_node_editor()
			ParleyDialogueSequenceAst.Type.END: _render_end_node_editor()
			ParleyDialogueSequenceAst.Type.JUMP: _render_jump_node_editor()
			_:
				push_error(ParleyUtils.log.error_msg("Unsupported Node type: %s for Node with ID: %s" % [ParleyDialogueSequenceAst.get_type_name(node_ast.type), node_ast.id]))
				return


func _render_dialogue_node_editor() -> void:
	if not dialogue_sequence_ast:
		push_error(ParleyUtils.log.error_msg("No Dialogue Sequence AST selected for %s, unable to render node editor" % [node_ast]))
		return
	var dialogue_node_ast: ParleyDialogueNodeAst = node_ast
	var dialogue_node_editor: ParleyDialogueNodeEditor = DialogueNodeEditorScene.instantiate()
	dialogue_node_editor.character_store = character_store
	dialogue_node_editor.id = dialogue_node_ast.id
	dialogue_node_editor.character = dialogue_node_ast.character
	dialogue_node_editor.dialogue = dialogue_node_ast.text
	ParleyUtils.signals.safe_connect(dialogue_node_editor.dialogue_node_changed, _on_dialogue_node_editor_dialogue_node_changed)
	ParleyUtils.signals.safe_connect(dialogue_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(dialogue_node_editor)


func _render_dialogue_option_node_editor() -> void:
	if not dialogue_sequence_ast:
		push_error(ParleyUtils.log.error_msg("No Dialogue Sequence AST selected for %s, unable to render node editor" % [node_ast]))
		return
	var dialogue_option_node_ast: ParleyDialogueOptionNodeAst = node_ast
	var dialogue_option_node_editor: ParleyDialogueOptionNodeEditor = DialogueOptionNodeEditorScene.instantiate()
	dialogue_option_node_editor.character_store = character_store
	dialogue_option_node_editor.id = dialogue_option_node_ast.id
	dialogue_option_node_editor.character = dialogue_option_node_ast.character
	dialogue_option_node_editor.option = dialogue_option_node_ast.text
	ParleyUtils.signals.safe_connect(dialogue_option_node_editor.dialogue_option_node_changed, _on_dialogue_option_node_editor_dialogue_option_node_changed)
	ParleyUtils.signals.safe_connect(dialogue_option_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(dialogue_option_node_editor)


func _render_condition_node_editor() -> void:
	if not dialogue_sequence_ast:
		push_error(ParleyUtils.log.error_msg("No Dialogue Sequence AST selected for %s, unable to render node editor" % [node_ast]))
		return
	var condition_node_ast: ParleyConditionNodeAst = node_ast
	var combiner: ParleyConditionNodeAst.Combiner = condition_node_ast.combiner
	# Create a separation between layers by duplicating
	var conditions: Array = condition_node_ast.conditions.duplicate(true).map(
		func(condition_item: Dictionary) -> Dictionary:
			var fact_ref: String = condition_item['fact_ref']
			var exists: bool = ResourceLoader.exists(fact_ref)
			if not exists:
				push_warning(ParleyUtils.log.warn_msg("Condition fact ref '%s' does not exist within the file system meaning this Dialogue Sequence will likely fail at runtime." % fact_ref))
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
		push_error(ParleyUtils.log.error_msg("No Dialogue Sequence AST selected for %s, unable to render node editor" % [node_ast]))
		return
	var match_node_ast: ParleyMatchNodeAst = node_ast
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
		push_error(ParleyUtils.log.error_msg("No Dialogue Sequence AST selected for %s, unable to render node editor" % [node_ast]))
		return
	var action_node_ast: ParleyActionNodeAst = node_ast
	var exists: bool = ResourceLoader.exists(action_node_ast.action_script_ref)
	if not exists and action_node_ast.action_script_ref != "":
		push_warning(ParleyUtils.log.warn_msg("Action script ref '%s' does not exist within the file system meaning this Dialogue Sequence will likely fail at runtime." % action_node_ast.action_script_ref))

	## TODO: create from ast
	var action_node_editor: ParleyActionNodeEditor = ActionNodeEditorScene.instantiate()
	action_node_editor.action_store = action_store
	action_node_editor.id = action_node_ast.id
	action_node_editor.description = action_node_ast.description
	action_node_editor.action_type = action_node_ast.action_type
	action_node_editor.action_script_ref = action_node_ast.action_script_ref
	action_node_editor.values = action_node_ast.values
	ParleyUtils.signals.safe_connect(action_node_editor.action_node_changed, _on_action_node_editor_action_node_changed)
	ParleyUtils.signals.safe_connect(action_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(action_node_editor)


func _render_jump_node_editor() -> void:
	if not dialogue_sequence_ast:
		push_error(ParleyUtils.log.error_msg("No Dialogue Sequence AST selected for %s, unable to render node editor" % [node_ast]))
		return
	var jump_node_ast: ParleyJumpNodeAst = node_ast
	var exists: bool = ResourceLoader.exists(jump_node_ast.dialogue_sequence_ast_ref)
	if not exists and jump_node_ast.dialogue_sequence_ast_ref != "":
		push_warning(ParleyUtils.log.warn_msg("Jump Node Dialogue Sequence ref '%s' does not exist within the file system meaning this Dialogue Sequence will likely fail at runtime." % jump_node_ast.dialogue_sequence_ast_ref))

	## TODO: create from ast
	var jump_node_editor: ParleyJumpNodeEditor = JumpNodeEditorScene.instantiate()
	jump_node_editor.id = jump_node_ast.id
	jump_node_editor.dialogue_sequence_ast_ref = jump_node_ast.dialogue_sequence_ast_ref
	ParleyUtils.signals.safe_connect(jump_node_editor.jump_node_changed, _on_jump_node_editor_jump_node_changed)
	ParleyUtils.signals.safe_connect(jump_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	ParleyUtils.signals.safe_connect(jump_node_editor.dialogue_sequence_ast_selected, _on_dialogue_sequence_ast_selected)
	node_editor_container.add_child(jump_node_editor)


func _render_group_node_editor() -> void:
	if not dialogue_sequence_ast:
		push_error(ParleyUtils.log.error_msg("No Dialogue Sequence AST selected for %s, unable to render node editor" % [node_ast]))
		return
	var group_node_ast: ParleyGroupNodeAst = node_ast
	## TODO: create from ast
	var group_node_editor: ParleyGroupNodeEditor = GroupNodeEditorScene.instantiate()
	group_node_editor.id = group_node_ast.id
	group_node_editor.group_name = group_node_ast.name
	group_node_editor.colour = group_node_ast.colour
	ParleyUtils.signals.safe_connect(group_node_editor.group_node_changed, _on_group_node_editor_group_node_changed)
	ParleyUtils.signals.safe_connect(group_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(group_node_editor)


func _render_start_node_editor() -> void:
	if not dialogue_sequence_ast:
		push_error(ParleyUtils.log.error_msg("No Dialogue Sequence AST selected for %s, unable to render node editor" % [node_ast]))
		return
	var start_node_ast: ParleyStartNodeAst = node_ast
	## TODO: create from ast
	var start_node_editor: ParleyStartNodeEditor = StartNodeEditorScene.instantiate()
	start_node_editor.id = start_node_ast.id
	ParleyUtils.signals.safe_connect(start_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(start_node_editor)


func _render_end_node_editor() -> void:
	if not dialogue_sequence_ast:
		push_error(ParleyUtils.log.error_msg("No Dialogue Sequence AST selected for %s, unable to render node editor" % [node_ast]))
		return
	var end_node_ast: ParleyEndNodeAst = node_ast
	## TODO: create from ast
	var end_node_editor: ParleyEndNodeEditor = EndNodeEditorScene.instantiate()
	end_node_editor.id = end_node_ast.id
	ParleyUtils.signals.safe_connect(end_node_editor.delete_node_button_pressed, _on_delete_node_button_pressed)
	node_editor_container.add_child(end_node_editor)
#endregion


# TODO: check ID exists in the Dialogue Sequence ast and is of the correct type
#region SIGNALS
func _on_dialogue_node_editor_dialogue_node_changed(_id: String, character: String, dialogue: String) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: ParleyDialogueNodeAst = node_ast.duplicate(true)
	new_node_ast.character = character
	new_node_ast.text = dialogue
	node_changed.emit(new_node_ast)


func _on_delete_node_button_pressed(id: String) -> void:
	delete_node_button_pressed.emit(id)


func _on_dialogue_option_node_editor_dialogue_option_node_changed(_id: String, character: String, option: String) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: ParleyDialogueOptionNodeAst = node_ast.duplicate(true)
	new_node_ast.character = character
	new_node_ast.text = option
	node_changed.emit(new_node_ast)


func _on_condition_node_editor_condition_node_changed(_id: String, description: String, combiner: ParleyConditionNodeAst.Combiner, conditions: Array) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: ParleyConditionNodeAst = node_ast.duplicate(true)
	var ast_conditions: Array = []
	for condition_def: Dictionary in conditions:
		# TODO: this seems pointless, isn't fact_ref the same as uid?
		var fact_ref: String = condition_def['fact_ref']
		var fact: ParleyFact = fact_store.get_fact_by_ref(fact_ref)
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
	var new_node_ast: ParleyMatchNodeAst = node_ast.duplicate(true)
	# TODO: this seems pointless, isn't fact_ref the same as uid?
	var fact: ParleyFact = fact_store.get_fact_by_ref(fact_ref)
	var uid: String = ""
	if fact.id != "":
		uid = ParleyUtils.resource.get_uid(fact.ref)
	new_node_ast.description = description
	new_node_ast.fact_ref = uid
	new_node_ast.cases = cases.duplicate()
	node_changed.emit(new_node_ast)


func _on_jump_node_editor_jump_node_changed(_id: String, dialogue_sequence_ast_ref: String) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: ParleyJumpNodeAst = node_ast.duplicate(true)
	new_node_ast.dialogue_sequence_ast_ref = dialogue_sequence_ast_ref
	node_changed.emit(new_node_ast)


func _on_dialogue_sequence_ast_selected(selected_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast_selected.emit(selected_dialogue_sequence_ast)


func _on_action_node_editor_action_node_changed(_id: String, description: String, action_type: ParleyActionNodeAst.ActionType, action_script_ref: String, values: Array) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: ParleyActionNodeAst = node_ast.duplicate(true)
	# TODO: this seems pointless, isn't action_script_ref the same as uid?
	var action: ParleyAction = action_store.get_action_by_ref(action_script_ref)
	var uid: String = ""
	if action.id != "":
		uid = ParleyUtils.resource.get_uid(action.ref)
	new_node_ast.update(description, action_type, uid, values)
	node_changed.emit(new_node_ast)


func _on_group_node_editor_group_node_changed(_id: String, group_name: String, colour: Color) -> void:
	# TODO: we should probably just update the resource here - it would make things way easier!
	var new_node_ast: ParleyGroupNodeAst = node_ast.duplicate(true)
	new_node_ast.name = group_name
	new_node_ast.colour = colour
	node_changed.emit(new_node_ast)
#endregion
