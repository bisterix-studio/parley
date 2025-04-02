@tool
# TODO: prefix with Parley
class_name DialogueAst extends Resource

## The title of the Dialogue Sequence AST
@export var title: String

### The edges of the Dialogue Sequence AST
@export var edges: Array[EdgeAst]

## The nodes of the Dialogue Sequence AST
@export var nodes: Array[NodeAst]

## The stores of the Dialogue Sequence AST
@export var stores: StoresAst

## The type of the Dialogue AST Node
## Example: "DialogueAstNodeType.DIALOGUE"
enum Type {DIALOGUE, DIALOGUE_OPTION, CONDITION, ACTION, START, END, GROUP, MATCH, UNKNOWN}

var is_ready: bool = false

# TODO: add types here. However it may be causing circular dep issues
signal dialogue_updated(new_dialogue_ast: Variant)
signal dialogue_ended(dialogue_ast: Variant)

func _init(_title: String = "", _nodes: Array = [], _edges: Array = [], _stores: Dictionary = {}) -> void:
	title = _title
	# TODO: add validation to ensure IDs are globally unique within the context of the dialogue
	for node in _nodes:
		add_ast_node(node)
	for edge in _edges:
		add_ast_edge(edge)
	add_ast_stores(_stores)
	is_ready = true

#region BUILDING DIALOGUE
## Add a node to the list of nodes from an AST
func add_ast_node(node: Dictionary) -> void:
	var type: Type = Type.get(node.get('type'), Type.UNKNOWN)
	var id = node.get('id')
	var position: Vector2 = _parse_position_from_raw_node_ast(node)
	if not id or not is_instance_of(id, TYPE_STRING):
		_push_error("Unable to import Parley AST node without a valid string id field: %s" % [id])
		return
	var ast_node: NodeAst
	match type:
		Type.DIALOGUE:
			ast_node = DialogueNodeAst.new(id, position, node.get('character'), node.get('text'))
		Type.DIALOGUE_OPTION:
			ast_node = DialogueOptionNodeAst.new(id, position, node.get('character'), node.get('text'))
		Type.CONDITION:
			var condition = ConditionNodeAst.Combiner.get(node.get('condition'))
			ast_node = ConditionNodeAst.new(id, position, node.get('description'), condition, node.get('conditions'))
		Type.MATCH:
			ast_node = MatchNodeAst.new(id, position, node.get('description'), node.get('fact_ref'), node.get('cases'))
		Type.ACTION:
			var action_type = ActionNodeAst.ActionType.get(node.get('action_type'))
			ast_node = ActionNodeAst.new(id, position, node.get('description'), action_type, node.get('action_script_ref'), node.get('values'))
		Type.START:
			ast_node = StartNodeAst.new(id, position)
		Type.END:
			ast_node = EndNodeAst.new(id, position)
		Type.GROUP:
			var colour: Color = _parse_group_colour_from_raw_node_ast(node)
			var size: Vector2 = _parse_group_size_from_raw_node_ast(node)
			ast_node = GroupNodeAst.new(id, position, node.get('name', ''), node.get('node_ids', []), colour, size)
		_:
			_push_error("Unable to import Parley AST node of type: %s" % [type])
			return
	ast_node.position = position
	nodes.push_back(ast_node)


## Add a new node to the list of nodes
func add_new_node(type: Type, position: Vector2 = Vector2.ZERO):
	_print('Inserting new Node into the AST of type: %s' % [type])
	var new_id = _generate_id()
	var ast_node: NodeAst
	match type:
		Type.DIALOGUE:
			ast_node = DialogueNodeAst.new(new_id, position)
		Type.DIALOGUE_OPTION:
			ast_node = DialogueOptionNodeAst.new(new_id, position)
		Type.CONDITION:
			ast_node = ConditionNodeAst.new(new_id, position)
		Type.MATCH:
			ast_node = MatchNodeAst.new(new_id, position)
		Type.ACTION:
			ast_node = ActionNodeAst.new(new_id, position)
		Type.START:
			ast_node = StartNodeAst.new(new_id, position)
		Type.END:
			ast_node = EndNodeAst.new(new_id, position)
		Type.GROUP:
			ast_node = GroupNodeAst.new(new_id, position)
		_:
			_push_error("Unable to create new Parley AST node of type: %s" % [type])
			return
	nodes.push_back(ast_node)
	_emit_dialogue_updated()
	return ast_node

## Update Node AST position
func update_node_position(ast_node_id: String, position: Vector2) -> void:
	for node in nodes:
		if node.id == ast_node_id:
			node.position = position
			break
	_emit_dialogue_updated()

