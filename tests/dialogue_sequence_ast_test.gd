# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends GutTest


const ParleyConstants = preload("res://addons/parley/constants.gd")


class Test_dialogue_sequence_ast:
	extends GutTest

	var result: ParleyRunResult
	var ctx: ParleyContext
	var test_dialogue_sequence_ast: ParleyDialogueSequenceAst
	var test_dialogue_sequence_ast_with_match_node: ParleyDialogueSequenceAst
	var test_dialogue_sequence_ast_sort_cases: ParleyDialogueSequenceAst
	var test_dialogue_sequence_ast_from_jump_node: ParleyDialogueSequenceAst
	var test_dialogue_sequence_ast_to_jump_node: ParleyDialogueSequenceAst
	var test_dialogue_sequence_translations: ParleyDialogueSequenceAst


	func before_each() -> void:
		test_dialogue_sequence_ast = TestUtils.load_dialogue_sequence_ast('res://tests/fixtures/basic_ast_node_generation_input.ds')
		test_dialogue_sequence_ast_with_match_node = TestUtils.load_dialogue_sequence_ast('res://tests/fixtures/basic_match_input.ds')
		test_dialogue_sequence_ast_sort_cases = TestUtils.load_dialogue_sequence_ast('res://tests/fixtures/basic_ast_node_generation_input_with_sorting_cases.ds')
		# We need the resource paths so these must be preserved
		test_dialogue_sequence_ast_from_jump_node = load('res://tests/fixtures/from_jump_node_input.ds')
		test_dialogue_sequence_ast_to_jump_node = load('res://tests/fixtures/to_jump_node_input.ds')


	func after_each() -> void:
		if ctx:
			ctx.free()
		if result:
			result.free()
		if test_dialogue_sequence_ast:
			test_dialogue_sequence_ast = null
		if test_dialogue_sequence_ast_with_match_node:
			test_dialogue_sequence_ast_with_match_node = null
		if test_dialogue_sequence_ast_sort_cases:
			test_dialogue_sequence_ast_sort_cases = null
		if test_dialogue_sequence_ast_from_jump_node:
			test_dialogue_sequence_ast_from_jump_node = null
		if test_dialogue_sequence_ast_to_jump_node:
			test_dialogue_sequence_ast_to_jump_node = null
		if test_dialogue_sequence_translations:
			test_dialogue_sequence_translations = null

	#region INIT
	var test_init_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "node:1", "expected_ids": ["node:3"]},
		{"ctx": {}, "current_id": "node:3", "expected_ids": ["node:3"]},
		{"ctx": {}, "current_id": "node:4", "expected_ids": ["node:4"]},
		{"ctx": {}, "current_id": "node:6", "expected_ids": ["node:7"]},
		{"ctx": {"bob_has_coffee": false}, "current_id": "node:6", "expected_ids": ["node:17"]},
		{"ctx": {"bob_has_coffee": false, "alice_gave_coffee": false}, "current_id": "node:6", "expected_ids": ["node:19"]},
		{"ctx": {}, "current_id": "node:7", "expected_ids": ["node:7"]},
		{"ctx": {}, "current_id": "node:8", "expected_ids": ["node:8"]},
		{"ctx": {}, "current_id": "node:9", "expected_ids": ["node:10"]},
		{"ctx": {}, "current_id": "node:10", "expected_ids": ["node:10"]},
		{"ctx": {}, "current_id": "node:11", "expected_ids": ["node:11"]},
		{"ctx": {}, "current_id": "node:12", "expected_ids": ["node:12"]},
		{"ctx": {}, "current_id": "node:13", "expected_ids": ["node:13"]},
		{"ctx": {}, "current_id": "node:14", "expected_ids": ["node:14"]},
		{"ctx": {}, "current_id": "node:15", "expected_ids": ["node:15"]},
		{"ctx": {}, "current_id": "node:17", "expected_ids": ["node:17"]},
		{"ctx": {}, "current_id": "node:19", "expected_ids": ["node:19"]},
		{"ctx": {}, "current_id": "node:20", "expected_ids": ["node:20"]},
		{"ctx": {}, "current_id": "node:21", "expected_ids": ["node:21"]},
	]


	func test_init(params: Dictionary = use_parameters(test_init_cases)) -> void:
		# Arrange
		var current_node: ParleyNodeAst = test_dialogue_sequence_ast.nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == params['current_id'])[0]
		var expected: Array = TestUtils._resolve_expected(params, test_dialogue_sequence_ast)
		var ctx_data: Dictionary = params.get('ctx', {})
		ctx = ParleyContext.create(test_dialogue_sequence_ast, ctx_data)
		
		# Act
		result = await ParleyDialogueSequenceAst.init(ctx, test_dialogue_sequence_ast, current_node)

		# Assert
		assert_eq_deep(result.node_asts.map(TestUtils.map_to_dict), expected.map(TestUtils.map_to_dict))


	var test_init_with_match_node_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "node:1", "expected_ids": ["node:16"]},
		{"ctx": {}, "current_id": "node:2", "expected_ids": ["node:6"]},
		{"ctx": {"alice_coffee_status": "NEEDS_COFFEE"}, "current_id": "node:2", "expected_ids": ["node:3"]},
		{"ctx": {"alice_coffee_status": "NEEDS_MORE_COFFEE"}, "current_id": "node:2", "expected_ids": ["node:4"]},
		{"ctx": {"alice_coffee_status": "NEEDS_EVEN_MORE_COFFEE"}, "current_id": "node:2", "expected_ids": ["node:5"]},
		{"ctx": {"alice_coffee_status": "INVALID"}, "current_id": "node:2", "expected_ids": ["node:6"]},
		{"ctx": {}, "current_id": "node:3", "expected_ids": ["node:3"]},
		{"ctx": {}, "current_id": "node:4", "expected_ids": ["node:4"]},
		{"ctx": {}, "current_id": "node:5", "expected_ids": ["node:5"]},
		{"ctx": {}, "current_id": "node:6", "expected_ids": ["node:6"]},
		{"ctx": {}, "current_id": "node:8", "expected_ids": ["node:8"]},
		{"ctx": {"ball": 1}, "current_id": "node:9", "expected_ids": ["node:10"]},
		{"ctx": {"ball": 2}, "current_id": "node:9", "expected_ids": ["node:14"]},
		{"ctx": {"ball": 6}, "current_id": "node:9", "expected_ids": ["node:13"]},
		{"ctx": {"ball": 5}, "current_id": "node:9", "expected_ids": ["node:12"]},
		{"ctx": {"ball": 7}, "current_id": "node:9", "expected_ids": ["node:11"]},
		{"ctx": {}, "current_id": "node:10", "expected_ids": ["node:10"]},
		{"ctx": {}, "current_id": "node:14", "expected_ids": ["node:14"]},
		{"ctx": {}, "current_id": "node:13", "expected_ids": ["node:13"]},
		{"ctx": {}, "current_id": "node:12", "expected_ids": ["node:12"]},
		{"ctx": {}, "current_id": "node:11", "expected_ids": ["node:11"]},
		{"ctx": {}, "current_id": "node:15", "expected_ids": ["node:15"]},
	]
	
	func test_init_with_match_node(params: Dictionary = use_parameters(test_init_with_match_node_cases)) -> void:
		# Arrange
		var current_node: ParleyNodeAst = test_dialogue_sequence_ast_with_match_node.nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == params['current_id']).front()
		var expected: Array = TestUtils._resolve_expected(params, test_dialogue_sequence_ast_with_match_node)
		var ctx_data: Dictionary = params.get('ctx', {})
		ctx = ParleyContext.create(test_dialogue_sequence_ast_with_match_node, ctx_data)
		
		# Act
		result = await ParleyDialogueSequenceAst.init(ctx, test_dialogue_sequence_ast_with_match_node, current_node)

		# Assert
		assert_eq_deep(result.node_asts.map(TestUtils.map_to_dict), expected.map(TestUtils.map_to_dict))


	var test_init_from_jump_node_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "node:1", "expected_ids": ["node:2"], "expected_dialogue_sequence_ref": "from_jump_node_input.ds" },
		{"ctx": {}, "current_id": "node:2", "expected_ids": ["node:2"], "expected_dialogue_sequence_ref": "from_jump_node_input.ds" },
		{"ctx": {}, "current_id": "node:3", "expected_ids": ["node:2"], "expected_dialogue_sequence_ref": "to_jump_node_input.ds" },
	]

	func test_init_from_jump_node(params: Dictionary = use_parameters(test_init_from_jump_node_cases)) -> void:
		# Arrange
		var expected_dialogue_sequence_ref: String = params.get('expected_dialogue_sequence_ref', 'unknown')

		var current_node: ParleyNodeAst = test_dialogue_sequence_ast_from_jump_node.nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == params['current_id']).front()
		var expected_ids: Array = TestUtils._resolve_expected(params, test_dialogue_sequence_ast_to_jump_node if expected_dialogue_sequence_ref.begins_with('to_') else test_dialogue_sequence_ast_from_jump_node)
		var ctx_data: Dictionary = params.get('ctx', {})
		ctx = ParleyContext.create(test_dialogue_sequence_ast_from_jump_node, ctx_data)
		
		# Act
		result = await ParleyDialogueSequenceAst.init(ctx, test_dialogue_sequence_ast_from_jump_node, current_node)

		# Assert
		assert_eq(result.dialogue_sequence.resource_path.get_file(), expected_dialogue_sequence_ref)
		assert_eq_deep(result.node_asts.map(TestUtils.map_to_dict), expected_ids.map(TestUtils.map_to_dict))
	#endregion

	#region RUN
	var test_run_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "node:1", "expected_ids": ["node:3"]},
		{"ctx": {}, "current_id": "node:3", "expected_ids": ["node:4"]},
		{"ctx": {}, "current_id": "node:4", "expected_ids": ["node:7"]},
		{"ctx": {"bob_has_coffee": false}, "current_id": "node:4", "expected_ids": ["node:17"]},
		{"ctx": {"bob_has_coffee": false, "alice_gave_coffee": false}, "current_id": "node:4", "expected_ids": ["node:19"]},
		{"ctx": {}, "current_id": "node:7", "expected_ids": ["node:8", "node:13"]},
		{"ctx": {}, "current_id": "node:8", "expected_ids": ["node:10"]},
		{"ctx": {}, "current_id": "node:10", "expected_ids": ["node:11"]},
		{"ctx": {}, "current_id": "node:11", "expected_ids": ["node:12"]},
		{"ctx": {}, "current_id": "node:12", "expected_ids": ["node:21"]},
		{"ctx": {}, "current_id": "node:13", "expected_ids": ["node:14"]},
		{"ctx": {}, "current_id": "node:14", "expected_ids": ["node:15"]},
		{"ctx": {}, "current_id": "node:15", "expected_ids": ["node:21"]},
	]


	func test_run(params: Dictionary = use_parameters(test_run_cases)) -> void:
		# Arrange
		var current_node: ParleyNodeAst = test_dialogue_sequence_ast.nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == params['current_id'])[0]
		var expected: Array = TestUtils._resolve_expected(params, test_dialogue_sequence_ast)
		var ctx_data: Dictionary = params.get('ctx', {})
		ctx = ParleyContext.create(test_dialogue_sequence_ast, ctx_data)
		
		# Act
		result = await ParleyDialogueSequenceAst.run(ctx, test_dialogue_sequence_ast, current_node)

		# Assert
		assert_eq_deep(result.node_asts.map(TestUtils.map_to_dict), expected.map(TestUtils.map_to_dict))


	var test_run_sort_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "node:6", "expected_ids": ["node:9", "node:10", "node:11"]},
		{"ctx": {}, "current_id": "node:8", "expected_ids": ["node:14", "node:12", "node:13"]},
	]

	func test_run_sort_by_y_position(params: Dictionary = use_parameters(test_run_sort_cases)) -> void:
		# Arrange
		var current_node: ParleyNodeAst = test_dialogue_sequence_ast_sort_cases.nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == params['current_id'])[0]
		var expected: Array = TestUtils._resolve_expected(params, test_dialogue_sequence_ast_sort_cases)
		var ctx_data: Dictionary = params.get('ctx', {})
		ctx = ParleyContext.create(test_dialogue_sequence_ast_sort_cases, ctx_data)
		
		# Act
		result = await ParleyDialogueSequenceAst.run(ctx, test_dialogue_sequence_ast_sort_cases, current_node)

		# Assert
		assert_eq_deep(result.node_asts.map(func(i: ParleyDialogueOptionNodeAst) -> String: return i.text), ['Top', 'Middle', 'Bottom'])
		assert_eq_deep(result.node_asts.map(TestUtils.map_to_dict), expected.map(TestUtils.map_to_dict))
	
	var test_run_with_match_node_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "node:1", "expected_ids": ["node:16"]},
		{"ctx": {"alice_coffee_status": "NEEDS_COFFEE"}, "current_id": "node:16", "expected_ids": ["node:3"]},
		{"ctx": {"alice_coffee_status": "NEEDS_MORE_COFFEE"}, "current_id": "node:16", "expected_ids": ["node:4"]},
		{"ctx": {"alice_coffee_status": "NEEDS_EVEN_MORE_COFFEE"}, "current_id": "node:16", "expected_ids": ["node:5"]},
		{"ctx": {"alice_coffee_status": "INVALID"}, "current_id": "node:16", "expected_ids": ["node:6"]},
		{"ctx": {}, "current_id": "node:16", "expected_ids": ["node:6"]},
		{"ctx": {}, "current_id": "node:3", "expected_ids": ["node:8"]},
		{"ctx": {}, "current_id": "node:4", "expected_ids": ["node:8"]},
		{"ctx": {}, "current_id": "node:5", "expected_ids": ["node:8"]},
		{"ctx": {}, "current_id": "node:6", "expected_ids": ["node:8"]},
		{"ctx": {"ball": 1}, "current_id": "node:8", "expected_ids": ["node:10"]},
		{"ctx": {"ball": 2}, "current_id": "node:8", "expected_ids": ["node:14"]},
		{"ctx": {"ball": 6}, "current_id": "node:8", "expected_ids": ["node:13"]},
		{"ctx": {"ball": 5}, "current_id": "node:8", "expected_ids": ["node:12"]},
		{"ctx": {"ball": 7}, "current_id": "node:8", "expected_ids": ["node:11"]},
		{"ctx": {}, "current_id": "node:8", "expected_ids": ["node:11"]},
		{"ctx": {}, "current_id": "node:11", "expected_ids": ["node:15"]},
	]
	
	func test_run_with_match_node(params: Dictionary = use_parameters(test_run_with_match_node_cases)) -> void:
		# Arrange
		var current_node: ParleyNodeAst = test_dialogue_sequence_ast_with_match_node.nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == params['current_id']).front()
		var expected: Array = TestUtils._resolve_expected(params, test_dialogue_sequence_ast_with_match_node)
		var ctx_data: Dictionary = params.get('ctx', {})
		ctx = ParleyContext.create(test_dialogue_sequence_ast_with_match_node, ctx_data)
		
		# Act
		result = await ParleyDialogueSequenceAst.run(ctx, test_dialogue_sequence_ast_with_match_node, current_node)

		# Assert
		assert_eq_deep(result.node_asts.map(TestUtils.map_to_dict), expected.map(TestUtils.map_to_dict))


	var test_run_from_jump_node_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "node:1", "expected_ids": ["node:2"], "expected_dialogue_sequence_ref": "from_jump_node_input.ds" },
		{"ctx": {}, "current_id": "node:2", "expected_ids": ["node:2"], "expected_dialogue_sequence_ref": "to_jump_node_input.ds" },
	]

	func test_run_from_jump_node(params: Dictionary = use_parameters(test_run_from_jump_node_cases)) -> void:
		# Arrange
		var expected_dialogue_sequence_ref: String = params.get('expected_dialogue_sequence_ref', 'unknown')

		var current_node: ParleyNodeAst = test_dialogue_sequence_ast_from_jump_node.nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == params['current_id']).front()
		var expected_ids: Array = TestUtils._resolve_expected(params, test_dialogue_sequence_ast_to_jump_node if expected_dialogue_sequence_ref.begins_with('to_') else test_dialogue_sequence_ast_from_jump_node)
		var ctx_data: Dictionary = params.get('ctx', {})
		ctx = ParleyContext.create(test_dialogue_sequence_ast_from_jump_node, ctx_data)
		
		# Act
		result = await ParleyDialogueSequenceAst.run(ctx, test_dialogue_sequence_ast_from_jump_node, current_node)

		# Assert
		assert_eq(result.dialogue_sequence.resource_path.get_file(), expected_dialogue_sequence_ref)
		assert_eq_deep(result.node_asts.map(TestUtils.map_to_dict), expected_ids.map(TestUtils.map_to_dict))
	#endregion


