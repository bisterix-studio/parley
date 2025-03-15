@tool
extends MarginContainer

const back_icon: Texture2D = preload('res://addons/parley/assets/Back.svg')
const forward_icon: Texture2D = preload('res://addons/parley/assets/Forward.svg')


@onready var toggle_sidebar_button: Button = %ToggleSidebarButton


var is_sidebar_open: bool = true: set = _is_sidebar_open_setter


signal sidebar_toggled(is_sidebar_open: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_sidebar_open = true


func _is_sidebar_open_setter(new_value) -> void:
	is_sidebar_open = new_value
	if is_sidebar_open:
		toggle_sidebar_button.icon = back_icon
	else:
		toggle_sidebar_button.icon = forward_icon
	sidebar_toggled.emit(is_sidebar_open)


func _on_toggle_sidebar_button_pressed() -> void:
	is_sidebar_open = !is_sidebar_open