## Add an edge to the list of edges from an AST
func add_ast_edge(edge: Dictionary) -> void:
	# TODO: add validation before instantiation to ensure that
	# all values are defined
	add_edge(
		edge.get('from_node'),
		edge.get('from_slot'),
		edge.get('to_node'),
		edge.get('to_slot'),
		false
	)

## Add a store to from an AST
func add_ast_stores(_stores: Dictionary) -> void:
	# TODO: add validation before instantiation to ensure that
	# all values are defined
	var character_store: Array = _stores.get('character', [])
	stores = StoresAst.new(character_store)

## Add a new edge to the list of edges. It will not add an edge if it already exists
## It returns the number of edges added (1 or 0).
## dialogue_ast.add_edge("1", 0, "2", 1)
func add_edge(from_node: String, from_slot: int, to_node: String, to_slot: int, emit = true) -> int:
	var new_edge: EdgeAst = EdgeAst.new(
		from_node,
		from_slot,
		to_node,
		to_slot,
	)
	var has_existing_edge: bool = edges.filter(func(edge: EdgeAst) -> bool:
		return (
			edge.from_node == new_edge.from_node and
			edge.from_slot == new_edge.from_slot and
			edge.to_node == new_edge.to_node and
			edge.to_slot == new_edge.to_slot
		)
	).size() > 0
	if not has_existing_edge:
		edges.push_back(new_edge)
		if emit:
			_emit_dialogue_updated()
	return 1 if not has_existing_edge else 0

## Remove edges to the list of edges.
## It returns the number of edges added.
## dialogue_ast.add_edges([EdgeAst("1", 0, "2", 1).new()])
func add_edges(edges_to_create: Array[EdgeAst], emit = true) -> int:
	var added: int = 0
	for edge: EdgeAst in edges_to_create:
		added += add_edge(edge.from_node, edge.from_slot, edge.to_node, edge.to_slot, false)
	if added > 0 and emit:
		_emit_dialogue_updated()
	return added

# TODO: also remove edges if there are any
## Remove a node from the list of nodes
func remove_node(node_id: String) -> void:
	var index: int = 0
	var removed = false
	for node in nodes:
		if node.id == node_id:
			nodes.remove_at(index)
			removed = true
			break
		index += 1
	if not removed:
		_print("Unable to remove node with ID: %s" % [node_id])
	_emit_dialogue_updated()


## Find a Node AST by its ID.
## Example: ast.find_node_by_id("1")
func find_node_by_id(id: String) -> NodeAst:
	var filtered_nodes = nodes.filter(func(node): return str(node.id) == str(id))
	if filtered_nodes.size() != 1:
		_print("No AST Node found with ID: {id}".format({'id': id}))
		return null
	return filtered_nodes.front()


## Remove an edge from the list of edges. It will log an error if an edge does not exist
## It returns the number of edges removed (1 or 0).
## dialogue_ast.remove_edge("1", 0, "2", 1)
func remove_edge(from_node: String, from_slot: int, to_node: String, to_slot: int, emit = true) -> int:
	var index: int = 0
	var removed = false
	for edge in edges:
		if (edge.from_node == from_node and
			edge.from_slot == from_slot and
			edge.to_node == to_node and
			edge.to_slot == to_slot):
			edges.remove_at(index)
			removed = true
			break
		index += 1
	if not removed:
		_print("Unable to remove edge: %s-%s:%s-%s" % [from_node, from_slot, to_node, to_slot])
	if removed and emit:
		_emit_dialogue_updated()
	return 1 if removed else 0

## Remove edges from the list of edges.
## It returns the number of edges removed.
## dialogue_ast.remove_edges([EdgeAst("1", 0, "2", 1).new()])
func remove_edges(edges_to_remove: Array[EdgeAst], emit = true) -> int:
	var removed: int = 0
	for edge: EdgeAst in edges_to_remove:
		removed += remove_edge(edge.from_node, edge.from_slot, edge.to_node, edge.to_slot, false)
	if removed > 0 and emit:
		_emit_dialogue_updated()
	return removed
#endregion


