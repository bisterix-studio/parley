# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyGraphView extends GraphEdit

var ast: ParleyDialogueSequenceAst
var action_store: ParleyActionStore = ParleyActionStore.new(): set = _set_action_store
var fact_store: ParleyFactStore = ParleyFactStore.new(): set = _set_fact_store
var character_store: ParleyCharacterStore = ParleyCharacterStore.new(): set = _set_character_store

#region SETUP
const dialogue_node_scene: PackedScene = preload("../components/dialogue/dialogue_node.tscn")
const dialogue_option_node_scene: PackedScene = preload("../components/dialogue_option/dialogue_option_node.tscn")
const action_node_scene: PackedScene = preload("../components/action/action_node.tscn")
const condition_node_scene: PackedScene = preload("../components/condition/condition_node.tscn")
const match_node_scene: PackedScene = preload("../components/match/match_node.tscn")
const start_node_scene: PackedScene = preload("../components/start/start_node.tscn")
const end_node_scene: PackedScene = preload("../components/end/end_node.tscn")
const group_node_scene: PackedScene = preload("../components/group/group_node.tscn")
const jump_node_scene: PackedScene = preload("../components/jump/jump_node.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await clear()
	scroll_offset = Vector2(-50, -50)


func _exit_tree() -> void:
	await clear()
	ast = null
	connections = []


func generate(arrange: bool = false) -> void:
	await clear()
	_generate_dialogue_nodes()
	if arrange:
		arrange_nodes()


func clear() -> void:
	clear_connections()
	var children: Array[ParleyGraphNode] = []
	for child: Node in get_children():
		if child is ParleyGraphNode:
			child.queue_free()
			children.append(child)
	for child: ParleyGraphNode in children:
		await child.tree_exited
#endregion


#region SETTERS
func _set_action_store(new_action_store: ParleyActionStore) -> void:
	action_store = new_action_store


func _set_fact_store(new_fact_store: ParleyFactStore) -> void:
	fact_store = new_fact_store


func _set_character_store(new_character_store: ParleyCharacterStore) -> void:
	character_store = new_character_store
#endregion


#region GENERATE COMPONENTS
func _register_node(ast_node: ParleyNodeAst) -> ParleyGraphNode:
	var type: ParleyDialogueSequenceAst.Type = ast_node.type
	var graph_node: ParleyGraphNode
	match type:
		ParleyDialogueSequenceAst.Type.DIALOGUE:
			graph_node = _create_dialogue_node(ast_node as ParleyDialogueNodeAst)
		ParleyDialogueSequenceAst.Type.DIALOGUE_OPTION:
			graph_node = _create_dialogue_option_node(ast_node as ParleyDialogueOptionNodeAst)
		ParleyDialogueSequenceAst.Type.CONDITION:
			graph_node = _create_condition_node(ast_node as ParleyConditionNodeAst)
		ParleyDialogueSequenceAst.Type.MATCH:
			graph_node = _create_match_node(ast_node as ParleyMatchNodeAst)
		ParleyDialogueSequenceAst.Type.ACTION:
			graph_node = _create_action_node(ast_node as ParleyActionNodeAst)
		ParleyDialogueSequenceAst.Type.START:
			graph_node = _create_start_node(ast_node as ParleyStartNodeAst)
		ParleyDialogueSequenceAst.Type.END:
			graph_node = _create_end_node(ast_node as ParleyEndNodeAst)
		ParleyDialogueSequenceAst.Type.GROUP:
			graph_node = _create_group_node(ast_node as ParleyGroupNodeAst)
		ParleyDialogueSequenceAst.Type.JUMP:
			graph_node = _create_jump_node(ast_node as ParleyJumpNodeAst)
		_:
			print_rich(ParleyUtils.log.info_msg("AST Node {type} is not supported".format({"type": type})))
			return
	var ast_node_id: String = ast_node.id
	# TODO: v. bad to change ast stuff here - refactor to avoid horrible bugs
	ParleyUtils.signals.safe_connect(graph_node.position_offset_changed, func() -> void:
		if ast_node.type == ParleyDialogueSequenceAst.Type.GROUP and graph_node is ParleyGroupNode:
			var group_graph_node: ParleyGroupNode = graph_node
			var diff: Vector2 = graph_node.position_offset - ast_node.position
			var nodes: Array[ParleyGraphNode] = _get_nodes_by_ids(group_graph_node.node_ids)
			for sub_node: ParleyGraphNode in nodes:
				sub_node.position_offset = sub_node.position_offset + diff
				# TODO: should do this via a signal
				ast.update_node_position(sub_node.id, sub_node.position_offset)
		# TODO: should do this via a signal
		ast.update_node_position(ast_node_id, graph_node.position_offset))
	graph_node.position_offset = ast_node.position
	add_child(graph_node)
	return graph_node


# TODO: v. bad to change ast stuff here - refactor to avoid horrible bugs
func _update_nodes_covered_by_group_node(group_node: ParleyGroupNode, group_node_ast: ParleyGroupNodeAst) -> Array[ParleyGraphNode]:
	var nodes: Array[ParleyGraphNode] = []
	for child: Node in get_children():
		if child is ParleyGraphNode and (child as ParleyGraphNode).id != group_node.id:
			var parley_graph_node: ParleyGraphNode = child
			var is_within_horizontal: bool = parley_graph_node.position_offset.x >= group_node.position_offset.x and parley_graph_node.position_offset.x <= (group_node.position_offset + group_node.size).x
			var is_within_vertical: bool = parley_graph_node.position_offset.y >= group_node.position_offset.y and parley_graph_node.position_offset.y <= (group_node.position_offset + group_node.size).y
			if is_within_horizontal and is_within_vertical:
				nodes.append(parley_graph_node)
	var new_node_ids: Array = nodes.map(func(n: ParleyGraphNode) -> String: return n.id)
	group_node.node_ids = new_node_ids
	# TODO: should do this via a signal at the main panel level
	# so the editor can also be changed at the same time
	new_node_ids.sort()
	group_node_ast.node_ids = new_node_ids
	return nodes


func _get_nodes_by_ids(ids: Array) -> Array[ParleyGraphNode]:
	var nodes: Array[ParleyGraphNode] = []
	for child: Node in get_children():
		if child is ParleyGraphNode and ids.has((child as ParleyGraphNode).id):
			nodes.append(child)
	return nodes


## Finds a Graph Node by ID.
## Example: graph_view.find_node_by_id("2")
func find_node_by_id(id: String) -> Variant:
	for _child: Node in get_children():
		if _child is ParleyGraphNode:
			var child: ParleyGraphNode = _child
			if child.id == id:
				return child
	return null


func _generate_dialogue_nodes() -> void:
	var graph_nodes: Dictionary = {}
	if not ast:
		return
	for ast_node: ParleyNodeAst in ast.nodes.filter(func(n: ParleyNodeAst) -> bool: return n.type == ParleyDialogueSequenceAst.Type.GROUP):
		_add_node(graph_nodes, ast_node)
	for ast_node: ParleyNodeAst in ast.nodes.filter(func(n: ParleyNodeAst) -> bool: return n.type != ParleyDialogueSequenceAst.Type.GROUP):
		_add_node(graph_nodes, ast_node)

	generate_edges(graph_nodes)


func _add_node(graph_nodes: Dictionary, ast_node: ParleyNodeAst) -> void:
	var current_graph_node: ParleyGraphNode
	if graph_nodes.has(ast_node.id):
		current_graph_node = graph_nodes[ast_node.id]
	if not current_graph_node:
		current_graph_node = _register_node(ast_node)
		graph_nodes[ast_node.id] = current_graph_node


func generate_edges(graph_nodes: Dictionary = {}) -> void:
	clear_connections()
	var nodes: Dictionary
	if graph_nodes.size() == 0:
		for child: Node in get_children():
			if child is ParleyGraphNode:
				var parley_graph_node: ParleyGraphNode = child
				nodes[parley_graph_node.id] = parley_graph_node
	else:
		nodes = graph_nodes

	for edge: ParleyEdgeAst in ast.edges:
#		TODO: this doesn't check if a slot exists, this will need sorting otherwise: big bugs people
		if nodes.has(edge.from_node) and nodes.has(edge.to_node):
			var from_node: ParleyGraphNode = nodes[edge.from_node]
			var to_node: ParleyGraphNode = nodes[edge.to_node]
			var _connected: int = connect_node(from_node.name, edge.from_slot, to_node.name, edge.to_slot)
			# TODO: handle ^
			set_edge_colour(edge)


func add_edge(edge: ParleyEdgeAst, from_node_name: StringName, to_node_name: StringName) -> void:
	var _connected: int = connect_node(from_node_name, edge.from_slot, to_node_name, edge.to_slot)
	# TODO: handle ^
	set_edge_colour(edge)


func set_edge_colour(edge: ParleyEdgeAst) -> void:
	var nodes: Array[ParleyGraphNode] = get_nodes_for_edge(edge)
	if nodes.size() != 2:
		push_error(ParleyUtils.log.error_msg("Invalid edge, expected 2 nodes but found %d" % nodes.size()))
		return
	var from_node_index: int = nodes.find_custom(func(n: ParleyGraphNode) -> bool: return n.id == edge.from_node)
	var to_node_index: int = nodes.find_custom(func(n: ParleyGraphNode) -> bool: return n.id == edge.to_node)
	if from_node_index == -1:
		push_error(ParleyUtils.log.error_msg("Unable to get from node for edge"))
		return
	if to_node_index == -1:
		push_error(ParleyUtils.log.error_msg("Unable to get from node for edge"))
		return
	var from_node: ParleyGraphNode = nodes[from_node_index]
	var to_node: ParleyGraphNode = nodes[to_node_index]
	if edge.should_override_colour:
		from_node.deselect_from_slot(edge.from_slot, edge.colour_override)
	else:
		from_node.deselect_from_slot(edge.from_slot)
	var from_node_colour: Color = from_node.get_from_slot_colour(edge.from_slot)
	to_node.unselect_to_slot(edge.to_slot, from_node_colour)
#endregion

#region UTILS
func get_ast_node_name(ast_node: ParleyNodeAst) -> String:
	return "%s-%s" % [str(ParleyDialogueSequenceAst.Type.find_key(ast_node.type)), ast_node.id.replace(ParleyNodeAst.id_prefix, '')]


func _goto_node(node: ParleyGraphNode) -> void:
	scroll_offset = (node.position_offset + node.size * 0.5) * zoom - size * 0.5
#endregion

#region NODES
func _create_dialogue_node(ast_node: ParleyDialogueNodeAst) -> ParleyGraphNode:
	var node: ParleyDialogueNode = dialogue_node_scene.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	node.character = character_store.get_character_by_ref(ast_node.character).name
	node.dialogue = ast_node.text
	return node


func _create_dialogue_option_node(ast_node: ParleyDialogueOptionNodeAst) -> ParleyGraphNode:
	var node: ParleyDialogueOptionNode = dialogue_option_node_scene.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	node.character = character_store.get_character_by_ref(ast_node.character).name
	node.option = ast_node.text
	return node


func _create_action_node(ast_node: ParleyActionNodeAst) -> ParleyGraphNode:
	var node: ParleyActionNode = action_node_scene.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	node.description = ast_node.description
	node.action_type = ast_node.action_type
	node.action_script_name = action_store.get_action_by_ref(ast_node.action_script_ref).name
	node.values = ast_node.values
	return node


func _create_match_node(ast_node: ParleyMatchNodeAst) -> ParleyGraphNode:
	var node: ParleyMatchNode = match_node_scene.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	node.description = ast_node.description
	node.fact_name = fact_store.get_fact_by_ref(ast_node.fact_ref).name
	var cases: Array[Variant] = []
	for case: Variant in ast_node.cases:
		cases.append(case)
	node.cases = cases
	return node


func _create_start_node(ast_node: ParleyStartNodeAst) -> ParleyGraphNode:
	var node: ParleyStartNode = start_node_scene.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	return node


func _create_end_node(ast_node: ParleyEndNodeAst) -> ParleyGraphNode:
	var node: ParleyEndNode = end_node_scene.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	return node


func _create_group_node(ast_node: ParleyGroupNodeAst, _should_regenerate: bool = false) -> ParleyGraphNode:
	var node: ParleyGroupNode = group_node_scene.instantiate()
	node.id = ast_node.id
	node.group_name = ast_node.name if ast_node.name else get_ast_node_name(ast_node)
	node.size = ast_node.size
	node.colour = ast_node.colour
	node.node_ids = ast_node.node_ids
	# TODO: v. bad to change ast stuff here - refactor to avoid horrible bugs
	ParleyUtils.signals.safe_connect(node.resize_end, func(new_size: Vector2) -> void:
		# TODO: should this really be done here?
		node.size = new_size
		ast_node.size = new_size
		var _nodes: Array[ParleyGraphNode] = _update_nodes_covered_by_group_node(node, ast_node)
	)
	# TODO: bad to change ast stuff here - refactor to avoid horrible bugs
	ParleyUtils.signals.safe_connect(node.node_deselected, func() -> void:
		var _nodes: Array[ParleyGraphNode] = _update_nodes_covered_by_group_node(node, ast_node)
		# This is to ensure that the sub nodes
		# are always selectable within the group node
		await generate()
	)
	# TODO: bad to change ast stuff here - refactor to avoid horrible bugs
	ParleyUtils.signals.safe_connect(node.node_selected, func() -> void:
		var _nodes: Array[ParleyGraphNode] = _update_nodes_covered_by_group_node(node, ast_node)
	)
	# TODO: bad to change ast stuff here - refactor to avoid horrible bugs
	# EXPERIMENTAL: see how feedback goes. This is certainly a candidate to be put into settings
	ParleyUtils.signals.safe_connect(node.dragged, func(_from: Vector2, _to: Vector2) -> void:
		var _nodes: Array[ParleyGraphNode] = _update_nodes_covered_by_group_node(node, ast_node)
	)
	return node


func _create_condition_node(ast_node: ParleyConditionNodeAst) -> ParleyGraphNode:
	var node: ParleyConditionNode = condition_node_scene.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	node.description = ast_node.description
	return node


func _create_jump_node(ast_node: ParleyJumpNodeAst) -> ParleyGraphNode:
	var node: ParleyJumpNode = jump_node_scene.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	if ResourceLoader.exists(ast_node.dialogue_sequence_ast_ref):
		node.dialogue_sequence_ast = load(ast_node.dialogue_sequence_ast_ref)
	return node


## Get nodes for an edge AST
## Example: get_nodes_for_edge(edge)
func get_nodes_for_edge(edge: ParleyEdgeAst) -> Array[ParleyGraphNode]:
	var nodes: Array[ParleyGraphNode] = []
	for node: Node in get_children():
		if node is ParleyGraphNode:
			var parley_graph_node: ParleyGraphNode = node
			if [edge.from_node, edge.to_node].has(parley_graph_node.id):
				nodes.append(parley_graph_node)
	return nodes


func set_selected_by_id(id: String, _goto: bool = true) -> void:
	for node: Node in get_children():
		if node is ParleyGraphNode and (node as ParleyGraphNode).id == id:
			set_selected(node)
			_goto_node(node as ParleyGraphNode)
			return
#endregion
