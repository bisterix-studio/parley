# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyDialogueSequenceAst extends Resource


## The title of the Dialogue Sequence AST
@export var title: String


### The edges of the Dialogue Sequence AST
@export var edges: Array[ParleyEdgeAst]


## The nodes of the Dialogue Sequence AST
@export var nodes: Array[ParleyNodeAst]


# TODO: for some reason removing this field creates a memory leak in the tests. Keep for now
# and do nothing with it and don't expose it to the user
## The stores of the Dialogue Sequence AST
var stores: StoresAst


## The type name of the Dialogue Sequence AST
const type_name: String = "ParleyDialogueSequenceAst"


## The type of the Dialogue AST Node
## Example: "DialogueAstNodeType.DIALOGUE"
enum Type {DIALOGUE, DIALOGUE_OPTION, CONDITION, ACTION, START, END, GROUP, MATCH, UNKNOWN}


var is_ready: bool = false


# TODO: add types here. However it may be causing circular dep issues
signal dialogue_updated(new_dialogue_ast: Variant)
signal dialogue_ended(dialogue_ast: Variant)


func _init(_title: String = "", _nodes: Array = [], _edges: Array = []) -> void:
	title = _title
	# TODO: add validation to ensure IDs are globally unique within the context of the dialogue
	for node: Dictionary in _nodes:
		add_ast_node(node)
	for edge: Dictionary in _edges:
		add_ast_edge(edge)
	is_ready = true


#region BUILDING DIALOGUE
## Add a node to the list of nodes from an AST
func add_ast_node(node: Dictionary) -> void:
	var type: Type = Type.get(node.get('type'), Type.UNKNOWN)
	var id_variant: Variant = node.get('id')
	var position: Vector2 = _parse_position_from_raw_node_ast(node)
	if not id_variant or not is_instance_of(id_variant, TYPE_STRING):
		ParleyUtils.log.error("Unable to import Parley AST Node without a valid string id field: %s" % [id_variant])
		return
	var ast_node: ParleyNodeAst
	var id: String = id_variant
	match type:
		Type.DIALOGUE:
			var character: String = node.get('character', '')
			var text: String = node.get('text', '')
			ast_node = ParleyDialogueNodeAst.new(id, position, character, text)
		Type.DIALOGUE_OPTION:
			var character: String = node.get('character', '')
			var text: String = node.get('text', '')
			ast_node = ParleyDialogueOptionNodeAst.new(id, position, character, text)
		Type.CONDITION:
			var combiner: ParleyConditionNodeAst.Combiner = ParleyConditionNodeAst.Combiner.get(node.get('combiner'), ParleyConditionNodeAst.Combiner.ALL)
			var description: String = node.get('description', '')
			var conditions: Array = node.get('conditions', [])
			ast_node = ParleyConditionNodeAst.new(id, position, description, combiner, conditions)
		Type.MATCH:
			var description: String = node.get('description', '')
			var fact_ref: String = node.get('fact_ref', '')
			var cases: Array = node.get('cases', [])
			ast_node = ParleyMatchNodeAst.new(id, position, description, fact_ref, cases)
		Type.ACTION:
			var description: String = node.get('description', '')
			var action_type_key: String = node.get('action_type', 'SCRIPT')
			var action_type: ParleyActionNodeAst.ActionType = ParleyActionNodeAst.ActionType.get(action_type_key, ParleyActionNodeAst.ActionType.SCRIPT)
			var action_script_ref: String = node.get('action_script_ref', '')
			var values: Array = node.get('values', [])
			ast_node = ParleyActionNodeAst.new(id, position, description, action_type, action_script_ref, values)
		Type.START:
			ast_node = ParleyStartNodeAst.new(id, position)
		Type.END:
			ast_node = ParleyEndNodeAst.new(id, position)
		Type.GROUP:
			var colour: Color = _parse_colour(node)
			var size: Vector2 = _parse_group_size_from_raw_node_ast(node)
			var name: String = node.get('name', '')
			var node_ids: Array = node.get('node_ids', [])
			ast_node = ParleyGroupNodeAst.new(id, position, name, node_ids, colour, size)
		_:
			ParleyUtils.log.error("Unable to import Parley AST node of type: %s" % [type])
			return
	ast_node.position = position
	nodes.push_back(ast_node)