#region DIALOGUE RUNTIME
# TODO: make context a class that can be extended
## Get the next node that can be rendered and perform any necessary processing
func process_next(ctx: Dictionary, current_node: NodeAst = null, dry_run: bool = false) -> Array[NodeAst]:
	if not current_node:
		var start_node = _get_start_node(dry_run)
		if not start_node:
			return []
		current_node = start_node
		
	var id: String = current_node.id
	# TODO: this won't work for conditionals, need to account for multiple slots
	var next_edges: Array[EdgeAst] = edges.filter(func(edge): return str(edge.from_node) == id)
	# TODO: the Dialogue AST should have a generate new unique ID function
	var end = EndNodeAst.new(_generate_id())
	if next_edges.size() == 0:
		return _process_end(dry_run)
	var next_nodes: Array[NodeAst] = []
	var condition_result: bool
	var match_result: int
	if current_node.type == Type.CONDITION:
		condition_result = _process_condition_node(ctx, current_node, dry_run)
	if current_node.type == Type.MATCH:
		match_result = _process_match_node(ctx, current_node)
	
	for next_edge in next_edges:
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
		var filtered_next_nodes = nodes.filter(func(node): return node.id == next_id)
		if filtered_next_nodes.size() == 0:
			_printwarn('Node: {id} not found for Edge: {edge}'.format({'id': next_id, 'edge': next_edge}), dry_run)
			continue
		var next_node: NodeAst = filtered_next_nodes.front()
		var next_type: Type = next_node.type
		match next_type:
			Type.DIALOGUE:
				next_nodes.append(next_node)
			Type.DIALOGUE_OPTION:
				next_nodes.append(next_node)
			Type.ACTION:
				if not dry_run:
					# TODO: Run action here
					pass
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
				_printwarn("AST Node {type} is not supported".format({"type": next_type}), dry_run)
				continue
	
	var types: Array[Type] = []
	# TODO: check for multiple of Dialogue
	# TODO: check for multiple of End
	for next_node in next_nodes:
		var type: Type = next_node.type
		if type not in types:
			types.append(type)

	if types.size() == 0:
		# Add this check here to ensure that conditions behave like guards
		if current_node.type == Type.CONDITION:
			return []
		_print("No AST Node types found for Dialogue tree: {types}".format({"types": types}), dry_run)
		return _process_end(dry_run)


	if types.size() > 1:
		_print("Multiple AST Node types found for Dialogue tree: {types}".format({"types": types}), dry_run)
		return _process_end(dry_run)

	if is_instance_of(next_nodes.front(), EndNodeAst):
		_process_end(dry_run) # Don't return as we want to use the existing End Node ID
	next_nodes.sort_custom(_sort_by_y_position)
	return next_nodes
	

# TODO: make context a class that can be extended
## Indicator for whether the node is at the end of the current dialogue sequence
func is_at_end(ctx: Dictionary, current_node: NodeAst) -> bool:
	# Perform a dry run to infer whether we are at the final node
	var next_nodes = process_next(ctx, current_node, true)
	if next_nodes.size() == 1 and next_nodes.front() is EndNodeAst:
		return true
	return false


func _process_condition_node(ctx: Dictionary, condition_node: ConditionNodeAst, dry_run: bool) -> bool:
	var combiner = condition_node.condition
	var conditions = condition_node.conditions
	var results: Array[bool] = []
	for condition_def in conditions:
		var fact_ref = condition_def.get('fact_ref')
		var operator = condition_def.get('operator')
		# TODO: evaluate this as an expression
		var value = condition_def.get('value')
		var fact: FactInterface = load(fact_ref).new()
		var result = fact.execute(ctx, [])
		# TODO: create a wrapper for this
		fact.call_deferred("free")
		var evaluated_value = _evaluate_value(value)
		match operator:
			ConditionNodeAst.Operator.EQUAL:
				results.append(typeof(result) == typeof(evaluated_value) and result == evaluated_value)
			ConditionNodeAst.Operator.NOT_EQUAL:
				results.append(typeof(result) != typeof(evaluated_value) or result != _evaluate_value(value))
			_:
				_print("Operator of type %s is not supported" % [operator], dry_run)
	if results.size() == 0:
		_print("No results evaluated", dry_run)
		return false
	match combiner:
		ConditionNodeAst.Combiner.ALL:
			return not results.has(false)
		ConditionNodeAst.Combiner.ANY:
			return results.has(true)
		_:
			_print("Combiner of type %s is not supported" % [combiner], dry_run)
			return false


func _process_match_node(ctx: Dictionary, match_node: MatchNodeAst) -> int:
	var fact_ref: String = match_node.fact_ref
	var fact: FactInterface = load(fact_ref).new()
	var result: Variant = fact.execute(ctx, [])
	# TODO: create a wrapper for this
	fact.call_deferred("free")
	var evaluated_result: Variant = _evaluate_value(result)
	var cases: Array = match_node.cases
	var case_index: int = cases.map(func(case: Variant) -> Variant: return _map_value(case)).find(evaluated_result)
	if case_index == -1:
		return cases.find(MatchNodeAst.fallback_key)
	return case_index


func _print(message: String, dry_run: bool = false) -> void:
	if not dry_run:
		print("PARLEY_DBG: %s" % [message])

func _push_error(message: String, dry_run: bool = false) -> void:
	if not dry_run:
		push_error("PARLEY_ERR: %s" % [message])

