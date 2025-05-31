extends GutTest

class Test_process_next:
	extends GutTest

	func _resolve_expected(params: Dictionary, dialogue_ast: DialogueAst) -> Array:
		var expected: Array = []
		if params.get('expected', null):
			expected = params['expected']
		else:
			var expected_ids: PackedStringArray = params['expected_ids']
			for expected_id: String in expected_ids:
				var found: Array[NodeAst] = dialogue_ast.nodes.filter(func(node: NodeAst) -> bool: return node.id == expected_id)
				if found.size() > 0:
					expected.append(found.front())
		return expected

	var test_dialogue_ast: DialogueAst = load('res://tests/fixtures/basic_ast_node_generation_input.ds')
	
	var test_process_next_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "3", "expected_ids": ["4"]},
		{"ctx": {}, "current_id": "4", "expected_ids": ["7"]},
		{"ctx": {"bob_has_coffee": false}, "current_id": "4", "expected_ids": ["17"]},
		{"ctx": {"bob_has_coffee": false, "alice_gave_coffee": false}, "current_id": "4", "expected_ids": ["19"]},
		{"ctx": {}, "current_id": "7", "expected_ids": ["8", "13"]},
		{"ctx": {}, "current_id": "8", "expected_ids": ["10"]},
		{"ctx": {}, "current_id": "10", "expected_ids": ["11"]},
		{"ctx": {}, "current_id": "11", "expected_ids": ["12"]},
		{"ctx": {}, "current_id": "12", "expected_ids": ["21"]},
		{"ctx": {}, "current_id": "13", "expected_ids": ["14"]},
		{"ctx": {}, "current_id": "14", "expected_ids": ["15"]},
		{"ctx": {}, "current_id": "15", "expected_ids": ["21"]},
	]
	
	func test_process_next(params: Dictionary = use_parameters(test_process_next_cases)) -> void:
		# Arrange
		var current_node: NodeAst = test_dialogue_ast.nodes.filter(func(node: NodeAst) -> bool: return node.id == params['current_id'])[0]
		var expected: Array = _resolve_expected(params, test_dialogue_ast)
		var ctx: Dictionary = params.get('ctx', {})
		
		# Act
		var result: Array[NodeAst] = test_dialogue_ast.process_next(ctx, current_node)

		# Assert
		assert_eq_deep(result.map(map_to_dict), expected.map(map_to_dict))


	var test_dialogue_ast_sort_cases: DialogueAst = load('res://tests/fixtures/basic_ast_node_generation_input_with_sorting_cases.ds')

	var test_process_next_sort_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "6", "expected_ids": ["9", "10", "11"]},
		{"ctx": {}, "current_id": "8", "expected_ids": ["14", "12", "13"]},
	]

	func test_process_next_sort_by_y_position(params: Dictionary = use_parameters(test_process_next_sort_cases)) -> void:
		# Arrange
		var current_node: NodeAst = test_dialogue_ast_sort_cases.nodes.filter(func(node: NodeAst) -> bool: return node.id == params['current_id'])[0]
		var expected: Array = _resolve_expected(params, test_dialogue_ast_sort_cases)
		var ctx: Dictionary = params.get('ctx', {})
		
		# Act
		var result: Array[NodeAst] = test_dialogue_ast_sort_cases.process_next(ctx, current_node)

		# Assert
		assert_eq_deep(result.map(func(i: DialogueOptionNodeAst) -> String: return i.text), ['Top', 'Middle', 'Bottom'])
		assert_eq_deep(result.map(map_to_dict), expected.map(map_to_dict))

	var test_dialogue_ast_with_match_node: DialogueAst = load('res://tests/fixtures/basic_match_input.ds')
	
	var test_process_next_with_match_node_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "1", "expected_ids": ["16"]},
		{"ctx": {"alice_coffee_status": "NEEDS_COFFEE"}, "current_id": "16", "expected_ids": ["3"]},
		{"ctx": {"alice_coffee_status": "NEEDS_MORE_COFFEE"}, "current_id": "16", "expected_ids": ["4"]},
		{"ctx": {"alice_coffee_status": "NEEDS_EVEN_MORE_COFFEE"}, "current_id": "16", "expected_ids": ["5"]},
		{"ctx": {"alice_coffee_status": "INVALID"}, "current_id": "16", "expected_ids": ["6"]},
		{"ctx": {}, "current_id": "16", "expected_ids": ["6"]},
		{"ctx": {}, "current_id": "3", "expected_ids": ["8"]},
		{"ctx": {}, "current_id": "4", "expected_ids": ["8"]},
		{"ctx": {}, "current_id": "5", "expected_ids": ["8"]},
		{"ctx": {}, "current_id": "6", "expected_ids": ["8"]},
		{"ctx": {"ball": 1}, "current_id": "8", "expected_ids": ["10"]},
		{"ctx": {"ball": 2}, "current_id": "8", "expected_ids": ["14"]},
		{"ctx": {"ball": 6}, "current_id": "8", "expected_ids": ["13"]},
		{"ctx": {"ball": 5}, "current_id": "8", "expected_ids": ["12"]},
		{"ctx": {"ball": 7}, "current_id": "8", "expected_ids": ["11"]},
		{"ctx": {}, "current_id": "8", "expected_ids": ["11"]},
		{"ctx": {}, "current_id": "11", "expected_ids": ["15"]},
	]
	
	func test_process_next_with_match_node(params: Dictionary = use_parameters(test_process_next_with_match_node_cases)) -> void:
		# Arrange
		var current_node: NodeAst = test_dialogue_ast_with_match_node.nodes.filter(func(node: NodeAst) -> bool: return node.id == params['current_id']).front()
		var expected: Array = _resolve_expected(params, test_dialogue_ast_with_match_node)
		var ctx: Dictionary = params.get('ctx', {})
		
		# Act
		var result: Array[NodeAst] = test_dialogue_ast_with_match_node.process_next(ctx, current_node)

		# Assert
		assert_eq_deep(result.map(map_to_dict), expected.map(map_to_dict))

	func map_to_dict(node: NodeAst) -> Dictionary:
		var d: Dictionary = inst_to_dict(node)
		var _path_result: bool = d.erase('@path')
		var _subpath_result: bool = d.erase('@subpath')
		return d