## Add a new node to the list of nodes
func add_new_node(type: Type, position: Vector2 = Vector2.ZERO) -> ParleyNodeAst:
	ParleyUtils.log.info('Inserting new Node into the AST of type: %s' % [type])
	var new_id: String = _generate_node_id()
	var ast_node: ParleyNodeAst
	match type:
		Type.DIALOGUE:
			ast_node = ParleyDialogueNodeAst.new(new_id, position)
		Type.DIALOGUE_OPTION:
			ast_node = ParleyDialogueOptionNodeAst.new(new_id, position)
		Type.CONDITION:
			ast_node = ParleyConditionNodeAst.new(new_id, position)
		Type.MATCH:
			ast_node = ParleyMatchNodeAst.new(new_id, position)
		Type.ACTION:
			ast_node = ParleyActionNodeAst.new(new_id, position)
		Type.START:
			ast_node = ParleyStartNodeAst.new(new_id, position)
		Type.END:
			ast_node = ParleyEndNodeAst.new(new_id, position)
		Type.GROUP:
			ast_node = ParleyGroupNodeAst.new(new_id, position)
		_:
			ParleyUtils.log.error("Unable to create new Parley AST node of type: %s" % [type])
			return null
	nodes.push_back(ast_node)
	_emit_dialogue_updated()
	return ast_node


## Update Node AST position
func update_node_position(ast_node_id: String, position: Vector2) -> void:
	for node: ParleyNodeAst in nodes:
		if node.id == ast_node_id:
			node.position = position
			break
	_emit_dialogue_updated()


## Add an edge to the list of edges from an AST
func add_ast_edge(edge: Dictionary) -> void:
	var id_variant: Variant = edge.get('id')
	if id_variant:
		if not is_instance_of(id_variant, TYPE_STRING):
			ParleyUtils.log.error("Unable to import Parley AST Edge without a valid string id field: %s" % [id_variant])
			return
	else:
		id_variant = _generate_edge_id()
	# TODO: add validation before instantiation to ensure that
	# all values are defined
	var edge_id: String = id_variant
	var from_node: String = edge.get('from_node')
	var from_slot: int = edge.get('from_slot')
	var to_node: String = edge.get('to_node')
	var to_slot: int = edge.get('to_slot')
	var should_override_colour: bool = edge.get('should_override_colour', false)
	var colour_override: Color = _parse_colour(edge, 'colour_override', ParleyEdgeAst.default_colour_override)
	var edge_ast: ParleyEdgeAst = ParleyEdgeAst.new(edge_id, from_node, from_slot, to_node, to_slot, should_override_colour, colour_override)

	edges.append(edge_ast)


## Add a new edge to the list of edges. It will not add an edge if it already exists
## It returns the number of edges added (1 or 0).
## dialogue_ast.add_edge("1", 0, "2", 1)
func add_new_edge(from_node: String, from_slot: int, to_node: String, to_slot: int, emit: bool = true) -> ParleyEdgeAst:
	var new_id: String = _generate_edge_id()
	var new_edge: ParleyEdgeAst = ParleyEdgeAst.new(
		new_id,
		from_node,
		from_slot,
		to_node,
		to_slot,
	)
	var existing_edges: Array[ParleyEdgeAst] = edges.filter(func(edge: ParleyEdgeAst) -> bool:
		return (
			edge.from_node == new_edge.from_node and
			edge.from_slot == new_edge.from_slot and
			edge.to_node == new_edge.to_node and
			edge.to_slot == new_edge.to_slot
		)
	)
	var has_existing_edge: bool = existing_edges.size() > 0
	if not has_existing_edge:
		edges.push_back(new_edge)
		if emit:
			_emit_dialogue_updated()
	return new_edge if not has_existing_edge else null


## Remove edges to the list of edges.
## It returns the number of edges added.
## dialogue_ast.add_edges([ParleyEdgeAst("1", 0, "2", 1).new()])
func add_edges(edges_to_create: Array[ParleyEdgeAst], emit: bool = true) -> int:
	var added: int = 0
	for edge: ParleyEdgeAst in edges_to_create:
		var added_edge: ParleyEdgeAst = add_new_edge(edge.from_node, edge.from_slot, edge.to_node, edge.to_slot, false)
		if added_edge:
			added += 1
	if added > 0 and emit:
		_emit_dialogue_updated()
	return added


