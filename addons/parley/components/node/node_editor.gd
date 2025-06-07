# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyBaseNodeEditor extends VBoxContainer


@export var id: String = "": set = _on_id_changed
@export var type: ParleyDialogueSequenceAst.Type = ParleyDialogueSequenceAst.Type.UNKNOWN: set = _on_type_changed


@onready var title_label: Label = %TitleLabel
@onready var title_panel: PanelContainer = %TitlePanelContainer


signal delete_node_button_pressed(id: String)


func _ready() -> void:
	set_title()


func _on_id_changed(new_id: String) -> void:
	if id != new_id: id = new_id
	set_title()


func _on_type_changed(new_type: ParleyDialogueSequenceAst.Type) -> void:
	if type != new_type: type = new_type
	set_title()


func set_title(title: String = "", colour: Variant = null) -> void:
	if title_label:
		title_label.text = "%s [ID: %s]" % [title if title else ParleyDialogueSequenceAst.get_type_name(type), id.replace(ParleyNodeAst.id_prefix, '')]
	if title_panel:
		title_panel.get_theme_stylebox('panel').set('bg_color', colour if colour is Color else ParleyDialogueSequenceAst.get_type_colour(type))


func _on_delete_node_button_pressed() -> void:
	delete_node_button_pressed.emit(id)
