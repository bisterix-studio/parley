# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends GutTest


class Test_translation_generate_key:
	extends GutTest


	var test_dialogue_sequence_ast: ParleyDialogueSequenceAst = load('res://tests/fixtures/basic_ast_node_generation_input.ds')


	#region INIT
	var test_basic_cases: Array[Dictionary] = [
		{"dialogue_sequence_ast": test_dialogue_sequence_ast, "node_ast_id": "node:3", "field": "text", "expected": "LOOK_I_MADE_A_THING__DM0PDRAMHS72H_3_TEXT"},
		{"dialogue_sequence_ast": test_dialogue_sequence_ast, "node_ast_id": "node:19", "field": "text", "expected": "I_NEED_COFFEE__DM0PDRAMHS72H_19_TEXT"},
		{"dialogue_sequence_ast": test_dialogue_sequence_ast, "node_ast_id": "node:22", "field": "text", "expected": "SOME_REALLY_REALLY_REALLY_LONG_D__DM0PDRAMHS72H_22_TEXT"},
		{"dialogue_sequence_ast": test_dialogue_sequence_ast, "node_ast_id": "node:23", "field": "text", "expected": "SP_ACES_RETURNS_TAB_1_TAB_2__DM0PDRAMHS72H_23_TEXT"},
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
