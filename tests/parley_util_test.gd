# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends GutTest


class Test_translation_generate_key:
	extends GutTest


	var test_dialogue_sequence_ast: ParleyDialogueSequenceAst = load('res://tests/fixtures/basic_ast_node_generation_input.ds')


	#region INIT
	var test_basic_cases: Array[Dictionary] = [
		{"dialogue_sequence_ast": test_dialogue_sequence_ast, "node_ast_id": "node:3", "field": "text", "expected": "look_i_made_a_thing__dm0pdramhs72h_3_text"},
		{"dialogue_sequence_ast": test_dialogue_sequence_ast, "node_ast_id": "node:19", "field": "text", "expected": "i_need_coffee__dm0pdramhs72h_19_text"},
		{"dialogue_sequence_ast": test_dialogue_sequence_ast, "node_ast_id": "node:22", "field": "text", "expected": "some_really_really_really_long_d__dm0pdramhs72h_22_text"},
		{"dialogue_sequence_ast": test_dialogue_sequence_ast, "node_ast_id": "node:23", "field": "text", "expected": "sp_aces_returns_tab_1_tab_2__dm0pdramhs72h_23_text"},
	]


	func test_basic(params: Dictionary = use_parameters(test_basic_cases)) -> void:
		# Arrange
		var node_ast_id: String = params.get('node_ast_id', "UNABLE_TO_GET_NODE_AST_ID_FROM_PARAMS")
		var field: String = params.get('field', 'UNABLE_TO_GET_FIELD_FROM_PARAMS')
		var expected: String = params.get("expected", "UNABLE_TO_GET_EXPECTED_OUTPUT_STRING_FROM_PARAMS")
		var node_ast: ParleyNodeAst = test_dialogue_sequence_ast.find_node_by_id(node_ast_id)
		var input: String = node_ast.get(field)
		
		# Act
		var result: String = ParleyUtils.translation.generate_key(input, test_dialogue_sequence_ast, node_ast, field)

		# Assert
		assert_not_null(node_ast)
		assert_eq(result, expected)