class Test_translations:
	extends GutTest


	var result: ParleyRunResult
	var ctx: ParleyContext
	var test_dialogue_sequence_ast_pot_translations: ParleyDialogueSequenceAst = load('res://tests/fixtures/basic_pot_translations.ds')
	var test_dialogue_sequence_ast_csv_translations: ParleyDialogueSequenceAst = load('res://tests/fixtures/basic_csv_translations.ds')
	var original_locale: String = TranslationServer.get_locale()
	var original_translation_mode: Variant = ProjectSettings.get(ParleyConstants.TRANSLATION_MODE)


	func after_each() -> void:
		if ctx:
			ctx.free()
		if result:
			result.free()
		TranslationServer.set_locale(original_locale)
		ProjectSettings.set(ParleyConstants.TRANSLATION_MODE, original_translation_mode)
	

	var test_init_pot_translations_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "node:2", "expected_ids": ["node:2"], "locale": "en", "expected_texts": ["[PO]: Some text in English."]},
		{"ctx": {}, "current_id": "node:2", "expected_ids": ["node:2"], "locale": "fr", "expected_texts": ["[PO]: Quelques textes en anglais."]},
		{"ctx": {}, "current_id": "node:3", "expected_ids": ["node:3"], "locale": "en", "expected_texts": ["[PO]: Some option in English."]},
		{"ctx": {}, "current_id": "node:3", "expected_ids": ["node:3"], "locale": "fr", "expected_texts": ["[PO]: Quelques options en anglais."]},
		{"ctx": {}, "current_id": "node:4", "expected_ids": ["node:4"], "locale": "en", "expected_texts": ["[PO]: Another option in English."]},
		{"ctx": {}, "current_id": "node:4", "expected_ids": ["node:4"], "locale": "fr", "expected_texts": ["[PO]: Une autre option en anglais."]},
		{"ctx": {}, "current_id": "node:5", "expected_ids": ["node:5"], "locale": "en", "expected_texts": ["[PO]: Some text with no translation."]},
		{"ctx": {}, "current_id": "node:5", "expected_ids": ["node:5"], "locale": "fr", "expected_texts": ["[PO]: Some text with no translation."]},
	]


	func test_init_pot_translations(params: Dictionary = use_parameters(test_init_pot_translations_cases)) -> void:
		# Arrange
		var current_node: ParleyNodeAst = test_dialogue_sequence_ast_pot_translations.nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == params['current_id'])[0]
		var expected_ids: Array = params.get('expected_ids', [])
		var expected_texts: Array = params.get('expected_texts', [])
		var ctx_data: Dictionary = params.get('ctx', {})
		var locale: String = params.get('locale', 'en')
		ctx = ParleyContext.create(test_dialogue_sequence_ast_pot_translations, ctx_data)
		ProjectSettings.set(ParleyConstants.TRANSLATION_MODE, ParleyContext.TranslationMode.PO)
		
		# Act
		TranslationServer.set_locale(locale)
		result = await ParleyDialogueSequenceAst.init(ctx, test_dialogue_sequence_ast_pot_translations, current_node)

		# Assert
		assert_eq_deep(result.node_asts.map(func (n: ParleyNodeAst) -> String: return n.id), expected_ids)
		assert_eq_deep(result.node_asts.map(func (n: ParleyNodeAst) -> String: return n.get('text')), expected_texts)


	var test_init_csv_translations_cases: Array[Dictionary] = [
		{"ctx": {}, "current_id": "node:2", "expected_ids": ["node:2"], "locale": "en", "expected_texts": ["[CSV]: Some text in English."]},
		{"ctx": {}, "current_id": "node:2", "expected_ids": ["node:2"], "locale": "fr", "expected_texts": ["[CSV]: Quelques textes en anglais."]},
		{"ctx": {}, "current_id": "node:3", "expected_ids": ["node:3"], "locale": "en", "expected_texts": ["[CSV]: Some option in English."]},
		{"ctx": {}, "current_id": "node:3", "expected_ids": ["node:3"], "locale": "fr", "expected_texts": ["[CSV]: Quelques options en anglais."]},
		{"ctx": {}, "current_id": "node:4", "expected_ids": ["node:4"], "locale": "en", "expected_texts": ["[CSV]: Another option in English."]},
		{"ctx": {}, "current_id": "node:4", "expected_ids": ["node:4"], "locale": "fr", "expected_texts": ["[CSV]: Une autre option en anglais."]},
		{"ctx": {}, "current_id": "node:5", "expected_ids": ["node:5"], "locale": "en", "expected_texts": ["[CSV]: Some text with no translation."]},
		{"ctx": {}, "current_id": "node:5", "expected_ids": ["node:5"], "locale": "fr", "expected_texts": ["[CSV]: Some text with no translation."]},
	]


	func test_init_csv_translations(params: Dictionary = use_parameters(test_init_csv_translations_cases)) -> void:
		# Arrange
		var current_node: ParleyNodeAst = test_dialogue_sequence_ast_csv_translations.nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == params['current_id'])[0]
		var expected_ids: Array = params.get('expected_ids', [])
		var expected_texts: Array = params.get('expected_texts', [])
		var ctx_data: Dictionary = params.get('ctx', {})
		var locale: String = params.get('locale', 'en')
		ctx = ParleyContext.create(test_dialogue_sequence_ast_csv_translations, ctx_data)
		ProjectSettings.set(ParleyConstants.TRANSLATION_MODE, ParleyContext.TranslationMode.CSV)
		
		# Act
		TranslationServer.set_locale(locale)
		result = await ParleyDialogueSequenceAst.init(ctx, test_dialogue_sequence_ast_csv_translations, current_node)

		# Assert
		assert_eq_deep(result.node_asts.map(func (n: ParleyNodeAst) -> String: return n.id), expected_ids)
		assert_eq_deep(result.node_asts.map(func (n: ParleyNodeAst) -> String: return n.get('text')), expected_texts)


