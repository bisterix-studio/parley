extends GutTest

# TODO: move  test file next to the scene
const ActionNodeEditorScene: PackedScene = preload('res://addons/parley/components/action/action_node_editor.tscn')

class Test_action_node_editor:
	extends GutTest
	
	var action_node_editor: ActionNodeEditor = null
	var action_store: ActionStore = null
	
	func before_each() -> void:
		action_store = ActionStore.new()
		action_node_editor = ActionNodeEditorScene.instantiate()
		action_node_editor.action_store = action_store
		add_child_autofree(action_node_editor)
		autofree(action_store)
	
	func after_each() -> void:
		action_node_editor = null
		action_store = null
	
	func setup_action_node_editor(p_action_node_editor: ActionNodeEditor, test_case: Dictionary) -> void:
		var id: Variant = test_case.get('id')
		var description: Variant = test_case.get('description')
		if id:
			p_action_node_editor.id = id
		if description:
			p_action_node_editor.description = description

	func use_action_node_editor(p_action_node_editor: ActionNodeEditor, test_case: Dictionary) -> void:
		var _description: Variant = test_case.get('description')
		if _description and _description is String:
			var description: String = _description
			p_action_node_editor.description_editor.insert_text_at_caret(description)

	func test_initial_render(params: Variant = use_parameters([
		{
			"input": {"id": null, "description": null},
			"expected": {"id": "", "description": ""},
		},
		{
			"input": {"id": "1", "description": null},
			"expected": {"id": "1", "description": ""},
		},
		{
			"input": {"id": null, "description": "Some description"},
			"expected": {"id": "", "description": "Some description"},
		},
		{
			"input": {"id": "1", "description": "Some description"},
			"expected": {"id": "1", "description": "Some description"},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		setup_action_node_editor(action_node_editor, input)
		watch_signals(action_node_editor)
		
		# Act
		await wait_until(func() -> bool: return action_node_editor.is_inside_tree(), .1)

		# Assert
		assert_true(action_node_editor.is_inside_tree())
		assert_eq(action_node_editor.id, str(expected['id']))
		assert_eq(action_node_editor.description, str(expected['description']))
		assert_eq(action_node_editor.description_editor.text, str(expected['description']))
		assert_signal_not_emitted(action_node_editor, 'action_node_changed')

	func test_update_render_with_variables(params: Variant = use_parameters([
		{
			"input": {"id": "1", "description": null},
			"expected": {"id": "1", "description": ""},
		},
		{
			"input": {"id": null, "description": "Some description"},
			"expected": {"id": "", "description": "Some description"},
		},
		{
			"input": {"id": "1", "description": "Some description"},
			"expected": {"id": "1", "description": "Some description"},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		watch_signals(action_node_editor)
		
		# Act
		await wait_until(func() -> bool: return action_node_editor.is_inside_tree(), .1)
		setup_action_node_editor(action_node_editor, input)

		# Assert
		assert_true(action_node_editor.is_inside_tree())
		assert_eq(action_node_editor.id, str(expected['id']))
		assert_eq(action_node_editor.description, str(expected['description']))
		assert_eq(action_node_editor.description_editor.text, str(expected['description']))
		assert_signal_not_emitted(action_node_editor, 'action_node_changed')

	func test_update_render_with_text_input(params: Variant = use_parameters([
		{
			"input": {"id": null, "description": "Some description"},
			"expected": {"id": "", "description": "Some description", "action_type": ActionNodeAst.ActionType.SCRIPT, "script_name": "", "values": []},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		watch_signals(action_node_editor)
		
		# Act
		await wait_until(func() -> bool: return action_node_editor.is_inside_tree(), .1)
		use_action_node_editor(action_node_editor, input)
		await wait_for_signal(action_node_editor.action_node_changed, .1)

		# Assert
		assert_true(action_node_editor.is_inside_tree())
		assert_eq(action_node_editor.id, str(expected['id']))
		assert_eq(action_node_editor.description, str(expected['description']))
		assert_eq(action_node_editor.description_editor.text, str(expected['description']))
		assert_signal_emitted_with_parameters(action_node_editor, 'action_node_changed', [expected['id'], expected['description'], expected['action_type'], expected['script_name'], expected['values']])
