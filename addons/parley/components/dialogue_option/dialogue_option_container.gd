@tool
class_name DialogueOptionContainer extends PanelContainer


var text: String = "[center]Unknown[/center]":
	set(new_text): text = "[center]%s[/center]" % [new_text]
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
