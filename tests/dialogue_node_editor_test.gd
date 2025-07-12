# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends GutTest

# TODO: move test file next to the scene
const DialogueNodeEditorScene: PackedScene = preload('res://addons/parley/components//dialogue/dialogue_node_editor.tscn')


class Test_dialogue_node_editor:
	extends GutTest
	
	var dialogue_node_editor: ParleyDialogueNodeEditor = null
	var character_store: ParleyCharacterStore = null
	
	func before_each() -> void:
		dialogue_node_editor = DialogueNodeEditorScene.instantiate()
		character_store = load('res://tests/fixtures/characters/base_character_store.tres')
		character_store.id = "test"
		character_store.characters = []
		var _result: ParleyCharacter = character_store.add_character("Default Character")
		dialogue_node_editor.character_store = character_store
		add_child_autofree(dialogue_node_editor)
	
	func after_each() -> void:
		dialogue_node_editor = null
	
	func setup_dialogue_node_editor(p_dialogue_node_editor: ParleyDialogueNodeEditor, test_case: Dictionary) -> void:
		var id: Variant = test_case.get('id')
		var _character_name: Variant = test_case.get('character_name')
		var dialogue: Variant = test_case.get('dialogue')
		if id:
			p_dialogue_node_editor.id = id
		if _character_name and _character_name is String:
			var character_name: String = _character_name
			var _added_character: ParleyCharacter = character_store.add_character(character_name)
			p_dialogue_node_editor.character = character_store.get_ref_by_index(character_store.characters.size() - 1)
		if dialogue:
			p_dialogue_node_editor.dialogue = dialogue


	func use_dialogue_node_editor(p_dialogue_node_editor: ParleyDialogueNodeEditor, test_case: Dictionary) -> void:
		var _dialogue: Variant = test_case.get('dialogue')
		var selected_character: Variant = test_case.get('selected_character')
		if _dialogue and _dialogue is String:
			var dialogue: String = _dialogue
			p_dialogue_node_editor.dialogue_editor.insert_text_at_caret(dialogue)
		if is_instance_of(selected_character, TYPE_INT):
			p_dialogue_node_editor.character_selector.item_selected.emit(selected_character)


	func test_initial_render(params: Variant = use_parameters([
		{
			"input": {"id": null, "character_name": null, "dialogue": null},
			"expected": {"id": "", "character_id": "", "selected_character": - 1, "dialogue": ""},
		},
		{
			"input": {"id": "1", "character_name": null, "dialogue": null},
			"expected": {"id": "1", "character_id": "", "selected_character": - 1, "dialogue": ""},
		},
		{
			"input": {"id": null, "character_name": "Test Character", "dialogue": null},
			"expected": {"id": "", "character_id": "%s::test_character" % ParleyUtils.resource.get_uid(character_store), "selected_character": 1, "dialogue": ""},
		},
		{
			"input": {"id": null, "character_name": null, "dialogue": "Some dialogue"},
			"expected": {"id": "", "character_id": "", "selected_character": - 1, "dialogue": "Some dialogue"},
		},
		{
			"input": {"id": "1", "character_name": "Test Character", "dialogue": "Some dialogue"},
			"expected": {"id": "1", "character_id": "%s::test_character" % ParleyUtils.resource.get_uid(character_store), "selected_character": 1, "dialogue": "Some dialogue"},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		var expected_selected_character: int = expected['selected_character']
		setup_dialogue_node_editor(dialogue_node_editor, input)
		watch_signals(dialogue_node_editor)
		
		# Act
		await wait_until(func() -> bool: return dialogue_node_editor.is_inside_tree(), .1)

		# Assert
		assert_true(dialogue_node_editor.is_inside_tree())
		assert_eq(dialogue_node_editor.id, str(expected['id']))
		assert_eq(dialogue_node_editor.character, str(expected['character_id']))
		assert_eq(dialogue_node_editor.character_selector.selected, expected_selected_character)
		assert_eq(dialogue_node_editor.dialogue, str(expected['dialogue']))
		assert_eq(dialogue_node_editor.dialogue_editor.text, str(expected['dialogue']))
		assert_signal_not_emitted(dialogue_node_editor, 'dialogue_node_changed')


	func test_update_render_with_variables(params: Variant = use_parameters([
		{
			"input": {"id": null, "character_name": null, "dialogue": null},
			"expected": {"id": "", "character_id": "", "selected_character": - 1, "dialogue": ""},
		},
		{
			"input": {"id": "1", "character_name": null, "dialogue": null},
			"expected": {"id": "1", "character_id": "", "selected_character": - 1, "dialogue": ""},
		},
		{
			"input": {"id": null, "character_name": "Test Character", "dialogue": null},
			"expected": {"id": "", "character_id": "%s:test_character" % ParleyUtils.resource.get_uid(character_store), "selected_character": 1, "dialogue": ""},
		},
		{
			"input": {"id": null, "character_name": null, "dialogue": "Some dialogue"},
			"expected": {"id": "", "character_id": "", "selected_character": - 1, "dialogue": "Some dialogue"},
		},
		{
			"input": {"id": "1", "character_name": "Test Character", "dialogue": "Some dialogue"},
			"expected": {"id": "1", "character_id": "%s:test_character" % ParleyUtils.resource.get_uid(character_store), "selected_character": 1, "dialogue": "Some dialogue"},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		watch_signals(dialogue_node_editor)
		
		# Act
		await wait_until(func() -> bool: return dialogue_node_editor.is_inside_tree(), .1)
		setup_dialogue_node_editor(dialogue_node_editor, input)

		# Assert
		assert_true(dialogue_node_editor.is_inside_tree())
		assert_eq(dialogue_node_editor.id, str(expected['id']))
		assert_eq(dialogue_node_editor.dialogue, str(expected['dialogue']))
		assert_eq(dialogue_node_editor.dialogue_editor.text, str(expected['dialogue']))
		assert_signal_not_emitted(dialogue_node_editor, 'dialogue_node_changed')

	func test_update_render_with_text_input(params: Variant = use_parameters([
		{
			"input": {"id": "1", "dialogue": "Some dialogue"},
			"expected": {"id": "1", "character_id": "", "selected_character": - 1, "dialogue": "Some dialogue"},
		},
		{
			"input": {"id": "1", "selected_character": 0},
			"expected": {"id": "1", "character_id": "%s::default_character" % ParleyUtils.resource.get_uid(character_store), "selected_character": 0, "dialogue": ""},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		var expected_selected_character: int = expected['selected_character']
		watch_signals(dialogue_node_editor)
		dialogue_node_editor.id = input['id']
		
		# Act
		await wait_until(func() -> bool: return dialogue_node_editor.is_inside_tree(), .1)
		use_dialogue_node_editor(dialogue_node_editor, input)
		await wait_for_signal(dialogue_node_editor.dialogue_node_changed, .1)

		# Assert
		assert_true(dialogue_node_editor.is_inside_tree())
		assert_eq(dialogue_node_editor.dialogue, str(expected['dialogue']))
		assert_eq(dialogue_node_editor.dialogue_editor.text, str(expected['dialogue']))
		assert_eq(dialogue_node_editor.character_selector.selected, expected_selected_character)
		assert_signal_emitted_with_parameters(dialogue_node_editor, 'dialogue_node_changed', [expected['id'], expected['character_id'], expected['dialogue']])
