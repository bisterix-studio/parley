# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyDialogueOptionContainer extends PanelContainer


var text: String = "[left]Unknown[/left]":
	set(new_text): text = "[left]%s[/left]" % [new_text]
	get: return text


@onready var label: RichTextLabel = %DialogueOptionLabel


func _ready() -> void:
	label.text = text


func _on_focus_entered() -> void:
	var panel: StyleBoxFlat = get_theme_stylebox("panel")
	panel.border_color = Color('#d1d1d1')


func _on_focus_exited() -> void:
	var panel: StyleBoxFlat = get_theme_stylebox("panel")
	panel.border_color = Color('#323232')
