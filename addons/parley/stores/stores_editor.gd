@tool
class_name ParleyStoresEditor extends PanelContainer

@onready var show_character_store_button: Button = %ShowCharacterStoreButton
@onready var show_fact_store_button: Button = %ShowFactStoreButton
@onready var show_action_store_button: Button = %ShowActionStoreButton
@onready var character_store_editor: PanelContainer = %CharacterStoreEditor
@onready var fact_store_editor: PanelContainer = %FactStoreEditor
@onready var action_store_editor: PanelContainer = %ActionStoreEditor

enum Store {
	CHARACTER,
	FACT,
	ACTION,
}

var dialogue_ast: DialogueAst = DialogueAst.new(): set = _set_dialogue_ast
var current_store: Store: set = _set_current_store

func _ready() -> void:
	current_store = Store.CHARACTER

func _clear() -> void:
	if character_store_editor:
		character_store_editor.hide()
	if fact_store_editor:
		fact_store_editor.hide()
	if action_store_editor:
		action_store_editor.hide()

func _render() -> void:
	_clear()

func _set_dialogue_ast(new_dialogue_ast: DialogueAst) -> void:
	dialogue_ast = new_dialogue_ast
	_set_current_store(current_store)

func _set_current_store(new_current_store: Store) -> void:
	current_store = new_current_store
	match current_store:
		Store.CHARACTER: _set_character_store()
		Store.FACT: _set_fact_store()
		Store.ACTION: _set_action_store()
		_: push_error('PARLEY_ERR: Unsupported store selected: %s' % [current_store])

func _set_character_store() -> void:
	if show_character_store_button and not show_character_store_button.button_pressed:
		show_character_store_button.button_pressed = true
	_clear()
	if character_store_editor:
		character_store_editor.selected_character_stores = dialogue_ast.stores.character
		character_store_editor.show()

func _set_fact_store() -> void:
	if show_fact_store_button and not show_fact_store_button.button_pressed:
		show_fact_store_button.button_pressed = true
	_clear()
	if fact_store_editor:
		fact_store_editor.show()

func _set_action_store() -> void:
	if show_action_store_button and not show_action_store_button.button_pressed:
		show_action_store_button.button_pressed = true
	_clear()
	if action_store_editor:
		action_store_editor.show()

func _on_show_character_store_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		current_store = Store.CHARACTER
		if show_fact_store_button:
			show_fact_store_button.button_pressed = false
		if show_action_store_button:
			show_action_store_button.button_pressed = false

func _on_show_fact_store_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		current_store = Store.FACT
		if show_character_store_button:
			show_character_store_button.button_pressed = false
		if show_action_store_button:
			show_action_store_button.button_pressed = false

func _on_show_action_store_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		current_store = Store.ACTION
		if show_fact_store_button:
			show_fact_store_button.button_pressed = false
		if show_character_store_button:
			show_character_store_button.button_pressed = false
