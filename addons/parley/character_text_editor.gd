# random_int_editor.gd
extends EditorProperty


# The main control for editing the property.
var property_control = TextEdit.new()
# An internal value of the property.
var current_value = ""
# A guard against internal changes when the property is updated.
var updating = false


func _init():
	property_control.placeholder_text = "Character goes here... TODO: dropdown?"
	property_control.wrap_mode = TextEdit.LineWrappingMode.LINE_WRAPPING_BOUNDARY
	property_control.custom_minimum_size.x = 100
	property_control.custom_minimum_size.y = 500
	property_control.grow_vertical = true
	# Add the control as a direct child of EditorProperty node.
	add_child(property_control)
	# Make sure the control is able to retain the focus.
	add_focusable(property_control)
	# Setup the initial state and connect to the signal to track changes.
	refresh_control_text()
	property_control.text_changed.connect(_on_text_changed)

func _on_text_changed():
	# Ignore the signal if the property is currently being updated.
	if (updating):
		return

	current_value = property_control.text
	refresh_control_text()
	emit_changed(get_edited_property(), current_value)

func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return

	# Update the control with the new value.
	updating = true
	current_value = new_value
	refresh_control_text()
	updating = false

func refresh_control_text():
	property_control.text = current_value
