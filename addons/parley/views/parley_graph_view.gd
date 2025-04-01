@tool
# TODO: prefix with Parley
class_name ParleyGraphView extends GraphEdit

@export var ast: DialogueAst

#region SETUP
var DialogueNode = preload("../components/dialogue/dialogue_node.tscn")
var DialogueOptionNode = preload("../components/dialogue_option/dialogue_option_node.tscn")
var ActionNode = preload("../components/action/action_node.tscn")
var ConditionNode = preload("../components/condition/condition_node.tscn")
var MatchNode = preload("../components/match/match_node.tscn")
var StartNode = preload("../components/start/start_node.tscn")
var EndNode = preload("../components/end/end_node.tscn")
var GroupNode = preload("../components/group/group_node.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await clear()
	scroll_offset = Vector2(-50, -50)


func _exit_tree() -> void:
	await clear()


func generate(arrange: bool = false) -> void:
	await clear()
	await _generate_dialogue_nodes()
	if arrange:
		arrange_nodes()


func clear():
	clear_connections()
	var children: Array[ParleyGraphNode] = []
	for child in get_children():
		if child is ParleyGraphNode:
			child.queue_free()
			children.append(child)
	for child in children:
		await child.tree_exited
#endregion

#region GENERATE COMPONENTS
func _register_node(ast_node: NodeAst) -> ParleyGraphNode:
	var type: DialogueAst.Type = ast_node.type
	var graph_node: ParleyGraphNode
	match type:
		DialogueAst.Type.DIALOGUE:
			graph_node = _create_dialogue_node(ast_node)
		DialogueAst.Type.DIALOGUE_OPTION:
			graph_node = _create_dialogue_option_node(ast_node)
		DialogueAst.Type.CONDITION:
			graph_node = _create_condition_node(ast_node)
		DialogueAst.Type.MATCH:
			graph_node = _create_match_node(ast_node)
		DialogueAst.Type.ACTION:
			graph_node = _create_action_node(ast_node)
		DialogueAst.Type.START:
			graph_node = _create_start_node(ast_node)
		DialogueAst.Type.END:
			graph_node = _create_end_node(ast_node)
		DialogueAst.Type.GROUP:
			graph_node = _create_group_node(ast_node)
		_:
			print("PARLEY_DBG: AST Node {type} is not supported".format({"type": type}))
			return
	var ast_node_id: String = ast_node.id
	# TODO: v. bad to change ast stuff here - refactor to avoid horrible bugs
	graph_node.position_offset_changed.connect(func():
		if ast_node.type == DialogueAst.Type.GROUP:
			var diff: Vector2 = graph_node.position_offset - ast_node.position
			var nodes: Array[ParleyGraphNode] = _get_nodes_by_ids(graph_node.node_ids)
			for sub_node in nodes:
				sub_node.position_offset = sub_node.position_offset + diff
				# TODO: should do this via a signal
				ast.update_node_position(sub_node.id, sub_node.position_offset)
		# TODO: should do this via a signal
		ast.update_node_position(ast_node_id, graph_node.position_offset))
	graph_node.position_offset = ast_node.position
	add_child(graph_node)
	return graph_node


# TODO: v. bad to change ast stuff here - refactor to avoid horrible bugs
func _update_nodes_covered_by_group_node(group_node: GroupNode, group_node_ast: GroupNodeAst) -> Array[ParleyGraphNode]:
	var nodes: Array[ParleyGraphNode] = []
	for child in get_children():
		if child is ParleyGraphNode and child.id != group_node.id:
			var is_within_horizontal = child.position_offset.x >= group_node.position_offset.x and child.position_offset.x <= (group_node.position_offset + group_node.size).x
			var is_within_vertical = child.position_offset.y >= group_node.position_offset.y and child.position_offset.y <= (group_node.position_offset + group_node.size).y
			if is_within_horizontal and is_within_vertical:
				nodes.append(child)
	var new_node_ids: Array = nodes.map(func(n): return n.id)
	group_node.node_ids = new_node_ids
	# TODO: should do this via a signal at the main panel level
	# so the editor can also be changed at the same time
	new_node_ids.sort()
	group_node_ast.node_ids = new_node_ids
	return nodes


func _get_nodes_by_ids(ids: Array) -> Array[ParleyGraphNode]:
	var nodes: Array[ParleyGraphNode] = []
	for child in get_children():
		if child is ParleyGraphNode and ids.has(child.id):
			nodes.append(child)
	return nodes


## Finds a Graph Node by ID.
## Example: graph_view.find_node_by_id("2")
func find_node_by_id(id: String) -> ParleyGraphNode:
	for child in get_children():
		if child is ParleyGraphNode and child.id == id:
			return child
	return null


func _generate_dialogue_nodes() -> void:
	var graph_nodes: Dictionary = {}
	if not ast:
		return
	for ast_node in ast.nodes.filter(func(n): return n.type == DialogueAst.Type.GROUP):
		_add_node(graph_nodes, ast_node)
	for ast_node in ast.nodes.filter(func(n): return n.type != DialogueAst.Type.GROUP):
		_add_node(graph_nodes, ast_node)

	generate_edges(graph_nodes)


func _add_node(graph_nodes: Dictionary, ast_node: NodeAst) -> void:
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
		for child in get_children():
			if child is ParleyGraphNode:
				nodes[child.id] = child
	else:
		nodes = graph_nodes

	for edge in ast.edges:
#		TODO: this doesn't check if a slot exists, this will need sorting otherwise: big bugs people
		if nodes.has(edge.from_node) and nodes.has(edge.to_node):
			var from_node: ParleyGraphNode = nodes[edge.from_node]
			var to_node: ParleyGraphNode = nodes[edge.to_node]
			connect_node(from_node.name, edge.from_slot, to_node.name, edge.to_slot)
#endregion

#region UTILS
func get_ast_node_name(ast_node: NodeAst) -> String:
	return "%s-%s" % [str(DialogueAst.Type.find_key(ast_node.type)), ast_node.id]
#endregion

#region NODES
func _create_dialogue_node(ast_node: DialogueNodeAst) -> ParleyGraphNode:
	var node: DialogueNode = DialogueNode.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	node.character = ast_node.character
	node.dialogue = ast_node.text
	return node


func _create_dialogue_option_node(ast_node: DialogueOptionNodeAst) -> ParleyGraphNode:
	var node: DialogueOptionNode = DialogueOptionNode.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	node.character = ast_node.character
	node.option = ast_node.text
	return node


func _create_action_node(ast_node: ActionNodeAst) -> ParleyGraphNode:
	var node: ActionNode = ActionNode.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	node.description = ast_node.description
	node.action_type = ast_node.action_type
	node.action_script_name = ParleyManager.action_store.get_action_by_ref(ast_node.action_script_ref).name
	node.values = ast_node.values
	return node


func _create_match_node(ast_node: MatchNodeAst) -> ParleyGraphNode:
	var node: MatchNode = MatchNode.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	node.description = ast_node.description
	node.fact_name = ParleyManager.fact_store.get_fact_by_ref(ast_node.fact_ref).name
	var cases: Array[Variant] = []
	for case: Variant in ast_node.cases:
		cases.append(case)
	node.cases = cases
	return node


func _create_start_node(ast_node: StartNodeAst) -> ParleyGraphNode:
	var node: StartNode = StartNode.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	return node


func _create_end_node(ast_node: EndNodeAst) -> ParleyGraphNode:
	var node: EndNode = EndNode.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	return node


func _create_group_node(ast_node: GroupNodeAst, should_regenerate: bool = false) -> ParleyGraphNode:
	var node: GroupNode = GroupNode.instantiate()
	node.id = ast_node.id
	node.group_name = ast_node.name if ast_node.name else get_ast_node_name(ast_node)
	node.size = ast_node.size
	node.colour = ast_node.colour
	node.node_ids = ast_node.node_ids
	# TODO: v. bad to change ast stuff here - refactor to avoid horrible bugs
	node.resize_end.connect(func(new_size: Vector2):
		# TODO: should this really be done here?
		node.size = new_size
		ast_node.size = new_size
		_update_nodes_covered_by_group_node(node, ast_node)
	)
	# TODO: v. bad to change ast stuff here - refactor to avoid horrible bugs
	node.node_deselected.connect(func():
		var nodes = _update_nodes_covered_by_group_node(node, ast_node)
		# This is to ensure that the sub nodes
		# are always selectable within the group node
		await generate()
	)
	# TODO: v. bad to change ast stuff here - refactor to avoid horrible bugs
	node.node_selected.connect(func():
		_update_nodes_covered_by_group_node(node, ast_node)
	)
	# TODO: v. bad to change ast stuff here - refactor to avoid horrible bugs
	# EXPERIMENTAL: see how feedback goes. This is certainly a candidate to be put into settings
	node.dragged.connect(func(from: Vector2, to: Vector2):
		_update_nodes_covered_by_group_node(node, ast_node)
	)
	return node


func _create_condition_node(ast_node: ConditionNodeAst) -> ParleyGraphNode:
	var node: ConditionNode = ConditionNode.instantiate()
	node.id = ast_node.id
	node.name = get_ast_node_name(ast_node)
	node.description = ast_node.description
	return node


## Get nodes for an edge AST
## Example: get_nodes_for_edge(edge)
func get_nodes_for_edge(edge: EdgeAst) -> Array[ParleyGraphNode]:
	var nodes: Array[ParleyGraphNode] = []
	for node in get_children():
		if node is ParleyGraphNode:
			if [edge.from_node, edge.to_node].has(node.id):
				nodes.append(node)
	return nodes


func set_selected_by_id(id: String, goto: bool = true) -> void:
	for node in get_children():
		if node is ParleyGraphNode and node.id == id:
			set_selected(node)
			_goto_node(node)
			return
#endregion

func _goto_node(node: ParleyGraphNode) -> void:
	scroll_offset = (node.position_offset + node.size * 0.5) * zoom - size * 0.5


# TODO: remove
#var lines = {
  #"1": { "id": "1", "next_id": "2", "type": "title", "text": "demo" },
  #"2": {
	#"id": "2",
	#"next_id": "4",
	#"notes": "",
	#"type": "dialogue",
	#"tags": [],
	#"character": "Narrator",
	#"character_replacements": [],
	#"text": "But he stands before you, just the same. Waiting; fixing you in his glare.",
	#"text_replacements": [],
	#"translation_key": "But he stands before you, just the same. Waiting; fixing you in his glare."
  #},
  #"4": {
	#"id": "4",
	#"next_id": "5",
	#"notes": "",
	#"type": "response",
	#"tags": [],
	#"character": "",
	#"character_replacements": [],
	#"text": "You're alive, too. And you look the same.",
	#"responses": ["4", "9", "12"],
	#"next_id_after": "14",
	#"text_replacements": [],
	#"translation_key": "You're alive, too. And you look the same."
  #},
  #"5": {
	#"id": "5",
	#"next_id": "6",
	#"parent_id": "4",
	#"notes": "",
	#"type": "dialogue",
	#"tags": [],
	#"character": "Player",
	#"character_replacements": [],
	#"text": "I assure you, I am not the same. And neither are you.",
	#"text_replacements": [],
	#"translation_key": "I assure you, I am not the same. And neither are you."
  #},
  #"6": {
	#"id": "6",
	#"next_id": "7",
	#"parent_id": "4",
	#"notes": "",
	#"type": "dialogue",
	#"tags": [],
	#"character": "Nathan",
	#"character_replacements": [],
	#"text": "I know we lost. At Brenna.",
	#"text_replacements": [],
	#"translation_key": "I know we lost. At Brenna."
  #},
  #"7": {
	#"id": "7",
	#"next_id": "14",
	#"parent_id": "4",
	#"notes": "",
	#"type": "dialogue",
	#"tags": [],
	#"character": "Player",
	#"character_replacements": [],
	#"text": "We?",
	#"text_replacements": [],
	#"translation_key": "We?"
  #},
  #"9": {
	#"id": "9",
	#"next_id": "10",
	#"notes": "",
	#"type": "response",
	#"tags": [],
	#"character": "",
	#"character_replacements": [],
	#"text": "I don't know what to say.",
	#"next_id_after": "14",
	#"text_replacements": [],
	#"translation_key": "I don't know what to say."
  #},
  #"10": {
	#"id": "10",
	#"next_id": "14",
	#"parent_id": "9",
	#"notes": "",
	#"type": "dialogue",
	#"tags": [],
	#"character": "Nathan",
	#"character_replacements": [],
	#"text": "2",
	#"text_replacements": [],
	#"translation_key": "2"
  #},
  #"12": {
	#"id": "12",
	#"next_id": "13",
	#"notes": "",
	#"type": "response",
	#"tags": [],
	#"character": "",
	#"character_replacements": [],
	#"text": "Say nothing.",
	#"next_id_after": "14",
	#"text_replacements": [],
	#"translation_key": "Say nothing."
  #},
  #"13": {
	#"id": "13",
	#"next_id": "14",
	#"parent_id": "12",
	#"notes": "",
	#"type": "dialogue",
	#"tags": [],
	#"character": "Nathan",
	#"character_replacements": [],
	#"text": "3",
	#"text_replacements": [],
	#"translation_key": "3"
  #},
  #"14": { "id": "14", "next_id": "end", "type": "goto", "is_snippet": false }
#}
