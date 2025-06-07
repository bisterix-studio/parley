# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

class_name ParleyDefaultBalloon extends CanvasLayer


const dialogue_container: PackedScene = preload('./dialogue/dialogue_container.tscn')
const dialogue_options_container: PackedScene = preload('./dialogue_option/dialogue_options_container.tscn')
const next_dialogue_button: PackedScene = preload('./next_dialogue_button.tscn')


## The action to use for advancing the dialogue
@export var advance_dialogue_action: StringName = &"ui_accept"


@onready var balloon: Control = %Balloon
@onready var balloon_container: VBoxContainer = %BalloonContainer


var ctx: Dictionary = {}
var dialogue_ast: ParleyDialogueSequenceAst
var dialogue_history: Array = []
## Temporary game states
var temporary_game_states: Array = []
## See if we are waiting for the player
var is_waiting_for_input: bool = false
var previous_node_ast: ParleyNodeAst = null
var current_node_asts: Array[ParleyNodeAst]: set = _set_current_node_asts


func _set_current_node_asts(p_current_node_asts: Array[ParleyNodeAst]) -> void:
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	# The dialogue has finished so close the balloon
	if p_current_node_asts.size() == 0 or is_instance_of(p_current_node_asts.front(), ParleyEndNodeAst):
		queue_free()
		return

	# If the node isn't ready yet then none of the options
	# will be ready yet either so we wait
	if not is_node_ready():
		await ready

	balloon.show()
	current_node_asts = p_current_node_asts
	var current_children: Array[Node] = balloon_container.get_children()
	var first_node: ParleyNodeAst = p_current_node_asts.front()
	var next_children: Array[Node] = _build_next_children(current_children, first_node)
	if next_children.size() == 0:
		return

	_handle_next_actions(current_children, next_children)

	balloon.focus_mode = Control.FOCUS_NONE
	if not ParleyDialogueSequenceAst.is_dialogue_options(current_node_asts):
		var next_button: Control = next_children.back()
		ParleyUtils.signals.safe_connect(next_button.gui_input, _on_next_dialogue_button_gui_input.bind(next_button))
		if not next_button.is_node_ready():
			await next_button.ready
		next_button.grab_focus()


func _build_next_children(current_children: Array[Node], current_node_ast: ParleyNodeAst) -> Array[Node]:
	var next_children: Array[Node] = []
	if is_instance_of(current_node_ast, ParleyDialogueNodeAst) and not (current_node_ast as ParleyDialogueNodeAst).text.is_empty():
		next_children.append_array(_build_next_dialogue_children(current_node_ast))
	elif current_node_asts.filter(func(_n: ParleyNodeAst) -> bool: return is_instance_of(current_node_ast, ParleyDialogueOptionNodeAst)).size() == current_node_asts.size():
		next_children.append_array(_build_next_dialogue_option_children(current_children))
	else:
		ParleyUtils.log.error("Invalid dialogue balloon nodes. Stopping processing.")
		return []
	return next_children


func _build_next_dialogue_children(current_node_ast: ParleyNodeAst) -> Array[Node]:
	var next_children: Array[Node] = []
	if previous_node_ast is ParleyDialogueOptionNodeAst:
		# Generate a new dialogue instance as if it were a dialogue
		# because it effectively is now
		var previous_dialogue_option_container: ParleyDialogueContainer = dialogue_container.instantiate()
		var dialogue_option_node_ast: ParleyDialogueOptionNodeAst = previous_node_ast
		var previous_node_dialogue_ast: ParleyDialogueNodeAst = ParleyDialogueNodeAst.new(dialogue_option_node_ast.id, dialogue_option_node_ast.position, dialogue_option_node_ast.character, dialogue_option_node_ast.text)
		previous_dialogue_option_container.dialogue_node = previous_node_dialogue_ast
		previous_dialogue_option_container.set_meta('ast', previous_node_dialogue_ast)
		next_children.append(previous_dialogue_option_container)
		next_children.append(_create_horizontal_separator(previous_dialogue_option_container))
	var next_dialogue_container: ParleyDialogueContainer = dialogue_container.instantiate()
	next_dialogue_container.dialogue_node = current_node_ast
	next_dialogue_container.set_meta('ast', current_node_ast)
	next_children.append(next_dialogue_container)
	var next_dialogue_button_control: ParleyNextDialogueButton = next_dialogue_button.instantiate()
	if dialogue_ast.is_at_end(ctx, current_node_ast):
		next_dialogue_button_control.text = 'Leave'
	next_children.append(next_dialogue_button_control)
	return next_children


func _build_next_dialogue_option_children(current_children: Array[Node]) -> Array[Node]:
	var next_children: Array[Node] = []
	var previous_node_variant: Variant = _find_previous_node_ast(current_children)
	if previous_node_variant is Control:
		var previous_node: Control = previous_node_variant
		next_children.append(previous_node)
		next_children.append(_create_horizontal_separator(previous_node))
	var dialogue_options_container_instance: ParleyDialogueOptionsMenu = dialogue_options_container.instantiate()
	dialogue_options_container_instance.dialogue_options = current_node_asts
	ParleyUtils.signals.safe_connect(dialogue_options_container_instance.dialogue_option_selected, _on_dialogue_options_container_dialogue_option_selected)
	next_children.append(dialogue_options_container_instance)
	return next_children