func _printwarn(message: String, dry_run: bool = false) -> void:
	if not dry_run:
		print("PARLEY_WRN: %s" % [message])


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

func _process_end(dry_run: bool) -> Array[NodeAst]:
	if not dry_run:
		dialogue_ended.emit(self)
	return [EndNodeAst.new(_generate_id())]

func _sort_by_y_position(a: NodeAst, b: NodeAst) -> bool:
	if a.position.y < b.position.y:
		return true
	return false


func _get_start_node(dry_run: bool) -> Variant:
	var filtered_nodes: Array[NodeAst] = nodes.filter(func(node: NodeAst) -> bool: return node.type == Type.START)
	if filtered_nodes.size() == 0:
		_push_error("No Start Nodes found. Unable to start the dialogue.", dry_run)
		return
	if filtered_nodes.size() > 1:
		_push_error("Multiple Start Nodes found. Unable to start the dialogue.", dry_run)
	return filtered_nodes.front()
#endregion


#region HELPERS
## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	return {
		'title': title,
		'nodes': nodes.map(func(node: NodeAst) -> Dictionary: return node.to_dict()),
		'edges': edges.map(func(edge: EdgeAst) -> Dictionary: return edge.to_dict()),
		'stores': stores.to_dict()
	}


## Convert this resource into CSV lines
func to_csv_lines() -> Array[PackedStringArray]:
	# TODO: handle locales at scale
	var lines: Array[PackedStringArray] = [PackedStringArray(["id", "type", "character_en", "text_en"])]
	for node_ast: NodeAst in nodes:
		match node_ast.type:
			Type.DIALOGUE:
				var node: DialogueNodeAst = node_ast
				lines.append(PackedStringArray([node.id, get_type_name(node.type), node.character, node.text]))
			Type.DIALOGUE_OPTION:
				var node: DialogueOptionNodeAst = node_ast
				lines.append(PackedStringArray([node.id, get_type_name(node.type), node.character, node.text]))
			_:
				continue
	return lines


## Get colour for Dialogue AST type
## Example: DialogueAst.get_type_colour(type)
static func get_type_colour(type: Type) -> Color:
	match type:
		Type.DIALOGUE:
			return DialogueNodeAst.get_colour()
		Type.DIALOGUE_OPTION:
			return DialogueOptionNodeAst.get_colour()
		Type.CONDITION:
			return ConditionNodeAst.get_colour()
		Type.ACTION:
			return ActionNodeAst.get_colour()
		Type.START:
			return StartNodeAst.get_colour()
		Type.MATCH:
			return MatchNodeAst.get_colour()
		Type.END:
			return EndNodeAst.get_colour()
		Type.GROUP:
			return GroupNodeAst.get_colour()
		_:
			return NodeAst.get_colour()


## Get name for Dialogue AST type
## Example: DialogueAst.get_type_name(type)
static func get_type_name(type: Type) -> String:
	return Type.keys()[type].capitalize()


static func is_dialogue_options(nodes: Array[NodeAst]) -> bool:
	return nodes.filter(func(node): return node.type == Type.DIALOGUE_OPTION).size() > 0


func _parse_position_from_raw_node_ast(node: Dictionary) -> Vector2:
	var raw_position = node.get('position', str(Vector2.ZERO))
	raw_position = raw_position.erase(0, 1)
	raw_position = raw_position.erase(raw_position.length() - 1, 1)
	var parts: Array = raw_position.split(", ")
	return Vector2(int(parts[0]), int(parts[1]))


func _parse_group_colour_from_raw_node_ast(node: Dictionary) -> Color:
	var raw_colour = node.get('colour', str(Color(0, 0, 0, 0)))
	raw_colour = raw_colour.erase(0, 1)
	raw_colour = raw_colour.erase(raw_colour.length() - 1, 1)
	var colour_parts = raw_colour.split(", ")
	return Color(float(colour_parts[0]), float(colour_parts[1]), float(colour_parts[2]), float(colour_parts[3]))


func _parse_group_size_from_raw_node_ast(node: Dictionary) -> Vector2:
	var raw_size = node.get('size', str(Vector2(350, 350)))
	raw_size = raw_size.erase(0, 1)
	raw_size = raw_size.erase(raw_size.length() - 1, 1)
	var size_parts: Array = raw_size.split(", ")
	return Vector2(int(size_parts[0]), int(size_parts[1]))


func _generate_id() -> String:
	if nodes.size() == 0:
		return "1"
	return str(nodes.map(func(node: NodeAst) -> int: return int(node.id)).max() + 1)


func _emit_dialogue_updated() -> void:
	# TODO: this seems to be called a lot - investigate
	# It's unclear what the purpose of this is any more
	if is_ready:
		dialogue_updated.emit(self)
#endregion
