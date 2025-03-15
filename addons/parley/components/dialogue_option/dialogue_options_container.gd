## A [Container] for dialogue options provided by Parley.
class_name DialogueOptionsMenu extends MarginContainer


const DialogueOptionContainer = preload('./dialogue_option_container.tscn')


@onready var dialogue_options_container = %DialogueOptionsContainer


## Emitted when a dialogue option is selected.
signal dialogue_option_selected(dialogue_option: DialogueOptionNodeAst)


## The action for accepting a dialogue option (is possibly overridden by parent dialogue balloon).
@export var next_action: StringName = &""


## The list of dialogue options.
var dialogue_options: Array = []:
	get:
		return dialogue_options
	set(value):
		dialogue_options = value
		
		if not is_node_ready():
			await ready

		# Remove any current items
		for item in dialogue_options_container.get_children():
			dialogue_options_container.remove_child(item)
			item.queue_free()

		# Add new items
		if dialogue_options.size() > 0:
			for dialogue_option in dialogue_options:
				#var item = Button.new()
				var item = DialogueOptionContainer.instantiate()
				item.name = "DialogueOption%d" % dialogue_options_container.get_child_count()
				#item.dialogue_option_node = dialogue_option
				item.text = dialogue_option.text
				item.set_meta("ast", dialogue_option)
				dialogue_options_container.add_child(item)

			_configure_focus()


func _ready() -> void:
	visibility_changed.connect(func():
		if visible and get_menu_items().size() > 0:
			get_menu_items()[0].grab_focus()
	)


## Get the selectable items in the menu.
func get_menu_items() -> Array:
	var items: Array = []
	for child in dialogue_options_container.get_children():
		if not child.visible: continue
		if not child.has_meta('ast'): continue
		items.append(child)

	return items


#region Internal
# Prepare the menu for keyboard and mouse navigation.
func _configure_focus() -> void:
	var items = get_menu_items()
	for i in items.size():
		var item: Control = items[i]

		item.focus_mode = Control.FOCUS_ALL

		item.focus_neighbor_left = item.get_path()
		item.focus_neighbor_right = item.get_path()

		if i == 0:
			item.focus_neighbor_top = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbor_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()

		if i == items.size() - 1:
			item.focus_neighbor_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()

		item.mouse_entered.connect(_on_dialogue_option_mouse_entered.bind(item))
		item.gui_input.connect(_on_dialogue_option_gui_input.bind(item, item.get_meta("ast")))

	items[0].grab_focus()


#endregion

#region Signals
func _on_dialogue_option_mouse_entered(item: Control) -> void:
	item.grab_focus()


func _on_dialogue_option_gui_input(event: InputEvent, item: Control, dialogue_option: DialogueOptionNodeAst) -> void:
	get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		dialogue_option_selected.emit(dialogue_option)
	elif event.is_action_pressed(&"ui_accept" if next_action.is_empty() else next_action) and item in get_menu_items():
		dialogue_option_selected.emit(dialogue_option)
#endregion