# TODO: also remove edges if there are any
## Remove a node from the list of nodes
func remove_node(node_id: String) -> void:
	var index: int = 0
	var removed: bool = false
	for node: ParleyNodeAst in nodes:
		if node.id == node_id:
			nodes.remove_at(index)
			removed = true
			break
		index += 1
	if not removed:
		ParleyUtils.log.info("Unable to remove node with ID: %s" % [node_id])
		return
	index = 0
	for edge: ParleyEdgeAst in edges:
		if edge.from_node == node_id or edge.to_node == node_id:
			edges.remove_at(index)
		index += 1

	_emit_dialogue_updated()


## Find a Node AST by its ID.
## Example: ast.find_node_by_id("1")
func find_node_by_id(id: String) -> ParleyNodeAst:
	var filtered_nodes: Array = nodes.filter(func(node: ParleyNodeAst) -> bool: return str(node.id) == str(id))
	if filtered_nodes.size() != 1:
		ParleyUtils.log.info("No AST Node found with ID: {id}".format({'id': id}))
		return null
	return filtered_nodes.front()


## Get nodes by types
## Example: get_nodes_by_types([type])
func find_nodes_by_types(types: Array[ParleyDialogueSequenceAst.Type]) -> Array[ParleyNodeAst]:
	var filtered_nodes: Array[ParleyNodeAst] = []
	for node_ast: ParleyNodeAst in nodes:
		if types.has(node_ast.type):
			filtered_nodes.append(node_ast)
	return filtered_nodes


## Remove an edge from the list of edges. It will log an error if an edge does not exist
## It returns the number of edges removed (1 or 0).
## dialogue_ast.remove_edge("1", 0, "2", 1)
func remove_edge(from_node: String, from_slot: int, to_node: String, to_slot: int, emit: bool = true) -> int:
	var index: int = 0
	var removed: bool = false
	for edge: ParleyEdgeAst in edges:
		if (edge.from_node == from_node and
			edge.from_slot == from_slot and
			edge.to_node == to_node and
			edge.to_slot == to_slot):
			edges.remove_at(index)
			removed = true
			break
		index += 1
	if not removed:
		ParleyUtils.log.info("Unable to remove edge: (%s|%s)=>(%s|%s)" % [from_node, from_slot, to_node, to_slot])
	if removed and emit:
		_emit_dialogue_updated()
	return 1 if removed else 0


## Remove edges from the list of edges.
## It returns the number of edges removed.
## dialogue_ast.remove_edges([ParleyEdgeAst("1", 0, "2", 1).new()])
func remove_edges(edges_to_remove: Array[ParleyEdgeAst], emit: bool = true) -> int:
	var removed: int = 0
	for edge: ParleyEdgeAst in edges_to_remove:
		removed += remove_edge(edge.from_node, edge.from_slot, edge.to_node, edge.to_slot, false)
	if removed > 0 and emit:
		_emit_dialogue_updated()
	return removed
#endregion


