# my_inspector_plugin.gd
extends EditorInspectorPlugin

var CharacterPropertyEditor = preload("character_text_editor.gd")
var TextPropertyEditor = preload("./components/editor/multiline_text_inspector.gd")

func _can_handle(object):
	if object is DialogueAst:
		return true
	if object is DialogueNodeAst:
		return true
	return false

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	# We handle properties of type integer.
	if object is DialogueNodeAst:
		if name == 'character' and type == TYPE_STRING:
			# Create an instance of the custom property editor and register
			# it to a specific property path.
			add_property_editor(name, CharacterPropertyEditor.new(), true)
			# Inform the editor to remove the default property editor for
			# this property type.
			return true
		if name == 'text' and type == TYPE_STRING:
			add_custom_control(TextPropertyEditor.new(name, object[name]))
			return true
		return false
	else:
		return false