class Test_add_edge:
	extends GutTest
	var test_add_edge_cases: Array[Dictionary] = [
		{
			"current_edges": [],
			"edge": {"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
			"expected": {
				"added": true,
				"emitted": true,
				"edges": [
					{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1}
				]
			},
		},
		{
			"current_edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"edge": {"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
			"expected": {
				"added": false,
				"emitted": false,
				"edges": [
					{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1}
				]
			},
		},
	]
	
	func test_add_edge(params: Dictionary = use_parameters(test_add_edge_cases)) -> void:
		# Arrange
		var current_edges: Array = params.get('current_edges', [])
		var edge: Dictionary = params.get('edge', {})
		var dialogue_ast: DialogueAst = DialogueAst.new("", [], current_edges)
		var from_node: String = edge.get('from_node')
		var from_slot: int = edge.get('from_slot')
		var to_node: String = edge.get('to_node')
		var to_slot: int = edge.get('to_slot')
		var expected: Dictionary = params.get('expected', {})
		var expected_added: bool = expected.get('added')
		var expected_edges: Array = expected.get('edges')
		var expected_emitted: bool = expected.get('emitted')
		watch_signals(dialogue_ast)
		
		# Act
		var result: EdgeAst = dialogue_ast.add_edge(from_node, from_slot, to_node, to_slot)

		# Assert
		if expected_added:
			assert_not_null(result)
		else:
			assert_null(result)
		var updated_edges: Array = dialogue_ast.to_dict().get('edges')
		assert_eq_deep(updated_edges, expected_edges)
		if expected_emitted:
			assert_signal_emitted(dialogue_ast, 'dialogue_updated')

class Test_add_edges:
	extends GutTest
	var test_add_edges_cases: Array[Dictionary] = [
		{
			"current_edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"edges": [
				{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "3", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"expected": {
				"added": 2,
				"emitted": true,
				"edges": [
					{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
					{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1},
					{"from_node": "3", "from_slot": 0, "to_node": "2", "to_slot": 1}
				]
			},
		},
		{
			"current_edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1},
			],
			"edges": [
				{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "3", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"expected": {
				"added": 1,
				"emitted": true,
				"edges": [
					{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
					{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1},
					{"from_node": "3", "from_slot": 0, "to_node": "2", "to_slot": 1}
				]
			},
		},
		{
			"current_edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1},
			],
			"edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"expected": {
				"added": 0,
				"emitted": false,
				"edges": [
					{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
					{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1}
				]
			},
		},
	]
	
	func test_add_edges(params: Dictionary = use_parameters(test_add_edges_cases)) -> void:
		# Arrange
		var current_edges: Array = params.get('current_edges', [])
		var raw_edges: Array = params.get('edges', [])
		var edges: Array[EdgeAst] = []
		for edge: Dictionary in raw_edges:
			var from_node: String = edge.get('from_node')
			var from_slot: int = edge.get('from_slot')
			var to_node: String = edge.get('to_node')
			var to_slot: int = edge.get('to_slot')
			edges.append(EdgeAst.new(from_node, from_slot, to_node, to_slot))
		var dialogue_ast: DialogueAst = DialogueAst.new("", [], current_edges)
		var expected: Dictionary = params.get('expected', {})
		var expected_added: int = expected.get('added')
		var expected_edges: Array = expected.get('edges')
		var expected_emitted: bool = expected.get('emitted')
		watch_signals(dialogue_ast)
		
		# Act
		var result: int = dialogue_ast.add_edges(edges)

		# Assert
		assert_eq(result, expected_added)
		var updated_edges: Array = dialogue_ast.to_dict().get('edges')
		assert_eq_deep(updated_edges, expected_edges)
		if expected_emitted:
			assert_signal_emitted(dialogue_ast, 'dialogue_updated')


class Test_remove_edge:
	extends GutTest
	var test_remove_edge_cases: Array[Dictionary] = [
		{
			"current_edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"edge": {"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
			"expected": {
				"removed": 1,
				"emitted": true,
				"edges": []
			},
		},
		{
			"current_edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"edge": {"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1},
			"expected": {
				"removed": 0,
				"emitted": false,
				"edges": [
					{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1}
				]
			},
		},
	]
	
	func test_remove_edge(params: Dictionary = use_parameters(test_remove_edge_cases)) -> void:
		# Arrange
		var current_edges: Array = params.get('current_edges', [])
		var edge: Dictionary = params.get('edge', {})
		var dialogue_ast: DialogueAst = DialogueAst.new("", [], current_edges)
		var from_node: String = edge.get('from_node')
		var from_slot: int = edge.get('from_slot')
		var to_node: String = edge.get('to_node')
		var to_slot: int = edge.get('to_slot')
		var expected: Dictionary = params.get('expected', {})
		var expected_removed: int = expected.get('removed')
		var expected_edges: Array = expected.get('edges')
		var expected_emitted: bool = expected.get('emitted')
		watch_signals(dialogue_ast)
		
		# Act
		var result: int = dialogue_ast.remove_edge(from_node, from_slot, to_node, to_slot)

		# Assert
		assert_eq(result, expected_removed)
		var updated_edges: Array = dialogue_ast.to_dict().get('edges')
		assert_eq_deep(updated_edges, expected_edges)
		if expected_emitted:
			assert_signal_emitted(dialogue_ast, 'dialogue_updated')

class Test_remove_edges:
	extends GutTest
	var test_remove_edges_cases: Array[Dictionary] = [
		{
			"current_edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "3", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"expected": {
				"removed": 2,
				"emitted": true,
				"edges": [
					{"from_node": "3", "from_slot": 0, "to_node": "2", "to_slot": 1}
				]
			},
		},
		{
			"current_edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "3", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"expected": {
				"removed": 1,
				"emitted": true,
				"edges": [
					{"from_node": "3", "from_slot": 0, "to_node": "2", "to_slot": 1}
				]
			},
		},
		{
			"current_edges": [
				{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
				{"from_node": "3", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"edges": [
				{"from_node": "2", "from_slot": 0, "to_node": "2", "to_slot": 1}
			],
			"expected": {
				"removed": 0,
				"emitted": false,
				"edges": [
					{"from_node": "1", "from_slot": 0, "to_node": "2", "to_slot": 1},
					{"from_node": "3", "from_slot": 0, "to_node": "2", "to_slot": 1}
				]
			},
		},
	]
	
	func test_remove_edges(params: Dictionary = use_parameters(test_remove_edges_cases)) -> void:
		# Arrange
		var current_edges: Array = params.get('current_edges', [])
		var raw_edges: Array = params.get('edges', [])
		var edges: Array[EdgeAst] = []
		for edge: Dictionary in raw_edges:
			var from_node: String = edge.get('from_node')
			var from_slot: int = edge.get('from_slot')
			var to_node: String = edge.get('to_node')
			var to_slot: int = edge.get('to_slot')
			edges.append(EdgeAst.new(from_node, from_slot, to_node, to_slot))
		var dialogue_ast: DialogueAst = DialogueAst.new("", [], current_edges)
		var expected: Dictionary = params.get('expected', {})
		var expected_removed: int = expected.get('removed')
		var expected_edges: Array = expected.get('edges')
		var expected_emitted: bool = expected.get('emitted')
		watch_signals(dialogue_ast)
		
		# Act
		var result: int = dialogue_ast.remove_edges(edges)

		# Assert
		assert_eq(result, expected_removed)
		var updated_edges: Array = dialogue_ast.to_dict().get('edges')
		assert_eq_deep(updated_edges, expected_edges)
		if expected_emitted:
			assert_signal_emitted(dialogue_ast, 'dialogue_updated')
