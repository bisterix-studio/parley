# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends GutTest

# TODO: move test file next to the scene
const TranslationKeyEditorScene: PackedScene = preload('res://addons/parley/components/editor/translation_key_editor.tscn')


class Test_translation_key_editor:
	extends GutTest
	
	var translation_key_editor: ParleyTranslationKeyEditor = null
	
	func before_each() -> void:
		translation_key_editor = TranslationKeyEditorScene.instantiate()
		add_child_autofree(translation_key_editor)
	
	func after_each() -> void:
		translation_key_editor = null
	
	func setup_translation_key_editor(p_translation_key_editor: ParleyTranslationKeyEditor, test_case: Dictionary) -> void:
		var label: Variant = test_case.get('label')
		var key: Variant = test_case.get('key')
		if label:
			p_translation_key_editor.label = label
		if key:
			p_translation_key_editor.key = key


	func use_translation_key_editor(p_translation_key_editor: ParleyTranslationKeyEditor, test_case: Dictionary) -> void:
		var key_variant: Variant = test_case.get('key')
		if key_variant and key_variant is String:
			var key: String = key_variant
			p_translation_key_editor.translation_key_editor.insert_text_at_caret(key)
			p_translation_key_editor.translation_key_editor.text_changed.emit(key)


	func test_initial_render(params: Variant = use_parameters([
		{
			"input": {"label": null, "key": null},
			"expected": {"label": "", "key": ""},
		},
		{
			"input": {"label": "Some label", "key": null},
			"expected": {"label": "Some label", "key": ""},
		},
		{
			"input": {"label": null, "key": null},
			"expected": {"label": "", "key": ""},
		},
		{
			"input": {"label": null, "key": "Some key"},
			"expected": {"label": "", "key": "Some key"},
		},
		{
			"input": {"label": "Some label", "key": "Some key"},
			"expected": {"label": "Some label", "key": "Some key"},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		setup_translation_key_editor(translation_key_editor, input)
		watch_signals(translation_key_editor)
		
		# Act
		await wait_until(func() -> bool: return translation_key_editor.is_inside_tree(), .1)

		# Assert
		assert_true(translation_key_editor.is_inside_tree())
		assert_eq(translation_key_editor.label, str(expected['label']))
		assert_eq(translation_key_editor.key, str(expected['key']))
		assert_signal_not_emitted(translation_key_editor, 'key_changed')
		assert_signal_not_emitted(translation_key_editor, 'key_generation_requested')


	func test_update_render_with_variables(params: Variant = use_parameters([
		{
			"input": {"label": null, "key": null},
			"expected": {"label": "", "key": ""},
		},
		{
			"input": {"label": "Some label", "key": null},
			"expected": {"label": "Some label", "key": ""},
		},
		{
			"input": {"label": null, "key": "Some key"},
			"expected": {"label": "", "key": "Some key"},
		},
		{
			"input": {"label": "Some label", "key": "Some key"},
			"expected": {"label": "Some label", "key": "Some key"},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		watch_signals(translation_key_editor)
		
		# Act
		await wait_until(func() -> bool: return translation_key_editor.is_inside_tree(), .1)
		setup_translation_key_editor(translation_key_editor, input)

		# Assert
		assert_true(translation_key_editor.is_inside_tree())
		assert_eq(translation_key_editor.label, str(expected['label']))
		assert_eq(translation_key_editor.translation_key_label.text, str(expected['label']))
		assert_eq(translation_key_editor.key, str(expected['key']))
		assert_eq(translation_key_editor.translation_key_editor.text, str(expected['key']))
		assert_signal_not_emitted(translation_key_editor, 'key_changed')
		assert_signal_not_emitted(translation_key_editor, 'key_generation_requested')

	func test_update_render_with_text_input(params: Variant = use_parameters([
		{
			"input": {"key": "Some key"},
			"expected": {"label": "", "key": "Some key"},
		},
	])) -> void:
		# Arrange
		var input: Dictionary = params['input']
		var expected: Dictionary = params['expected']
		watch_signals(translation_key_editor)
		
		# Act
		await wait_until(func() -> bool: return translation_key_editor.is_inside_tree(), .1)
		use_translation_key_editor(translation_key_editor, input)
		await wait_for_signal(translation_key_editor.key_changed, .1)

		# Assert
		assert_true(translation_key_editor.is_inside_tree())
		assert_eq(translation_key_editor.label, str(expected['label']))
		assert_eq(translation_key_editor.translation_key_label.text, str(expected['label']))
		assert_eq(translation_key_editor.key, str(expected['key']))
		assert_eq(translation_key_editor.translation_key_editor.text, str(expected['key']))
		assert_signal_emitted_with_parameters(translation_key_editor, 'key_changed', [expected['key']])
		assert_signal_not_emitted(translation_key_editor, 'key_generation_requested')