#region DIALOGUE RUNTIME
# TODO: make context a class that can be extended
## Get the next node that can be rendered and perform any necessary processing
func process_next(ctx: Dictionary, current_node: ParleyNodeAst = null, dry_run: bool = false) -> Array[ParleyNodeAst]:
	if not current_node:
		var start_node: Variant = _get_start_node(dry_run)
		if not start_node:
			return []
		current_node = start_node
		
	var id: String = current_node.id
	# TODO: this won't work for conditionals, need to account for multiple slots
	var next_edges: Array[ParleyEdgeAst] = edges.filter(func(edge: ParleyEdgeAst) -> bool: return str(edge.from_node) == id)
	# TODO: the Dialogue AST should have a generate new unique ID function
	if next_edges.size() == 0:
		return _process_end(dry_run)
	var next_nodes: Array[ParleyNodeAst] = []
	var condition_result: bool
	var match_result: int
	if current_node.type == Type.CONDITION:
		var condition_node: ParleyConditionNodeAst = current_node
		condition_result = _process_condition_node(ctx, condition_node, dry_run)
	if current_node.type == Type.MATCH:
		var match_node: ParleyMatchNodeAst = current_node
		match_result = _process_match_node(ctx, match_node)
	
	for next_edge: ParleyEdgeAst in next_edges:
		if current_node.type == Type.CONDITION:
			var next_slot: int = 0 if condition_result else 1
			if next_edge.from_slot != next_slot:
				continue
		
		# TODO: maybe check if match_result is within a valid next_edge
		if current_node.type == Type.MATCH and match_result is int:
			if next_edge.from_slot != match_result:
				continue

		var next_id: String = str(next_edge.to_node)
		# TODO: warn when multiple nodes are found for the edge
		var filtered_next_nodes: Array = nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == next_id)
		if filtered_next_nodes.size() == 0:
			ParleyUtils.log.warn('Node: {id} not found for Edge: {edge}'.format({'id': next_id, 'edge': next_edge}), dry_run)
			continue
		var next_node: ParleyNodeAst = filtered_next_nodes.front()
		var next_type: Type = next_node.type
		match next_type:
			Type.DIALOGUE:
				next_nodes.append(next_node)
			Type.DIALOGUE_OPTION:
				next_nodes.append(next_node)
			Type.ACTION:
				if not dry_run:
					_run_action(next_node, ctx)
				next_nodes.append_array(process_next(ctx, next_node, dry_run))
			Type.CONDITION:
				next_nodes.append_array(process_next(ctx, next_node, dry_run))
			Type.MATCH:
				next_nodes.append_array(process_next(ctx, next_node, dry_run))
			Type.START:
				next_nodes.append(next_node)
			Type.END:
				next_nodes.append(next_node)
			_:
				ParleyUtils.log.warn("AST Node {type} is not supported".format({"type": next_type}), dry_run)
				continue
	
	var types: Array[Type] = []
	# TODO: check for multiple of Dialogue
	# TODO: check for multiple of End
	for next_node: ParleyNodeAst in next_nodes:
		var type: Type = next_node.type
		if type not in types:
			types.append(type)

	if types.size() == 0:
		# Add this check here to ensure that conditions behave like guards
		if current_node.type == Type.CONDITION:
			return []
		ParleyUtils.log.info("No AST Node types found for Dialogue tree: {types}".format({"types": types}), dry_run)
		return _process_end(dry_run)


	if types.size() > 1:
		ParleyUtils.log.info("Multiple AST Node types found for Dialogue tree: {types}".format({"types": types}), dry_run)
		return _process_end(dry_run)

	if is_instance_of(next_nodes.front(), ParleyEndNodeAst):
		var _end: Array[ParleyNodeAst] = _process_end(dry_run) # Don't return as we want to use the existing End Node ID
	next_nodes.sort_custom(_sort_by_y_position)
	return next_nodes


# TODO: make this async/await
func _run_action(node_ast: ParleyNodeAst, ctx: Dictionary) -> void:
	if node_ast is not ParleyActionNodeAst:
		ParleyUtils.log.error("Action Node to execute is not an Action Node (node:%s)" % node_ast)
		return
	var action_node_ast: ParleyActionNodeAst = node_ast
	var action: ParleyActionInterface
	match action_node_ast.action_type:
		ParleyActionNodeAst.ActionType.SCRIPT:
			var action_script: GDScript = load(action_node_ast.action_script_ref)
			if action_script is not GDScript:
				ParleyUtils.log.error("Action Script reference is not a valid GDScript (node:%s, script:%s)" % [node_ast, action_script])
				return
			action = action_script.new()
		_:
			ParleyUtils.log.error("Action Node to execute has an unknown Action Type (node:%s)" % node_ast)
			return
	if action is not ParleyActionInterface or not action.has_method(&"execute"):
		ParleyUtils.log.error("Action to execute is not a valid action interface (node:%sm, action:%s)" % [node_ast, action])
		return
	var result: int = action.execute(ctx, action_node_ast.values)
	action.free()
	if result != OK:
		ParleyUtils.log.error("Unable to execute Action (code:%i)" % result)


# TODO: make context a class that can be extended
## Indicator for whether the node is at the end of the current Dialogue Sequence
func is_at_end(ctx: Dictionary, current_node: ParleyNodeAst) -> bool:
	# Perform a dry run to infer whether we are at the final node
	var next_nodes: Array[ParleyNodeAst] = process_next(ctx, current_node, true)
	if next_nodes.size() == 1 and next_nodes.front() is ParleyEndNodeAst:
		return true
	return false