func _handle_next_actions(current_children: Array[Node], next_children: Array[Node]) -> void:
	var next_actions: Array[Dictionary] = []
	for child: Node in current_children:
		if child is ParleyDialogueContainer:
			if next_children.has(child):
				next_actions.append({
					'action': 'move_to_top',
					'child': child
				})
			else:
				next_actions.append({
					'action': 'exit_top',
					'child': child
				})
		else:
			next_actions.append({
				'action': 'fade_out',
				'child': child
			})
	for child: Node in next_children:
		if not current_children.has(child):
			next_actions.append({
				'action': 'fade_in',
				'child': child
			})
	for next_action: Dictionary in next_actions:
		match next_action.action:
			'exit_top': _exit_top(next_action)
			'move_to_top': _move_to_top(next_action)
			'fade_in': _fade_in(next_action)
			'fade_out': _fade_out(next_action)


func _create_horizontal_separator(sibling_above: Control) -> Node:
	var horizontal_separator: MarginContainer = MarginContainer.new()
	if sibling_above.has_theme_constant('margin_left'):
		var margin_left: int = sibling_above.get_theme_constant('margin_left')
		horizontal_separator.add_theme_constant_override('margin_left', margin_left * 2)
	if sibling_above.has_theme_constant('margin_right'):
		var margin_right: int = sibling_above.get_theme_constant('margin_right')
		horizontal_separator.add_theme_constant_override('margin_right', margin_right * 2)
	horizontal_separator.add_theme_constant_override('margin_top', 0)
	horizontal_separator.add_theme_constant_override('margin_bottom', 0)
	horizontal_separator.add_child(HSeparator.new())
	return horizontal_separator


#region ACTIONS
func _exit_top(next_action: Dictionary) -> void:
	var child: Variant = next_action.get('child')
	if child and child is Node:
		var node: Node = child
		if node.has_meta('ast'):
			var ast: Variant = node.get_meta('ast')
			if ast is ParleyNodeAst:
				var node_ast: ParleyNodeAst = ast
				dialogue_history.append(node_ast.duplicate())
			node.queue_free()
			await node.tree_exited


func _move_to_top(_next_action: Dictionary) -> void:
	pass


func _fade_in(next_action: Dictionary) -> void:
	var child: Variant = next_action.get('child')
	if child and child is Node:
		var node: Node = child
		balloon_container.add_child(node)


func _fade_out(next_action: Dictionary) -> void:
	var child: Variant = next_action.get('child')
	if child and child is Node:
		var node: Node = child
		node.queue_free()
		await node.tree_exited
#endregion

func _find_previous_node_ast(children: Array[Node]) -> Variant:
	if not previous_node_ast:
		return
	for child: Node in children:
		if child.has_meta('ast'):
			var ast: Variant = child.get_meta('ast')
			if ast.id == previous_node_ast.id:
				return child
	return


func _render_top() -> void:
	if not previous_node_ast:
		return
	match previous_node_ast.type:
		ParleyDialogueSequenceAst.Type.DIALOGUE:
			pass
			

func _ready() -> void:
	balloon.hide()


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


# TODO: add a context param
## Start some dialogue
func start(_ctx: Dictionary, _dialogue_ast: ParleyDialogueSequenceAst, start_node: ParleyNodeAst = null) -> void:
	balloon.show()
	temporary_game_states = [self]
	is_waiting_for_input = false
	ctx = _ctx
	dialogue_ast = _dialogue_ast
	if start_node is ParleyDialogueNodeAst or start_node is ParleyDialogueOptionNodeAst:
		current_node_asts = [start_node]
	elif start_node:
		current_node_asts = dialogue_ast.process_next(ctx, start_node)
	else:
		current_node_asts = dialogue_ast.process_next(ctx)


## Process the next Nodes
func next(current_node_ast: ParleyNodeAst) -> void:
	# Probably want to emit at this point? Or maybe earlier
	dialogue_history.append(current_node_ast)
	previous_node_ast = current_node_ast
	current_node_asts = dialogue_ast.process_next(ctx, current_node_ast)


#region Signals
func _on_balloon_gui_input(event: InputEvent) -> void:
	if not is_waiting_for_input: return
	if ParleyDialogueSequenceAst.is_dialogue_options(current_node_asts): return

	# When there are no dialogue options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	var current_node: ParleyDialogueNodeAst = current_node_asts.front()
	if event is InputEventMouseButton and event.is_pressed() and event.get('button_index') == MOUSE_BUTTON_LEFT:
		next(current_node)
	elif event.is_action_pressed(advance_dialogue_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(current_node)


func _on_next_dialogue_button_gui_input(event: InputEvent, item: Control) -> void:
	if ParleyDialogueSequenceAst.is_dialogue_options(current_node_asts): return
	get_viewport().set_input_as_handled()

	var current_node: ParleyDialogueNodeAst = current_node_asts.front()
	if event is InputEventMouseButton and event.is_pressed() and event.get('button_index') == MOUSE_BUTTON_LEFT:
		next(current_node)
	elif event is InputEventKey and event.is_action_pressed(advance_dialogue_action) and item is ParleyNextDialogueButton and get_viewport().gui_get_focus_owner() == item:
		next(current_node)


func _on_dialogue_options_container_dialogue_option_selected(current_node: ParleyDialogueOptionNodeAst) -> void:
	next(current_node)
#endregion
