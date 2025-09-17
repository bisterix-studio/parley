# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends GutTest


const ParleyExport = preload("res://addons/parley/parley_export.gd")


class Test_parley_export:
	extends GutTest


	var test_dialogue_sequence_ast: ParleyDialogueSequenceAst = load('res://tests/fixtures/basic_csv_translations.ds')
	var tmp_dir: DirAccess
	var existing_csv_path: String
	

	func before_each() -> void:
		tmp_dir = DirAccess.create_temp('test_export_dialogue_text_translation')
		existing_csv_path = TestUtils.create_empty_csv(tmp_dir)
	

	func after_each() -> void:
		tmp_dir = null


	var test_export_dialogue_text_translation_cases: Array[Dictionary] = [
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"expected": [
				PackedStringArray(["keys", "en"]),
				PackedStringArray(["[CSV]: Some text in English.", "[CSV]: Some text in English."]),
				PackedStringArray(["[CSV]: Some option in English.", "[CSV]: Some option in English."]),
				PackedStringArray(["[CSV]: Another option in English.", "[CSV]: Another option in English."]),
				PackedStringArray(["[CSV]: Some text with no translation.", "[CSV]: Some text with no translation."]),
			],
		},
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				PackedStringArray(["keys", "en"]),
				PackedStringArray(["Existing row 1", "Existing row 1"]),
				PackedStringArray(["Existing row 2", "Existing row 2"]),
			],
			"expected": [
				PackedStringArray(["keys", "en"]),
				PackedStringArray(["Existing row 1", "Existing row 1"]),
				PackedStringArray(["Existing row 2", "Existing row 2"]),
				PackedStringArray(["[CSV]: Some text in English.", "[CSV]: Some text in English."]),
				PackedStringArray(["[CSV]: Some option in English.", "[CSV]: Some option in English."]),
				PackedStringArray(["[CSV]: Another option in English.", "[CSV]: Another option in English."]),
				PackedStringArray(["[CSV]: Some text with no translation.", "[CSV]: Some text with no translation."]),
			],
		},
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				PackedStringArray(["keys", "en", "fr", "es"]),
				PackedStringArray(["Existing keys row 1", "Existing en row 1", "Existing fr row 1", "Existing es row 1"]),
				PackedStringArray(["Existing keys row 2", "Existing en row 2", "Existing fr row 1", "Existing es row 1"]),
			],
			"expected": [
				PackedStringArray(["keys", "en", "fr", "es"]),
				PackedStringArray(["Existing keys row 1", "Existing en row 1", "Existing fr row 1", "Existing es row 1"]),
				PackedStringArray(["Existing keys row 2", "Existing en row 2", "Existing fr row 1", "Existing es row 1"]),
				PackedStringArray(["[CSV]: Some text in English.", "[CSV]: Some text in English.", "[CSV]: Some text in English.", "[CSV]: Some text in English."]),
				PackedStringArray(["[CSV]: Some option in English.", "[CSV]: Some option in English.", "[CSV]: Some option in English.", "[CSV]: Some option in English."]),
				PackedStringArray(["[CSV]: Another option in English.", "[CSV]: Another option in English.", "[CSV]: Another option in English.", "[CSV]: Another option in English."]),
				PackedStringArray(["[CSV]: Some text with no translation.", "[CSV]: Some text with no translation.", "[CSV]: Some text with no translation.", "[CSV]: Some text with no translation."]),
			],
		},
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				PackedStringArray(["keys", "fr", "es"]),
				PackedStringArray(["Existing keys row 1", "Existing fr row 1", "Existing es row 1"]),
				PackedStringArray(["Existing keys row 2", "Existing fr row 1", "Existing es row 1"]),
			],
			"expected": [
				PackedStringArray(["keys", "fr", "es"]),
				PackedStringArray(["Existing keys row 1", "Existing fr row 1", "Existing es row 1"]),
				PackedStringArray(["Existing keys row 2", "Existing fr row 1", "Existing es row 1"]),
				PackedStringArray(["[CSV]: Some text in English.", "[CSV]: Some text in English.", "[CSV]: Some text in English."]),
				PackedStringArray(["[CSV]: Some option in English.", "[CSV]: Some option in English.", "[CSV]: Some option in English."]),
				PackedStringArray(["[CSV]: Another option in English.", "[CSV]: Another option in English.", "[CSV]: Another option in English."]),
				PackedStringArray(["[CSV]: Some text with no translation.", "[CSV]: Some text with no translation.", "[CSV]: Some text with no translation."]),
			],
		},
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": "fixtures/existing_dialogue_text_export.csv",
			"expected": [
				PackedStringArray(["keys", "en", "fr", "es"]),
				PackedStringArray(["Existing keys row 1", "Existing en row 1", "Existing fr row 1", "Existing es row 1"]),
				PackedStringArray(["Existing keys row 2", "Existing en row 2", "Existing fr row 1", "Existing es row 1"]),
				PackedStringArray(["[CSV]: Some text in English.", "[CSV]: Some text in English.", "[CSV]: Some text in English.", "[CSV]: Some text in English."]),
				PackedStringArray(["[CSV]: Some option in English.", "[CSV]: Some option in English.", "[CSV]: Some option in English.", "[CSV]: Some option in English."]),
				PackedStringArray(["[CSV]: Another option in English.", "[CSV]: Another option in English.", "[CSV]: Another option in English.", "[CSV]: Another option in English."]),
				PackedStringArray(["[CSV]: Some text with no translation.", "[CSV]: Some text with no translation.", "[CSV]: Some text with no translation.", "[CSV]: Some text with no translation."]),
			],
		},
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": "fixtures/existing_dialogue_text_export_no_trailing_line.csv",
			"expected": [
				PackedStringArray(["keys", "en", "fr", "es"]),
				PackedStringArray(["Existing keys row 1", "Existing en row 1", "Existing fr row 1", "Existing es row 1"]),
				PackedStringArray(["Existing keys row 2", "Existing en row 2", "Existing fr row 1", "Existing es row 1"]),
				PackedStringArray(["[CSV]: Some text in English.", "[CSV]: Some text in English.", "[CSV]: Some text in English.", "[CSV]: Some text in English."]),
				PackedStringArray(["[CSV]: Some option in English.", "[CSV]: Some option in English.", "[CSV]: Some option in English.", "[CSV]: Some option in English."]),
				PackedStringArray(["[CSV]: Another option in English.", "[CSV]: Another option in English.", "[CSV]: Another option in English.", "[CSV]: Another option in English."]),
				PackedStringArray(["[CSV]: Some text with no translation.", "[CSV]: Some text with no translation.", "[CSV]: Some text with no translation.", "[CSV]: Some text with no translation."]),
			],
		},
	]


	func test_export_dialogue_text_translation_csv(params: Dictionary = use_parameters(test_export_dialogue_text_translation_cases)) -> void:
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
		var file_type: ParleyExportModal.FileType = ParleyExportModal.FileType.Csv
		var expected: Array = params.get("expected")
		
		# Act
		ParleyExport.export_dialogue_text_translation(file_type, test_dialogue_sequence_ast, path)

		# Assert
		assert_file_exists(path)
		assert_file_not_empty(path)
		var result: Array[PackedStringArray] = TestUtils.get_csv_results(path)
		assert_eq_deep(result, expected)

	var test_export_character_name_translation_cases: Array[Dictionary] = [
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"expected": [
				PackedStringArray(["keys", "en"]),
				PackedStringArray(["Alice", "Alice"]),
				PackedStringArray(["Bob", "Bob"]),
				PackedStringArray(["Carol", "Carol"]),
				PackedStringArray(["Dave", "Dave"]),
			],
		},
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				PackedStringArray(["keys", "en"]),
				PackedStringArray(["Eve", "Eve"]),
				PackedStringArray(["Fred", "Fred"]),
			],
			"expected": [
				PackedStringArray(["keys", "en"]),
				PackedStringArray(["Eve", "Eve"]),
				PackedStringArray(["Fred", "Fred"]),
				PackedStringArray(["Alice", "Alice"]),
				PackedStringArray(["Bob", "Bob"]),
				PackedStringArray(["Carol", "Carol"]),
				PackedStringArray(["Dave", "Dave"]),
			],
		},
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				PackedStringArray(["keys", "en", "fr", "es"]),
				PackedStringArray(["Eve", "Eve [en]", "Eve [fr]", "Eve [es]"]),
				PackedStringArray(["Fred", "Fred [en]", "Fred [fr]", "Fred [es]"]),
			],
			"expected": [
				PackedStringArray(["keys", "en", "fr", "es"]),
				PackedStringArray(["Eve", "Eve [en]", "Eve [fr]", "Eve [es]"]),
				PackedStringArray(["Fred", "Fred [en]", "Fred [fr]", "Fred [es]"]),
				PackedStringArray(["Alice", "Alice", "Alice", "Alice"]),
				PackedStringArray(["Bob", "Bob", "Bob", "Bob"]),
				PackedStringArray(["Carol", "Carol", "Carol", "Carol"]),
				PackedStringArray(["Dave", "Dave", "Dave", "Dave"]),
			],
		},
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": [
				PackedStringArray(["keys", "fr", "es"]),
				PackedStringArray(["Eve", "Eve [fr]", "Eve [es]"]),
				PackedStringArray(["Fred", "Fred [fr]", "Fred [es]"]),
			],
			"expected": [
				PackedStringArray(["keys", "fr", "es"]),
				PackedStringArray(["Eve", "Eve [fr]", "Eve [es]"]),
				PackedStringArray(["Fred", "Fred [fr]", "Fred [es]"]),
				PackedStringArray(["Alice", "Alice", "Alice"]),
				PackedStringArray(["Bob", "Bob", "Bob"]),
				PackedStringArray(["Carol", "Carol", "Carol"]),
				PackedStringArray(["Dave", "Dave", "Dave"]),
			],
		},
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": "fixtures/existing_character_name_export.csv",
			"expected": [
				PackedStringArray(["keys", "en", "fr", "es"]),
				PackedStringArray(["Eve", "Eve [en]", "Eve [fr]", "Eve [es]"]),
				PackedStringArray(["Fred", "Fred [en]", "Fred [fr]", "Fred [es]"]),
				PackedStringArray(["Alice", "Alice", "Alice", "Alice"]),
				PackedStringArray(["Bob", "Bob", "Bob", "Bob"]),
				PackedStringArray(["Carol", "Carol", "Carol", "Carol"]),
				PackedStringArray(["Dave", "Dave", "Dave", "Dave"]),
			],
		},
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"existing": "fixtures/existing_character_name_export_no_trailing_line.csv",
			"expected": [
				PackedStringArray(["keys", "en", "fr", "es"]),
				PackedStringArray(["Eve", "Eve [en]", "Eve [fr]", "Eve [es]"]),
				PackedStringArray(["Fred", "Fred [en]", "Fred [fr]", "Fred [es]"]),
				PackedStringArray(["Alice", "Alice", "Alice", "Alice"]),
				PackedStringArray(["Bob", "Bob", "Bob", "Bob"]),
				PackedStringArray(["Carol", "Carol", "Carol", "Carol"]),
				PackedStringArray(["Dave", "Dave", "Dave", "Dave"]),
			],
		},
	]


	func test_export_character_name_translation_csv(params: Dictionary = use_parameters(test_export_character_name_translation_cases)) -> void:
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
		var file_type: ParleyExportModal.FileType = ParleyExportModal.FileType.Csv
		var expected: Array = params.get("expected")
		
		# Act
		ParleyExport.export_character_name_translation(file_type, test_dialogue_sequence_ast, path)

		# Assert
		assert_file_exists(path)
		assert_file_not_empty(path)
		var result: Array[PackedStringArray] = TestUtils.get_csv_results(path)
		assert_eq_deep(result, expected)


	var test_export_node_cases: Array[Dictionary] = [
		{
			"dialogue_sequence_ast": test_dialogue_sequence_ast,
			"expected": [
				PackedStringArray(["id", "type", "character_en", "text_en", "text_translation_key"]),
				PackedStringArray(["node:2", "Dialogue", "uid://ceouii84qmu0w::alice", "[CSV]: Some text in English.", ""]),
				PackedStringArray(["node:3", "Dialogue Option", "uid://ceouii84qmu0w::bob", "[CSV]: Some option in English.", ""]),
				PackedStringArray(["node:4", "Dialogue Option", "uid://ceouii84qmu0w::carol", "[CSV]: Another option in English.", ""]),
				PackedStringArray(["node:5", "Dialogue", "uid://ceouii84qmu0w::dave", "[CSV]: Some text with no translation.", ""]),
			],
		},
	]


	func test_export_node_csv(params: Dictionary = use_parameters(test_export_node_cases)) -> void:
		# Arrange
		var path: String = tmp_dir.get_current_dir().path_join("export_%s.csv" % [str(int(Time.get_unix_time_from_system()))])
		var file_type: ParleyExportModal.FileType = ParleyExportModal.FileType.Csv
		var expected: Array = params.get("expected")
		
		# Act
		ParleyExport.export_node(file_type, test_dialogue_sequence_ast, path)

		# Assert
		assert_file_exists(path)
		assert_file_not_empty(path)
		var result: Array[PackedStringArray] = TestUtils.get_csv_results(path)
		assert_eq_deep(result, expected)


class TestUtils:
	static func get_csv_results(path: String) -> Array[PackedStringArray]:
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if not file:
			return []
		var result: Array[PackedStringArray] = []
		while !file.eof_reached():
			var row: PackedStringArray = file.get_csv_line()
			result.append(row)
		result.pop_back() # Remove empty final line
		file.close()
		return result
	

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
