# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends GutTest


const ParleyImport = preload("res://addons/parley/parley_import.gd")


class Test_parley_import:
	extends GutTest


	var test_dialogue_sequence_ast: ParleyDialogueSequenceAst
	var tmp_dir: DirAccess
	var existing_csv_path: String
	var raw_test_dialogue_sequence_ast: ParleyDialogueSequenceAst = load('res://tests/fixtures/basic_csv_translations.ds')
	

	func before_each() -> void:
		var test_dialogue_sequence_ast_dict: Dictionary = JSON.parse_string(JSON.stringify(raw_test_dialogue_sequence_ast.to_dict()))
		var title: String = test_dialogue_sequence_ast_dict.get('title')
		var nodes: Array = test_dialogue_sequence_ast_dict.get('nodes')
		var edges: Array = test_dialogue_sequence_ast_dict.get('edges')
		test_dialogue_sequence_ast = ParleyDialogueSequenceAst.new(title, nodes, edges)
		tmp_dir = DirAccess.create_temp('test_import_dialogue_text_translation')
		existing_csv_path = TestUtils.create_empty_csv(tmp_dir)
	

	func after_each() -> void:
		tmp_dir = null
		test_dialogue_sequence_ast = null


	var test_import_dialogue_text_translation_cases: Array[Dictionary] = [
		# No changes
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				["keys", "en"],
				["SOME_TEXT", "[CSV]: Some text in English."]
			],
			"expected": [
				ParleyStartNodeAst.new("node:1", Vector2(440.0, 1120.0)),
				ParleyDialogueNodeAst.new("node:2", Vector2(760.0, 1080.0), "uid://ceouii84qmu0w::alice", "[CSV]: Some text in English.", "SOME_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:3", Vector2(1360.0, 880.0), "uid://ceouii84qmu0w::bob", "[CSV]: Some option in English.", ""),
				ParleyDialogueOptionNodeAst.new("node:4", Vector2(1360.0, 1300.0), "uid://ceouii84qmu0w::carol", "[CSV]: Another option in English.", ""),
				ParleyDialogueNodeAst.new("node:5", Vector2(1940.0, 1040.0), "uid://ceouii84qmu0w::dave", "[CSV]: Some text with no translation.", ""),
				ParleyDialogueOptionNodeAst.new("node:6", Vector2(2520.0, 920.0), "uid://ceouii84qmu0w::alice", "[CSV]: Same option text in English.", "SAME_OPTION_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:7", Vector2(2520.0, 1260.0), "uid://ceouii84qmu0w::alice", "[CSV]: Same option text in English.", "SAME_OPTION_TEXT"),
			],
		},
		# No changes with extra locale present
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				["keys", "en", "fr"],
				["SOME_TEXT", "[CSV]: Some text in English.", "[CSV]: Some text in French."]
			],
			"expected": [
				ParleyStartNodeAst.new("node:1", Vector2(440.0, 1120.0)),
				ParleyDialogueNodeAst.new("node:2", Vector2(760.0, 1080.0), "uid://ceouii84qmu0w::alice", "[CSV]: Some text in English.", "SOME_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:3", Vector2(1360.0, 880.0), "uid://ceouii84qmu0w::bob", "[CSV]: Some option in English.", ""),
				ParleyDialogueOptionNodeAst.new("node:4", Vector2(1360.0, 1300.0), "uid://ceouii84qmu0w::carol", "[CSV]: Another option in English.", ""),
				ParleyDialogueNodeAst.new("node:5", Vector2(1940.0, 1040.0), "uid://ceouii84qmu0w::dave", "[CSV]: Some text with no translation.", ""),
				ParleyDialogueOptionNodeAst.new("node:6", Vector2(2520.0, 920.0), "uid://ceouii84qmu0w::alice", "[CSV]: Same option text in English.", "SAME_OPTION_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:7", Vector2(2520.0, 1260.0), "uid://ceouii84qmu0w::alice", "[CSV]: Same option text in English.", "SAME_OPTION_TEXT"),
			],
		},
		# Relevant node updated, others unchanged
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				["keys", "en", "fr"],
				["SOME_TEXT", "[CSV]: Some new text in English.", "[CSV]: Some new text in French."],
			],
			"expected": [
				ParleyStartNodeAst.new("node:1", Vector2(440.0, 1120.0)),
				ParleyDialogueNodeAst.new("node:2", Vector2(760.0, 1080.0), "uid://ceouii84qmu0w::alice", "[CSV]: Some new text in English.", "SOME_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:3", Vector2(1360.0, 880.0), "uid://ceouii84qmu0w::bob", "[CSV]: Some option in English.", ""),
				ParleyDialogueOptionNodeAst.new("node:4", Vector2(1360.0, 1300.0), "uid://ceouii84qmu0w::carol", "[CSV]: Another option in English.", ""),
				ParleyDialogueNodeAst.new("node:5", Vector2(1940.0, 1040.0), "uid://ceouii84qmu0w::dave", "[CSV]: Some text with no translation.", ""),
				ParleyDialogueOptionNodeAst.new("node:6", Vector2(2520.0, 920.0), "uid://ceouii84qmu0w::alice", "[CSV]: Same option text in English.", "SAME_OPTION_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:7", Vector2(2520.0, 1260.0), "uid://ceouii84qmu0w::alice", "[CSV]: Same option text in English.", "SAME_OPTION_TEXT"),
			],
		},
		# Multiple nodes updated, others unchanged
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				["keys", "en", "fr"],
				["SAME_OPTION_TEXT", "[CSV]: New same option text in English.", "[CSV]: New same option text in French."]
			],
			"expected": [
				ParleyStartNodeAst.new("node:1", Vector2(440.0, 1120.0)),
				ParleyDialogueNodeAst.new("node:2", Vector2(760.0, 1080.0), "uid://ceouii84qmu0w::alice", "[CSV]: Some text in English.", "SOME_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:3", Vector2(1360.0, 880.0), "uid://ceouii84qmu0w::bob", "[CSV]: Some option in English.", ""),
				ParleyDialogueOptionNodeAst.new("node:4", Vector2(1360.0, 1300.0), "uid://ceouii84qmu0w::carol", "[CSV]: Another option in English.", ""),
				ParleyDialogueNodeAst.new("node:5", Vector2(1940.0, 1040.0), "uid://ceouii84qmu0w::dave", "[CSV]: Some text with no translation.", ""),
				ParleyDialogueOptionNodeAst.new("node:6", Vector2(2520.0, 920.0), "uid://ceouii84qmu0w::alice", "[CSV]: New same option text in English.", "SAME_OPTION_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:7", Vector2(2520.0, 1260.0), "uid://ceouii84qmu0w::alice", "[CSV]: New same option text in English.", "SAME_OPTION_TEXT"),
			],
		},
		# Unknown keys ignored, nodes unaffected
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				["keys", "en", "fr"],
				["SOME_UNKNOWN_TEXT", "[CSV]: Some unknown text in English.", "[CSV]: Some unknown text in French."]
			],
			"expected": [
				ParleyStartNodeAst.new("node:1", Vector2(440.0, 1120.0)),
				ParleyDialogueNodeAst.new("node:2", Vector2(760.0, 1080.0), "uid://ceouii84qmu0w::alice", "[CSV]: Some text in English.", "SOME_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:3", Vector2(1360.0, 880.0), "uid://ceouii84qmu0w::bob", "[CSV]: Some option in English.", ""),
				ParleyDialogueOptionNodeAst.new("node:4", Vector2(1360.0, 1300.0), "uid://ceouii84qmu0w::carol", "[CSV]: Another option in English.", ""),
				ParleyDialogueNodeAst.new("node:5", Vector2(1940.0, 1040.0), "uid://ceouii84qmu0w::dave", "[CSV]: Some text with no translation.", ""),
				ParleyDialogueOptionNodeAst.new("node:6", Vector2(2520.0, 920.0), "uid://ceouii84qmu0w::alice", "[CSV]: Same option text in English.", "SAME_OPTION_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:7", Vector2(2520.0, 1260.0), "uid://ceouii84qmu0w::alice", "[CSV]: Same option text in English.", "SAME_OPTION_TEXT"),
			],
		},
		# When keys is not set to the first column, no changes will be made
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				["en", "keys", "fr"],
				["[CSV]: Some new text in English.", "SOME_TEXT", "[CSV]: Some new text in French."],
			],
			"expected_result": [ERR_INVALID_DATA, 'Unable to import: cannot find valid translation index: (headers:["en", "keys", "fr"], line:["en", "keys", "fr"], locale:en)'],
			"expected": [
				ParleyStartNodeAst.new("node:1", Vector2(440.0, 1120.0)),
				ParleyDialogueNodeAst.new("node:2", Vector2(760.0, 1080.0), "uid://ceouii84qmu0w::alice", "[CSV]: Some text in English.", "SOME_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:3", Vector2(1360.0, 880.0), "uid://ceouii84qmu0w::bob", "[CSV]: Some option in English.", ""),
				ParleyDialogueOptionNodeAst.new("node:4", Vector2(1360.0, 1300.0), "uid://ceouii84qmu0w::carol", "[CSV]: Another option in English.", ""),
				ParleyDialogueNodeAst.new("node:5", Vector2(1940.0, 1040.0), "uid://ceouii84qmu0w::dave", "[CSV]: Some text with no translation.", ""),
				ParleyDialogueOptionNodeAst.new("node:6", Vector2(2520.0, 920.0), "uid://ceouii84qmu0w::alice", "[CSV]: Same option text in English.", "SAME_OPTION_TEXT"),
				ParleyDialogueOptionNodeAst.new("node:7", Vector2(2520.0, 1260.0), "uid://ceouii84qmu0w::alice", "[CSV]: Same option text in English.", "SAME_OPTION_TEXT"),
			],
		},
	]


	func test_import_dialogue_text_translation_csv(params: Dictionary = use_parameters(test_import_dialogue_text_translation_cases)) -> void:
		# Arrange
		var existing: Variant = params.get("existing")
		var path: String = tmp_dir.get_current_dir().path_join("export_%s.csv" % [str(int(Time.get_unix_time_from_system()))])
		if existing:
			if is_instance_of(existing, TYPE_ARRAY):
				path = existing_csv_path
				TestUtils.create_csv_fixture(path, existing)
			elif is_instance_of(existing, TYPE_STRING):
				var test_dir: DirAccess = DirAccess.open('res://tests')
				var fixture_path: String = existing
				var absolute_fixture_path: String = test_dir.get_current_dir().path_join(fixture_path)
				var _result: int = DirAccess.copy_absolute(absolute_fixture_path, path)
		var file_type: ParleyImportModal.FileType = ParleyImportModal.FileType.Csv
		var expected: Array = params.get("expected")
		var expected_result: Array = params.get("expected_result", [OK, ""])
		
		# Act
		var result: Array = ParleyImport.import_dialogue_text_translation(file_type, test_dialogue_sequence_ast, path)

		# Assert
		assert_eq(result, expected_result)
		assert_typeof(expected, TYPE_ARRAY)
		assert_gt(expected.size(), 0)
		assert_eq_deep(
			test_dialogue_sequence_ast.nodes.map(func(node: ParleyNodeAst) -> Dictionary: return node.to_dict()),
			expected.map(func(node: ParleyNodeAst) -> Dictionary: return node.to_dict())
		)


class TestUtils:
	static func create_empty_csv(dir: DirAccess) -> String:
		var path: String = dir.get_current_dir().path_join("export_fixture_%s.csv" % [str(int(Time.get_unix_time_from_system()))])
		var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.close()
		return path


	static func create_csv_fixture(path: String, input: Variant) -> void:
		if not is_instance_of(input, TYPE_ARRAY):
			return
		var file: FileAccess = FileAccess.open(path, FileAccess.READ_WRITE)
		if not file:
			return
		for line: PackedStringArray in input:
			var _result: int = file.store_csv_line(line)
		file.close()