func _process_condition_node(ctx: Dictionary, condition_node: ParleyConditionNodeAst, dry_run: bool) -> bool:
	var combiner: ParleyConditionNodeAst.Combiner = condition_node.combiner
	var conditions: Array = condition_node.conditions
	var results: Array[bool] = []
	for condition_def: Dictionary in conditions:
		var fact_ref: String = condition_def.get('fact_ref')
		var operator: Variant = condition_def.get('operator')
		# TODO: evaluate this as an expression
		var value: Variant = condition_def.get('value')
		var script: GDScript = load(fact_ref)
		var fact: FactInterface = script.new()
		var result: Variant = fact.execute(ctx, [])
		fact.free() # Previous this was call_deferred, although I'm not sure why
		var evaluated_value: Variant = _evaluate_value(value)
		match operator:
			ParleyConditionNodeAst.Operator.EQUAL:
				results.append(typeof(result) == typeof(evaluated_value) and result == evaluated_value)
			ParleyConditionNodeAst.Operator.NOT_EQUAL:
				results.append(typeof(result) != typeof(evaluated_value) or result != _evaluate_value(value))
			_:
				ParleyUtils.log.info("Operator of type %s is not supported" % [operator], dry_run)
	if results.size() == 0:
		ParleyUtils.log.info("No results evaluated", dry_run)
		return false
	match combiner:
		ParleyConditionNodeAst.Combiner.ALL:
			return not results.has(false)
		ParleyConditionNodeAst.Combiner.ANY:
			return results.has(true)
		_:
			ParleyUtils.log.info("Combiner of type %s is not supported" % [combiner], dry_run)
			return false


func _process_match_node(ctx: Dictionary, match_node: ParleyMatchNodeAst) -> int:
	var fact_ref: String = match_node.fact_ref
	var script: GDScript = load(fact_ref)
	var fact: FactInterface = script.new()
	var result: Variant = fact.execute(ctx, [])
	fact.free() # Previous this was call_deferred, although I'm not sure why
	var evaluated_result: Variant = _evaluate_value(result)
	var cases: Array = match_node.cases
	var case_index: int = cases.map(func(case: Variant) -> Variant: return _map_value(case)).find(evaluated_result)
	if case_index == -1:
		return cases.find(ParleyMatchNodeAst.fallback_key)
	return case_index


func _evaluate_value(value_expr: Variant) -> Variant:
	# TODO: add evaluation here
	return _map_value(value_expr)


func _map_value(value_expr: Variant) -> Variant:
	if value_expr is String and value_expr == 'true':
		return true
	if value_expr is String and value_expr == 'false':
		return false
	if is_instance_of(value_expr, TYPE_INT):
		var value_int: int = value_expr
		return float(value_int)
	# TODO: this needs work for int and float values
	#var value: Variant = int(value_expr)
	#if int(value_expr):
		#return value
	#value = float(value_expr)
	#if not is_nan(value):
		#return value
	return value_expr


func _process_end(dry_run: bool) -> Array[ParleyNodeAst]:
	if not dry_run:
		dialogue_ended.emit(self)
	return [ParleyEndNodeAst.new(_generate_node_id())]


func _sort_by_y_position(a: ParleyNodeAst, b: ParleyNodeAst) -> bool:
	if a.position.y < b.position.y:
		return true
	return false


func _get_start_node(dry_run: bool) -> Variant:
	var filtered_nodes: Array[ParleyNodeAst] = nodes.filter(func(node: ParleyNodeAst) -> bool: return node.type == Type.START)
	if filtered_nodes.size() == 0:
		ParleyUtils.log.error("No Start Nodes found. Unable to start the Dialogue Sequence.", dry_run)
		return
	if filtered_nodes.size() > 1:
		ParleyUtils.log.error("Multiple Start Nodes found. Unable to start the Dialogue Sequence.", dry_run)
		return
	return filtered_nodes.front()
#endregion


#region HELPERS
## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	return {
		'title': title,
		'nodes': nodes.map(func(node: ParleyNodeAst) -> Dictionary: return node.to_dict()),
		'edges': edges.map(func(edge: ParleyEdgeAst) -> Dictionary: return edge.to_dict()),
	}


## Convert this resource into CSV lines
func to_csv_lines() -> Array[PackedStringArray]:
	# TODO: handle locales at scale
	var lines: Array[PackedStringArray] = [PackedStringArray(["id", "type", "character_en", "text_en"])]
	for node_ast: ParleyNodeAst in nodes:
		match node_ast.type:
			Type.DIALOGUE:
				var node: ParleyDialogueNodeAst = node_ast
				lines.append(PackedStringArray([node.id, get_type_name(node.type), node.character, node.text]))
			Type.DIALOGUE_OPTION:
				var node: ParleyDialogueOptionNodeAst = node_ast
				lines.append(PackedStringArray([node.id, get_type_name(node.type), node.character, node.text]))
			_:
				continue
	return lines