class Test_add_edge:
	extends GutTest
	var test_add_edge_cases: Array[Dictionary] = [
		{
			"current_edges": [],
			"edge": {"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
			"expected": {
				"added": true,
				"emitted": true,
				"edges": [
					{"id": "edge:1", "from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override}
				]
			},
		},
		{
			"current_edges": [
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"edge": {"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
			"expected": {
				"added": false,
				"emitted": false,
				"edges": [
					{"id": "edge:1", "from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override}
				]
			},
		},
	]
	
	func test_add_edge(params: Dictionary = use_parameters(test_add_edge_cases)) -> void:
		# Arrange
		var current_edges: Array = params.get('current_edges', [])
		var edge: Dictionary = params.get('edge', {})
		var dialogue_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new("", [], current_edges)
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
		var result: ParleyEdgeAst = dialogue_ast.add_new_edge(from_node, from_slot, to_node, to_slot)

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
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"edges": [
				{"from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:3", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"expected": {
				"added": 2,
				"emitted": true,
				"edges": [
					{"id": "edge:1", "from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override},
					{"id": "edge:2", "from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override},
					{"id": "edge:3", "from_node": "node:3", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override}
				]
			},
		},
		{
			"current_edges": [
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
			],
			"edges": [
				{"from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:3", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"expected": {
				"added": 1,
				"emitted": true,
				"edges": [
					{"id": "edge:1", "from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override},
					{"id": "edge:2", "from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override},
					{"id": "edge:3", "from_node": "node:3", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override}
				]
			},
		},
		{
			"current_edges": [
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
			],
			"edges": [
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"expected": {
				"added": 0,
				"emitted": false,
				"edges": [
					{"id": "edge:1", "from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override},
					{"id": "edge:2", "from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override}
				]
			},
		},
	]
	
	func test_add_edges(params: Dictionary = use_parameters(test_add_edges_cases)) -> void:
		# Arrange
		var current_edges: Array = params.get('current_edges', [])
		var raw_edges: Array = params.get('edges', [])
		var edges: Array[ParleyEdgeAst] = []
		for edge: Dictionary in raw_edges:
			var from_node: String = edge.get('from_node')
			var from_slot: int = edge.get('from_slot')
			var to_node: String = edge.get('to_node')
			var to_slot: int = edge.get('to_slot')
			# The edge ID doesn't matter here as it is handled internally
			edges.append(ParleyEdgeAst.new("", from_node, from_slot, to_node, to_slot))
		var dialogue_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new("", [], current_edges)
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
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"edge": {"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
			"expected": {
				"removed": 1,
				"emitted": true,
				"edges": []
			},
		},
		{
			"current_edges": [
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"edge": {"from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
			"expected": {
				"removed": 0,
				"emitted": false,
				"edges": [
					{"id": "edge:1", "from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override}
				]
			},
		},
	]
	
	func test_remove_edge(params: Dictionary = use_parameters(test_remove_edge_cases)) -> void:
		# Arrange
		var current_edges: Array = params.get('current_edges', [])
		var edge: Dictionary = params.get('edge', {})
		var dialogue_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new("", [], current_edges)
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
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:3", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"edges": [
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"expected": {
				"removed": 2,
				"emitted": true,
				"edges": [
					{"id": "edge:3", "from_node": "node:3", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override}
				]
			},
		},
		{
			"current_edges": [
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:3", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"edges": [
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"expected": {
				"removed": 1,
				"emitted": true,
				"edges": [
					{"id": "edge:2", "from_node": "node:3", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override}
				]
			},
		},
		{
			"current_edges": [
				{"from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1},
				{"from_node": "node:3", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"edges": [
				{"from_node": "node:2", "from_slot": 0, "to_node": "node:2", "to_slot": 1}
			],
			"expected": {
				"removed": 0,
				"emitted": false,
				"edges": [
					{"id": "edge:1", "from_node": "node:1", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override},
					{"id": "edge:2", "from_node": "node:3", "from_slot": 0, "to_node": "node:2", "to_slot": 1, "should_override_colour": false, "colour_override": ParleyEdgeAst.default_colour_override}
				]
			},
		},
	]
	
	func test_remove_edges(params: Dictionary = use_parameters(test_remove_edges_cases)) -> void:
		# Arrange
		var current_edges: Array = params.get('current_edges', [])
		var raw_edges: Array = params.get('edges', [])
		var edges: Array[ParleyEdgeAst] = []
		for edge: Dictionary in raw_edges:
			var from_node: String = edge.get('from_node')
			var from_slot: int = edge.get('from_slot')
			var to_node: String = edge.get('to_node')
			var to_slot: int = edge.get('to_slot')
			# # The edge ID doesn't matter here as it is handled internally
			edges.append(ParleyEdgeAst.new("", from_node, from_slot, to_node, to_slot))
		var dialogue_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new("", [], current_edges)
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


class Test_generate_text_translation_keys extends GutTest:

	var test_dialogue_sequence_ast: ParleyDialogueSequenceAst


	func before_each() -> void:
		test_dialogue_sequence_ast = load('res://tests/fixtures/generate_text_translation_keys_translations.ds')

	
	func after_each() -> void:
		if test_dialogue_sequence_ast:
			test_dialogue_sequence_ast = null


	var test_generate_text_translation_keys_cases: Array[Dictionary] = [
		{
			"expected": [
				{ "id": "node:1", "text_translation_key": null },
				{ "id": "node:2", "text_translation_key": "SOME_TEXT" },
				{ "id": "node:3", "text_translation_key": "CSV_SOME_OPTION_IN_ENGLISH__BI26W64M677X6_3_TEXT" },
				{ "id": "node:4", "text_translation_key": "CSV_ANOTHER_OPTION_IN_ENGLISH__BI26W64M677X6_4_TEXT" },
				{ "id": "node:5", "text_translation_key": "CSV_SOME_TEXT_WITH_NO_TRANSLATIO__BI26W64M677X6_5_TEXT" },
				{ "id": "node:6", "text_translation_key": "SAME_OPTION_TEXT" },
				{ "id": "node:7", "text_translation_key": "SAME_OPTION_TEXT" },
			],
		},
	]

	func test_generate_text_translation_keys(params: Dictionary = use_parameters(test_generate_text_translation_keys_cases)) -> void:
		# Arrange
		# Note, loading the Dialogue Sequence as is may cause issues in the future
		# when we have multiple tests. However, not an issue for now.
		var dialogue_sequence_ast: ParleyDialogueSequenceAst = test_dialogue_sequence_ast
		var expected: Array = params.get('expected', {})

		# Act
		var result: bool = dialogue_sequence_ast.generate_text_translation_keys()

		# Assert
		assert_eq(result, true)
		for node_ast: ParleyNodeAst in dialogue_sequence_ast.nodes:
			var expected_node_index: int = expected.find_custom(func(node: Dictionary) -> bool: return node.get('id') == node_ast.id)
			assert(expected_node_index != -1, "Node AST %s not found in Dialogue Sequence AST %s" % [node_ast, dialogue_sequence_ast])
			var expected_node: Dictionary = expected[expected_node_index]
			var text_translation_key: Variant = node_ast.get('text_translation_key')
			var expected_text_translation_key: Variant = expected_node.get('text_translation_key', 'invalid')
			@warning_ignore("UNSAFE_CALL_ARGUMENT") # We know this is fine
			assert_eq(text_translation_key, expected_text_translation_key)



class TestUtils:
	static func load_dialogue_sequence_ast(path: String) -> ParleyDialogueSequenceAst:
		var raw_test_dialogue_sequence_ast: ParleyDialogueSequenceAst = load(path)
		var test_dialogue_sequence_ast_dict: Dictionary = JSON.parse_string(JSON.stringify(raw_test_dialogue_sequence_ast.to_dict()))
		var title: String = test_dialogue_sequence_ast_dict.get('title')
		var nodes: Array = test_dialogue_sequence_ast_dict.get('nodes')
		var edges: Array = test_dialogue_sequence_ast_dict.get('edges')
		return ParleyDialogueSequenceAst.new(title, nodes, edges)


	static func map_to_dict(node: ParleyNodeAst) -> Dictionary:
		var d: Dictionary = inst_to_dict(node)
		var _path_result: bool = d.erase('@path')
		var _subpath_result: bool = d.erase('@subpath')
		return d


	static func _resolve_expected(params: Dictionary, dialogue_ast: ParleyDialogueSequenceAst) -> Array:
		var expected: Array = []
		if params.get('expected', null):
			expected = params['expected']
		else:
			var expected_ids: PackedStringArray = params['expected_ids']
			for expected_id: String in expected_ids:
				var found: Array[ParleyNodeAst] = dialogue_ast.nodes.filter(func(node: ParleyNodeAst) -> bool: return node.id == expected_id)
				if found.size() > 0:
					expected.append(found.front())
		return expected
