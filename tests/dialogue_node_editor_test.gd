extends GutTest

# TODO: move  test file next to the scene
const DialogueNodeEditorScene = preload('res://addons/parley/components//dialogue/dialogue_node_editor.tscn')


class Test_dialogue_node_editor:
	extends GutTest
	
	var dialogue_node_editor: DialogueNodeEditor = null
	
	func before_each():
		dialogue_node_editor = DialogueNodeEditorScene.instantiate()
		dialogue_node_editor.character_store = CharacterStore.new()
		dialogue_node_editor.character_store.add_character("Default Character")
		add_child_autofree(dialogue_node_editor)
	
	func after_each():
		dialogue_node_editor = null
	
	func setup_dialogue_node_editor(p_dialogue_node_editor: DialogueNodeEditor, test_case: Dictionary) -> void:
		var id = test_case.get('id')
		var character = test_case.get('character')
		var dialogue = test_case.get('dialogue')
		if id:
			p_dialogue_node_editor.id = id
		if character:
			p_dialogue_node_editor.character_store.add_character(character)
			p_dialogue_node_editor.reload_character_store()
			p_dialogue_node_editor.character = character
		if dialogue:
			p_dialogue_node_editor.dialogue = dialogue


	func use_dialogue_node_editor(p_dialogue_node_editor: DialogueNodeEditor, test_case: Dictionary) -> void:
		var dialogue = test_case.get('dialogue')
		var selected_character = test_case.get('selected_character')
		if dialogue:
			p_dialogue_node_editor.dialogue_editor.insert_text_at_caret(dialogue)
		if is_instance_of(selected_character, TYPE_INT):
			p_dialogue_node_editor.character_editor.item_selected.emit(selected_character)


	func test_initial_render(params = use_parameters([
		{
			"input": {"id": null, "character": null, "dialogue": null},
			"expected": {"id": "", "character": "", "selected_character": - 1, "dialogue": ""},
		},
		{
			"input": {"id": "1", "character": null, "dialogue": null},
			"expected": {"id": "1", "character": "", "selected_character": - 1, "dialogue": ""},
		},
		{
			"input": {"id": null, "character": "Test Character", "dialogue": null},
			"expected": {"id": "", "character": "Test Character", "selected_character": 1, "dialogue": ""},
		},
		{
			"input": {"id": null, "character": null, "dialogue": "Some dialogue"},
			"expected": {"id": "", "character": "", "selected_character": - 1, "dialogue": "Some dialogue"},
		},
		{
			"input": {"id": "1", "character": "Test Character", "dialogue": "Some dialogue"},
			"expected": {"id": "1", "character": "Test Character", "selected_character": 1, "dialogue": "Some dialogue"},
		},
	])) -> void:
		# Arrange
		var input = params['input']
		var expected = params['expected']
		setup_dialogue_node_editor(dialogue_node_editor, input)
		watch_signals(dialogue_node_editor)
		
		# Act
		await wait_until(func(): return dialogue_node_editor.is_inside_tree(), .1)

		# Assert
		assert_true(dialogue_node_editor.is_inside_tree())
		assert_eq(dialogue_node_editor.id, expected['id'])
		assert_eq(dialogue_node_editor.character, expected['character'])
		assert_eq(dialogue_node_editor.character_editor.selected, expected['selected_character'])
		assert_eq(dialogue_node_editor.dialogue, expected['dialogue'])
		assert_eq(dialogue_node_editor.dialogue_editor.text, expected['dialogue'])
		assert_signal_not_emitted(dialogue_node_editor, 'dialogue_node_changed')


	func test_update_render_with_variables(params = use_parameters([
		{
			"input": {"id": null, "character": null, "dialogue": null},
			"expected": {"id": "", "character": "", "selected_character": - 1, "dialogue": ""},
		},
		{
			"input": {"id": "1", "character": null, "dialogue": null},
			"expected": {"id": "1", "character": "", "selected_character": - 1, "dialogue": ""},
		},
		{
			"input": {"id": null, "character": "Test Character", "dialogue": null},
			"expected": {"id": "", "character": "Test Character", "selected_character": 1, "dialogue": ""},
		},
		{
			"input": {"id": null, "character": null, "dialogue": "Some dialogue"},
			"expected": {"id": "", "character": "", "selected_character": - 1, "dialogue": "Some dialogue"},
		},
		{
			"input": {"id": "1", "character": "Test Character", "dialogue": "Some dialogue"},
			"expected": {"id": "1", "character": "Test Character", "selected_character": 1, "dialogue": "Some dialogue"},
		},
	])) -> void:
		# Arrange
		var input = params['input']
		var expected = params['expected']
		watch_signals(dialogue_node_editor)
		
		# Act
		await wait_until(func(): return dialogue_node_editor.is_inside_tree(), .1)
		setup_dialogue_node_editor(dialogue_node_editor, input)

		# Assert
		assert_true(dialogue_node_editor.is_inside_tree())
		assert_eq(dialogue_node_editor.id, expected['id'])
		assert_eq(dialogue_node_editor.dialogue, expected['dialogue'])
		assert_eq(dialogue_node_editor.dialogue_editor.text, expected['dialogue'])
		assert_signal_not_emitted(dialogue_node_editor, 'dialogue_node_changed')
#
#
	func test_update_render_with_text_input(params = use_parameters([
		#{
			#"input": {"id": "1", "dialogue": "Some dialogue"},
			#"expected": {"id": "1", "character": "Unknown", "selected_character": -1, "dialogue": "Some dialogue"},
		#},
		{
			"input": {"id": "1", "selected_character": 0},
			"expected": {"id": "1", "character": "Default Character", "selected_character": 0, "dialogue": ""},
		},
	])) -> void:
		# Arrange
		var input = params['input']
		var expected = params['expected']
		watch_signals(dialogue_node_editor)
		dialogue_node_editor.id = input['id']
		
		# Act
		await wait_until(func(): return dialogue_node_editor.is_inside_tree(), .1)
		use_dialogue_node_editor(dialogue_node_editor, input)
		await wait_for_signal(dialogue_node_editor.dialogue_node_changed, .1)

		# Assert
		assert_true(dialogue_node_editor.is_inside_tree())
		assert_eq(dialogue_node_editor.dialogue, expected['dialogue'])
		assert_eq(dialogue_node_editor.dialogue_editor.text, expected['dialogue'])
		assert_eq(dialogue_node_editor.character_editor.selected, expected['selected_character'])
		assert_signal_emitted_with_parameters(dialogue_node_editor, 'dialogue_node_changed', [expected['id'], expected['character'], expected['dialogue']])
