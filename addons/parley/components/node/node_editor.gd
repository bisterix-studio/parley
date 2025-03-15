@tool
class_name NodeEditor extends VBoxContainer

@export var id: String = "": set = _on_id_changed
@export var type: DialogueAst.Type = DialogueAst.Type.UNKNOWN: set = _on_type_changed

@onready var title_label: Label = %TitleLabel
@onready var title_panel: PanelContainer = %TitlePanelContainer

func _ready() -> void:
	hide()


func _on_id_changed(new_id: String) -> void:
	if id != new_id: id = new_id
	set_title()


func _on_type_changed(new_type: DialogueAst.Type) -> void:
	if type != new_type: type = new_type
	set_title()


func set_title(title: String = "", colour = null) -> void:
	if title_label:
		title_label.text = "%s [ID: %s]" % [title if title else DialogueAst.get_type_name(type), id]
	if title_panel:
		title_panel.get_theme_stylebox('panel').set('bg_color', colour if colour is Color else DialogueAst.get_type_colour(type))
