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

	var test_dialogue_ast: DialogueAst = load('res://tests/fixtures/basic_ast_node_generation_input.dlog')
	
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


	var test_dialogue_ast_sort_cases: DialogueAst = load('res://tests/fixtures/basic_ast_node_generation_input_with_sorting_cases.dlog')

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

	var test_dialogue_ast_with_match_node: DialogueAst = load('res://tests/fixtures/basic_match_input.dlog')
	
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
		d.erase('@path')
		d.erase('@subpath')
		return d
