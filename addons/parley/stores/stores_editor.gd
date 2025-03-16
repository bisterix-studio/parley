@tool
extends PanelContainer

@onready var show_character_store_button: Button = %ShowCharacterStoreButton
@onready var show_fact_store_button: Button = %ShowFactStoreButton
@onready var show_action_store_button: Button = %ShowActionStoreButton

func _ready() -> void:
	show_character_store_button.flat = true
	show_fact_store_button.flat = true
	show_action_store_button.flat = true
	show_character_store_button.button_pressed = true


func _on_show_character_store_button_toggled(toggled_on: bool) -> void:
	if show_character_store_button:
		show_character_store_button.flat = not toggled_on
	if toggled_on:
		if show_fact_store_button:
			show_fact_store_button.button_pressed = false
		if show_action_store_button:
			show_action_store_button.button_pressed = false

func _on_show_fact_store_button_toggled(toggled_on: bool) -> void:
	if show_fact_store_button:
		show_fact_store_button.flat = not toggled_on
	if toggled_on:
		if show_character_store_button:
			show_character_store_button.button_pressed = false
		if show_action_store_button:
			show_action_store_button.button_pressed = false


func _on_show_action_store_button_toggled(toggled_on: bool) -> void:
	if show_action_store_button:
		show_action_store_button.flat = not toggled_on
	if toggled_on:
		if show_fact_store_button:
			show_fact_store_button.button_pressed = false
		if show_character_store_button:
			show_character_store_button.button_pressed = false
