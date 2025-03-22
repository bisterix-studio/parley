extends GutTest

const MatchNodeScene: PackedScene = preload('res://addons/parley/components/match/match_node.tscn')


class Test_match_node:
	extends GutTest
	
	var match_node: MatchNode = null
	
	func before_each() -> void:
		match_node = MatchNodeScene.instantiate()
		add_child_autofree(match_node)
	
	func after_each() -> void:
		match_node = null
	
	func setup_match_node(_match_node: MatchNode, test_case: Dictionary) -> void:
		var id: Variant = test_case.get('id')
		var description: Variant = test_case.get('description')
		var fact_name: Variant = test_case.get('fact_name')
		var cases: Variant = test_case.get('cases')
		if id:
			_match_node.id = id
		if description:
			_match_node.description = description
		if fact_name:
			_match_node.fact_name = fact_name
		if cases:
			_match_node.cases = cases

	func test_initial_render(params: Variant = use_parameters([
		{
			"input": {"id": null, "description": null},
			"expected": {"id": "", "description": "", "fact_name": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": null},
			"expected": {"id": "1", "description": "", "fact_name": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": null, "description": "Some description"},
			"expected": {"id": "", "description": "Some description", "fact_name": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description"},
			"expected": {"id": "1", "description": "Some description", "fact_name": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description", "fact_name": "Unknown fact"},
			"expected": {"id": "1", "description": "Some description", "fact_name": "Unknown fact", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description", "fact_name": "Fact 1"},
			"expected": {"id": "1", "description": "Some description", "fact_name": "Fact 1", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description", "fact_name": "Fact 2"},
			"expected": {"id": "1", "description": "Some description", "fact_name": "Fact 2", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description", "fact_name": "Fact 2", "cases": ["NEEDS_COFFEE", "NEEDS_MORE_COFFEE", "FALLBACK"]},
			"expected": {"id": "1", "description": "Some description", "fact_name": "Fact 2", "selected_fact_name": "Fact 2", "cases": ["NEEDS_COFFEE", "NEEDS_MORE_COFFEE", "FALLBACK"], "selected_cases": ["Needs Coffee", "Needs More Coffee", "Fallback"]},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		var expected_cases: Array = expected['cases']
		setup_match_node(match_node, input)
		watch_signals(match_node)
		
		# Act
		await wait_until(func() -> void: return match_node.is_inside_tree(), .1)

		# Assert
		assert_true(match_node.is_inside_tree())
		assert_eq(match_node.id, str(expected['id']))
		assert_eq(match_node.description, str(expected['description']))
		assert_eq(match_node.description_label.text, str(expected['description']))
		assert_eq(match_node.fact_name, str(expected['fact_name']), "Expected fact_name to be set to the expected value.")
		assert_eq(match_node.fact_label.text, str(expected['fact_name']), "Expected fact_name to be set to the expected value.")
		assert_eq_deep(match_node.cases, expected_cases)
		var index: int = MatchNode.start_slot
		for expected_case: Variant in expected['selected_cases']:
			var case_label: CaseLabel = match_node.get_child(index)
			assert_eq(case_label.case_label.text, str(expected_case), "Cases label does not equal expected case for child: %s" % [index])
			index += 1
