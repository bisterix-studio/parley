# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends GutTest

# TODO: move test file next to the scene
const DialogueOptionNodeEditorScene: PackedScene = preload('res://addons/parley/components/dialogue_option/dialogue_option_node_editor.tscn')


class Test_dialogue_option_node_editor:
	extends GutTest
	
	var dialogue_option_node_editor: ParleyDialogueOptionNodeEditor = null
	var character_store: ParleyCharacterStore = null
	
	func before_each() -> void:
		dialogue_option_node_editor = DialogueOptionNodeEditorScene.instantiate()
		character_store = load('res://tests/fixtures/characters/base_character_store.tres')
		character_store.id = "test"
		character_store.characters = []
		var _result: ParleyCharacter = character_store.add_character("Default Character")
		dialogue_option_node_editor.character_store = character_store
		add_child_autofree(dialogue_option_node_editor)
	
	func after_each() -> void:
		dialogue_option_node_editor = null
	
	func setup_dialogue_option_node_editor(p_dialogue_option_node_editor: ParleyDialogueOptionNodeEditor, test_case: Dictionary) -> void:
		var id: Variant = test_case.get('id')
		var _character_name: Variant = test_case.get('character_name')
		var option: Variant = test_case.get('option')
		if id:
			p_dialogue_option_node_editor.id = id
		if _character_name and _character_name is String:
			var character_name: String = _character_name
			var _added_character: ParleyCharacter = character_store.add_character(character_name)
			p_dialogue_option_node_editor.character = character_store.get_ref_by_index(character_store.characters.size() - 1)
		if option:
			p_dialogue_option_node_editor.option = option


	func use_dialogue_option_node_editor(p_dialogue_option_node_editor: ParleyDialogueOptionNodeEditor, test_case: Dictionary) -> void:
		var dialogue_variant: Variant = test_case.get('option')
		var selected_character: Variant = test_case.get('selected_character')
		var text_translation_key_variant: Variant = test_case.get('text_translation_key')
		if dialogue_variant and dialogue_variant is String:
			var option: String = dialogue_variant
			p_dialogue_option_node_editor.option_editor.insert_text_at_caret(option)
		if is_instance_of(selected_character, TYPE_INT):
			p_dialogue_option_node_editor.character_selector.item_selected.emit(selected_character)
		if text_translation_key_variant and text_translation_key_variant is String:
			var text_translation_key: String = text_translation_key_variant
			p_dialogue_option_node_editor.text_translation_key_editor.key_changed.emit(text_translation_key)


	func test_initial_render(params: Variant = use_parameters([
		{
			"input": {"id": null, "character_name": null, "option": null},
			"expected": {"id": "", "character_id": "", "selected_character": - 1, "option": ""},
		},
		{
			"input": {"id": "1", "character_name": null, "option": null},
			"expected": {"id": "1", "character_id": "", "selected_character": - 1, "option": ""},
		},
		{
			"input": {"id": null, "character_name": "Test Character", "option": null},
			"expected": {"id": "", "character_id": "%s::test_character" % ParleyUtils.resource.get_uid(character_store), "selected_character": 1, "option": ""},
		},
		{
			"input": {"id": null, "character_name": null, "option": "Some option"},
			"expected": {"id": "", "character_id": "", "selected_character": - 1, "option": "Some option"},
		},
		{
			"input": {"id": "1", "character_name": "Test Character", "option": "Some option"},
			"expected": {"id": "1", "character_id": "%s::test_character" % ParleyUtils.resource.get_uid(character_store), "selected_character": 1, "option": "Some option"},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		var expected_selected_character: int = expected['selected_character']
		setup_dialogue_option_node_editor(dialogue_option_node_editor, input)
		watch_signals(dialogue_option_node_editor)
		
		# Act
		await wait_until(func() -> bool: return dialogue_option_node_editor.is_inside_tree(), .1)

		# Assert
		assert_true(dialogue_option_node_editor.is_inside_tree())
		assert_eq(dialogue_option_node_editor.id, str(expected['id']))
		assert_eq(dialogue_option_node_editor.character, str(expected['character_id']))
		assert_eq(dialogue_option_node_editor.character_selector.selected, expected_selected_character)
		assert_eq(dialogue_option_node_editor.option, str(expected['option']))
		assert_eq(dialogue_option_node_editor.option_editor.text, str(expected['option']))
		assert_signal_not_emitted(dialogue_option_node_editor, 'dialogue_option_node_changed')


	func test_update_render_with_variables(params: Variant = use_parameters([
		{
			"input": {"id": null, "character_name": null, "option": null},
			"expected": {"id": "", "character_id": "", "selected_character": - 1, "option": ""},
		},
		{
			"input": {"id": "1", "character_name": null, "option": null},
			"expected": {"id": "1", "character_id": "", "selected_character": - 1, "option": ""},
		},
		{
			"input": {"id": null, "character_name": "Test Character", "option": null},
			"expected": {"id": "", "character_id": "%s:test_character" % ParleyUtils.resource.get_uid(character_store), "selected_character": 1, "option": ""},
		},
		{
			"input": {"id": null, "character_name": null, "option": "Some option"},
			"expected": {"id": "", "character_id": "", "selected_character": - 1, "option": "Some option"},
		},
		{
			"input": {"id": "1", "character_name": "Test Character", "option": "Some option"},
			"expected": {"id": "1", "character_id": "%s:test_character" % ParleyUtils.resource.get_uid(character_store), "selected_character": 1, "option": "Some option"},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		watch_signals(dialogue_option_node_editor)
		
		# Act
		await wait_until(func() -> bool: return dialogue_option_node_editor.is_inside_tree(), .1)
		setup_dialogue_option_node_editor(dialogue_option_node_editor, input)

		# Assert
		assert_true(dialogue_option_node_editor.is_inside_tree())
		assert_eq(dialogue_option_node_editor.id, str(expected['id']))
		assert_eq(dialogue_option_node_editor.option, str(expected['option']))
		assert_eq(dialogue_option_node_editor.option_editor.text, str(expected['option']))
		assert_signal_not_emitted(dialogue_option_node_editor, 'dialogue_option_node_changed')

	func test_update_render_with_text_input(params: Variant = use_parameters([
		{
			"input": {"id": "1", "option": "Some option"},
			"expected": {"id": "1", "character_id": "", "selected_character": -1, "option": "Some option", "text_translation_key": ""},
		},
		{
			"input": {"id": "1", "selected_character": 0},
			"expected": {"id": "1", "character_id": "%s::default_character" % ParleyUtils.resource.get_uid(character_store), "selected_character": 0, "option": "", "text_translation_key": ""},
		},
		{
			"input": {"id": "1", "text_translation_key": "some_text_translation_key"},
			"expected": {"id": "1", "character_id": "", "selected_character": -1, "option": "", "text_translation_key": "some_text_translation_key"},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		var expected_selected_character: int = expected['selected_character']
		watch_signals(dialogue_option_node_editor)
		dialogue_option_node_editor.id = input['id']
		
		# Act
		await wait_until(func() -> bool: return dialogue_option_node_editor.is_inside_tree(), .1)
		use_dialogue_option_node_editor(dialogue_option_node_editor, input)
		await wait_for_signal(dialogue_option_node_editor.dialogue_option_node_changed, .1)

		# Assert
		assert_true(dialogue_option_node_editor.is_inside_tree())
		assert_eq(dialogue_option_node_editor.option, str(expected['option']))
		assert_eq(dialogue_option_node_editor.option_editor.text, str(expected['option']))
		assert_eq(dialogue_option_node_editor.character_selector.selected, expected_selected_character)
		assert_eq(dialogue_option_node_editor.text_translation_key, str(expected['text_translation_key']))
		assert_signal_emitted_with_parameters(dialogue_option_node_editor, 'dialogue_option_node_changed', [expected['id'], expected['character_id'], expected['option'], expected['text_translation_key']])
