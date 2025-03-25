@tool
extends EditorProperty

const MultilineTextEditor: PackedScene = preload('./multiline_text_editor.tscn')

# The main control for editing the property.
var property_control = MultilineTextEditor.instantiate()
# An internal value of the property.
var current_value = ""
# A guard against internal changes when the property is updated.
var updating = false


func _init(_label: String = "", _current_value: String = ""):
	label = _label.capitalize()
	current_value = _current_value
	# Add the control as a direct child of EditorProperty node.
	add_child(property_control)
	set_bottom_editor(property_control)
	# Make sure the control is able to retain the focus.
	add_focusable(property_control)
	# Setup the initial state and connect to the signal to track changes.
	refresh_control_text()

func _on_text_changed():
	# Ignore the signal if the property is currently being updated.
	if (updating):
		return

	current_value = property_control.text
	refresh_control_text()
	emit_changed(get_edited_property(), current_value)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object().get(get_edited_property())
	if (new_value == current_value):
		return

	# Update the control with the new value.
	updating = true
	current_value = new_value
	refresh_control_text()
	updating = false

func refresh_control_text():
	if property_control and is_instance_of(current_value, TYPE_STRING) and property_control.text != current_value:
		property_control.text = current_value
