class_name NextDialogueButton extends PanelContainer


var text: String = "[center]. . .[/center]":
	set(new_text):
		text = "[center]%s[/center]" % [new_text]
	get:
		return text


@onready var label: RichTextLabel = %NextDialogueLabel


func _ready() -> void:
	label.text = text


func _on_mouse_entered() -> void:
	var panel: StyleBoxFlat = get_theme_stylebox("panel")
	panel.border_color = Color('#d1d1d1')


func _on_mouse_exited() -> void:
	var panel: StyleBoxFlat = get_theme_stylebox("panel")
	panel.border_color = Color('#323232')