## Get colour for Dialogue AST type
## Example: ParleyDialogueSequenceAst.get_type_colour(type)
static func get_type_colour(type: Type) -> Color:
	match type:
		Type.DIALOGUE:
			return ParleyDialogueNodeAst.get_colour()
		Type.DIALOGUE_OPTION:
			return ParleyDialogueOptionNodeAst.get_colour()
		Type.CONDITION:
			return ParleyConditionNodeAst.get_colour()
		Type.ACTION:
			return ParleyActionNodeAst.get_colour()
		Type.START:
			return ParleyStartNodeAst.get_colour()
		Type.MATCH:
			return ParleyMatchNodeAst.get_colour()
		Type.END:
			return ParleyEndNodeAst.get_colour()
		Type.GROUP:
			return ParleyGroupNodeAst.get_colour()
		_:
			return ParleyNodeAst.get_colour()


## Get name for Dialogue AST type
## Example: ParleyDialogueSequenceAst.get_type_name(type)
static func get_type_name(type: Type) -> String:
	var key: String = Type.keys()[type]
	return key.capitalize()


static func is_dialogue_options(p_nodes: Array[ParleyNodeAst]) -> bool:
	return p_nodes.filter(func(node: ParleyNodeAst) -> bool: return node.type == Type.DIALOGUE_OPTION).size() > 0


func _parse_position_from_raw_node_ast(node: Dictionary) -> Vector2:
	var default: Vector2 = Vector2.ZERO
	var raw_position: Variant = node.get('position', str(default))
	if not is_instance_of(raw_position, TYPE_STRING):
		ParleyUtils.log.warn("Unable to parse position of node: %s. Defaulting to %s" % [node.get('id', 'unknown'), str(default)])
		return default
	var position: String = raw_position
	position = position.erase(0, 1)
	position = position.erase(position.length() - 1, 1)
	var parts: Array = position.split(", ")
	var x: int = int(str(parts[0]))
	var y: int = int(str(parts[1]))
	return Vector2(x, y)


func _parse_colour(datum: Dictionary, key: String = "colour", default: Color = Color(0, 0, 0, 0)) -> Color:
	var raw_colour: Variant = datum.get(key, str(default))
	if not is_instance_of(raw_colour, TYPE_STRING):
		ParleyUtils.log.warn("Unable to parse colour: %s. Defaulting to %s" % [datum.get('id', 'unknown'), str(default)])
		return default
	var colour: String = raw_colour
	colour = colour.erase(0, 1)
	colour = colour.erase(colour.length() - 1, 1)
	var colour_parts: Array = colour.split(", ")
	var r: float = float(str(colour_parts[0]))
	var g: float = float(str(colour_parts[1]))
	var b: float = float(str(colour_parts[2]))
	var a: float = float(str(colour_parts[3]))
	return Color(r, g, b, a)


func _parse_group_size_from_raw_node_ast(node: Dictionary) -> Vector2:
	var default: Vector2 = Vector2(350, 350)
	var raw_size: Variant = node.get('size', str(default))
	if not is_instance_of(raw_size, TYPE_STRING):
		ParleyUtils.log.warn("Unable to parse size of node: %s. Defaulting to %s" % [node.get('id', 'unknown'), str(default)])
		return default
	var size: String = raw_size
	size = size.erase(0, 1)
	size = size.erase(size.length() - 1, 1)
	var size_parts: Array = size.split(", ")
	var x: int = int(str(size_parts[0]))
	var y: int = int(str(size_parts[1]))
	return Vector2(x, y)


func _generate_node_id() -> String:
	if nodes.size() == 0:
		return "1"
	return str(nodes.map(func(node: ParleyNodeAst) -> int: return int(node.id)).max() + 1)


func _generate_edge_id() -> String:
	if edges.size() == 0:
		return "1"
	return str(edges.map(func(edge: ParleyEdgeAst) -> int: return int(edge.id)).max() + 1)


func _emit_dialogue_updated() -> void:
	# TODO: this seems to be called a lot - investigate
	# It's unclear what the purpose of this is any more
	if is_ready:
		dialogue_updated.emit(self)


func _to_string() -> String:
	return "ParleyDialogueSequenceAst<nodes=%d edges=%d>" % [nodes.size(), edges.size()]
#endregion
