# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends GutTest

const MatchNodeEditorScene: PackedScene = preload('res://addons/parley/components/match/match_node_editor.tscn')


class Test_match_node_editor:
	extends GutTest
	
	var match_node_editor: ParleyMatchNodeEditor = null
	var fact_store: ParleyFactStore = preload("res://tests/fixtures/basic_fact_store.tres")
	
	func before_each() -> void:
		match_node_editor = MatchNodeEditorScene.instantiate()
		match_node_editor.fact_store = fact_store
		add_child_autofree(match_node_editor)
	
	func after_each() -> void:
		match_node_editor = null
	
	func setup_match_node_editor(_match_node_editor: ParleyMatchNodeEditor, test_case: Dictionary) -> void:
		var id: Variant = test_case.get('id')
		var description: Variant = test_case.get('description')
		var fact_ref: Variant = test_case.get('fact_ref')
		var cases: Variant = test_case.get('cases')
		if id:
			_match_node_editor.id = id
		if description:
			_match_node_editor.description = description
		if fact_ref:
			_match_node_editor.fact_ref = fact_ref
		if cases:
			_match_node_editor.cases = cases

	func use_match_node_editor(_match_node_editor: ParleyMatchNodeEditor, test_case: Dictionary) -> void:
		var description: Variant = test_case.get('description')
		var fact_ref: Variant = test_case.get('fact_ref')
		var cases: Variant = test_case.get('cases')
		if description:
			_match_node_editor.description_editor.insert_text_at_caret(str(description))
		if fact_ref:
			_match_node_editor.fact_ref = fact_ref
			_match_node_editor.fact_selector.selected = -1
			_match_node_editor.fact_selector.item_selected.emit(fact_store.get_fact_index_by_ref(str(fact_ref)))
		if cases:
			var index: int = 0
			for case: Variant in cases:
				_match_node_editor.add_case_button.pressed.emit()
				var case_editor: ParleyCaseEditor = _match_node_editor.cases_editor.get_child(index)
				if case_editor:
					case_editor.case_editor.item_selected.emit(_match_node_editor.available_cases.find(case))
				index += 1

	func test_initial_render(params: Variant = use_parameters([
		{
			"input": {"id": null, "description": null},
			"expected": {"id": "", "description": "", "fact_ref": "", "selected_fact_ref": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": null},
			"expected": {"id": "1", "description": "", "fact_ref": "", "selected_fact_ref": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": null, "description": "Some description"},
			"expected": {"id": "", "description": "Some description", "fact_ref": "", "selected_fact_ref": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description"},
			"expected": {"id": "1", "description": "Some description", "fact_ref": "", "selected_fact_ref": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description", "fact_ref": "Unknown fact ref"},
			"expected": {"id": "1", "description": "Some description", "fact_ref": "Unknown fact ref", "selected_fact_ref": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description", "fact_ref": ParleyUtils.resource.get_uid(fact_store.facts[0].ref)},
			"expected": {"id": "1", "description": "Some description", "fact_ref": ParleyUtils.resource.get_uid(fact_store.facts[0].ref), "selected_fact_ref": fact_store.facts[0].name, "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description", "fact_ref": ParleyUtils.resource.get_uid(fact_store.facts[1].ref)},
			"expected": {"id": "1", "description": "Some description", "fact_ref": ParleyUtils.resource.get_uid(fact_store.facts[1].ref), "selected_fact_ref": fact_store.facts[1].name, "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description", "fact_ref": ParleyUtils.resource.get_uid(fact_store.facts[1].ref), "cases": ["NEEDS_COFFEE", "NEEDS_MORE_COFFEE", "FALLBACK"]},
			"expected": {"id": "1", "description": "Some description", "fact_ref": ParleyUtils.resource.get_uid(fact_store.facts[1].ref), "selected_fact_ref": fact_store.facts[1].name, "cases": ["NEEDS_COFFEE", "NEEDS_MORE_COFFEE", "FALLBACK"], "selected_cases": ["Needs Coffee", "Needs More Coffee", "Fallback"]},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		setup_match_node_editor(match_node_editor, input)
		watch_signals(match_node_editor)
		
		# Act
		await wait_until(func() -> bool: return match_node_editor.is_inside_tree(), .1)

		# Assert
		assert_true(match_node_editor.is_inside_tree())
		assert_eq(match_node_editor.id, str(expected['id']))
		assert_eq(match_node_editor.description, str(expected['description']))
		assert_eq(match_node_editor.description_editor.text, str(expected['description']))
		assert_eq(match_node_editor.fact_ref, str(expected['fact_ref']), "Expected fact_ref to be set to the expected value.")
		assert_eq(match_node_editor.fact_selector.text, str(expected['selected_fact_ref']), "Expected selected fact_ref to be set to the expected value.")
		assert_eq_deep(match_node_editor.cases, TestUtils.string_array(expected['cases']))
		var index: int = 0
		for expected_case: Variant in expected['selected_cases']:
			var case_editor: ParleyCaseEditor = match_node_editor.cases_editor.get_child(index)
			assert_eq(case_editor.case_editor.text, str(expected_case), "Cases selector does not equal expected case for child: %s" % [index])
			index += 1
		assert_signal_not_emitted(match_node_editor, 'match_node_changed')


	func test_update_render_with_variables(params: Variant = use_parameters([
		{
			"input": {"id": "1", "description": null},
			"expected": {"id": "1", "description": "", "fact_ref": "", "selected_fact_ref": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": null, "description": "Some description"},
			"expected": {"id": "", "description": "Some description", "fact_ref": "", "selected_fact_ref": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description"},
			"expected": {"id": "1", "description": "Some description", "fact_ref": "", "selected_fact_ref": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": "1", "description": "Some description", "fact_ref": ParleyUtils.resource.get_uid(fact_store.facts[1].ref), "cases": ["NEEDS_COFFEE", "NEEDS_MORE_COFFEE", "FALLBACK"]},
			"expected": {"id": "1", "description": "Some description", "fact_ref": ParleyUtils.resource.get_uid(fact_store.facts[1].ref), "selected_fact_ref": fact_store.facts[1].name, "cases": ["NEEDS_COFFEE", "NEEDS_MORE_COFFEE", "FALLBACK"], "selected_cases": ["Needs Coffee", "Needs More Coffee", "Fallback"]},
		}
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		watch_signals(match_node_editor)
		
		# Act
		await wait_until(func() -> bool: return match_node_editor.is_inside_tree(), .1)
		setup_match_node_editor(match_node_editor, input)

		# Assert
		assert_true(match_node_editor.is_inside_tree())
		assert_eq(match_node_editor.id, str(expected['id']))
		assert_eq(match_node_editor.description, str(expected['description']))
		assert_eq(match_node_editor.description_editor.text, str(expected['description']))
		assert_eq(match_node_editor.fact_ref, str(expected['fact_ref']), "Expected fact_ref to be set to the expected value.")
		assert_eq(match_node_editor.fact_selector.text, str(expected['selected_fact_ref']), "Expected selected fact_ref to be set to the expected value.")
		assert_eq_deep(match_node_editor.cases, TestUtils.string_array(expected['cases']))
		var index: int = 0
		for expected_case: Variant in expected['selected_cases']:
			var case_editor: ParleyCaseEditor = match_node_editor.cases_editor.get_child(index)
			assert_eq(case_editor.case_editor.text, str(expected_case), "Cases selector does not equal expected case for child: %s" % [index])
			index += 1
		assert_signal_not_emitted(match_node_editor, 'match_node_changed')


	func test_update_render_with_text_input(params: Variant = use_parameters([
		{
			"input": {"id": null, "description": "Some description", "fact_ref": null, "cases": null},
			"expected": {"id": "", "description": "Some description", "fact_ref": "", "selected_fact_ref": "", "cases": [], "selected_cases": []},
		},
		{
			"input": {"id": null, "description": null, "fact_ref": ParleyUtils.resource.get_uid(fact_store.facts[1].ref), "cases": ["NEEDS_COFFEE", "FALLBACK", "NEEDS_MORE_COFFEE"]},
			"expected": {"id": "", "description": "", "fact_ref": ParleyUtils.resource.get_uid(fact_store.facts[1].ref), "selected_fact_ref": fact_store.facts[1].name, "cases": ["NEEDS_COFFEE", "FALLBACK", "NEEDS_MORE_COFFEE"], "selected_cases": ["Needs Coffee", "Fallback", "Needs More Coffee"]},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		watch_signals(match_node_editor)
		
		# Act
		await wait_until(func() -> bool: return match_node_editor.is_node_ready(), .1)
		use_match_node_editor(match_node_editor, input)
		await wait_for_signal(match_node_editor.match_node_changed, .1)

		# Assert
		assert_true(match_node_editor.is_inside_tree())
		assert_eq(str(match_node_editor.id), str(expected['id']))
		assert_eq(str(match_node_editor.description), str(expected['description']))
		assert_eq(str(match_node_editor.description_editor.text), str(expected['description']))
		assert_eq(match_node_editor.fact_ref, str(expected['fact_ref']), "Expected fact_ref to be set to the expected value.")
		assert_eq(match_node_editor.fact_selector.text, str(expected['selected_fact_ref']), "Expected selected fact_ref to be set to the expected value.")
		assert_eq_deep(match_node_editor.cases, TestUtils.string_array(expected['cases']))
		var index: int = 0
		for expected_case: Variant in expected['selected_cases']:
			var case_editor: ParleyCaseEditor = match_node_editor.cases_editor.get_child(index)
			assert_not_null(case_editor)
			if case_editor:
				assert_eq(case_editor.case_editor.text, str(expected_case), "Cases selector does not equal expected case for child: %s" % [index])
			index += 1
		assert_signal_emitted_with_parameters(match_node_editor, 'match_node_changed', [expected['id'], expected['description'], expected['fact_ref'], expected['cases']])


class TestUtils:
	static func string_array(array: Variant) -> Array[String]:
		if not is_instance_of(array, TYPE_ARRAY):
			return []
		var output: Array[String] = []
		for item: String in array:
			output.append(str(item))
		return output
