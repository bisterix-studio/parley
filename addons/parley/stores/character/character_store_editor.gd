@tool
class_name ParleyCharacterStoreEditor extends PanelContainer


#region DEFS
const CharacterEditor: PackedScene = preload("../../components/character/character_editor.tscn")


var dialogue_sequence_ast: DialogueAst: set = _set_dialogue_sequence_ast
var available_character_store_paths: Array[String]: get = _get_available_character_store_paths
var available_character_stores: Dictionary[String, CharacterStore] = {}
var character_filter: String = "": set = _set_character_filter
var selected_character_stores: Array[String] = []: set = _set_selected_character_stores
var characters: Array[Character] = []: set = _set_characters
var filtered_characters: Array[Character] = []


@onready var available_character_store_label: Label = %AvailableCharacterStoresLabel
@onready var available_character_store_menu: MenuButton = %AvailableCharacterStores
@onready var character_store_selector_label: Label = %CharacterStoreSelectorLabel
@onready var character_store_selector: OptionButton = %CharacterStoreSelector
@onready var characters_container: VBoxContainer = %CharactersContainer
@onready var dialogue_sequence_container: ParleyResourceEditor = %DialogueSequenceContainer
@onready var add_character_button: Button = %AddCharacterButton
@onready var register_character_store: ParleyRegisterStoreModal = %RegisterCharacterStoreModal


signal dialogue_sequence_ast_selected(dialogue_sequence_ast: DialogueAst)
signal dialogue_sequence_ast_changed(dialogue_sequence_ast: DialogueAst)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_setup()
	_render()


func _setup() -> void:
	_setup_available_character_stores()


func _clear_characters() -> void:
	for child: Node in characters_container.get_children():
		child.queue_free()
#endregion


#region SETTERS
func _update_characters() -> void:
	if character_store_selector and character_store_selector.selected != -1:
		# The first item is always the combined view
		if character_store_selector.selected == 0:
			var all_characters: Array[Character] = []
			# TODO: there is the chance of duplicates here but let's allow this for now
			for character_store: CharacterStore in available_character_stores.values():
				all_characters.append_array(character_store.characters)
			characters = all_characters
		else:
			var selected_character_store_ref: String = selected_character_stores[character_store_selector.selected - 1]
			var selected_character_store: CharacterStore = available_character_stores.get(selected_character_store_ref)
			characters = selected_character_store.characters


func _setup_available_character_stores() -> void:
	available_character_stores = {}
	for character_store_path: String in available_character_store_paths:
		var character_store: CharacterStore = load(character_store_path)
		if character_store.resource_path and not available_character_stores.has(character_store.resource_path):
			var _set_ok: bool = available_character_stores.set(character_store.resource_path, character_store)


func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: DialogueAst) -> void:
	if dialogue_sequence_ast != new_dialogue_sequence_ast:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		_reload_dialogue_sequence_ast()


func _reload_dialogue_sequence_ast() -> void:
	_render_dialogue_sequence()
	var new_selected_character_stores: Array[String] = []
	for store: CharacterStore in dialogue_sequence_ast.stores.character:
		new_selected_character_stores.append(store.resource_path)
	selected_character_stores = new_selected_character_stores


func _set_selected_character_stores(new_selected_character_stores: Array[String]) -> void:
	if selected_character_stores != new_selected_character_stores:
		selected_character_stores = new_selected_character_stores
		_render_available_character_store_menu()
		_render_selected_character_stores()
		_update_characters()


func _set_selected_character_store(index: int) -> void:
	var new_character_stores: Array[String] = selected_character_stores.duplicate(true)
	var selected_character_store: CharacterStore = available_character_stores.values()[index]
	var selected_character_store_index: int = selected_character_stores.find(selected_character_store.resource_path)
	if selected_character_store_index == -1:
		new_character_stores.append(selected_character_store.resource_path)
		# TODO: handle deregistration
		_register_character_store(selected_character_store, false)
	else:
		new_character_stores.remove_at(selected_character_store_index)
	selected_character_stores = new_character_stores


func _set_characters(new_characters: Array[Character]) -> void:
	characters = new_characters
	filtered_characters = []
	for character: Character in characters:
		var raw_character_string: String = str(inst_to_dict(character))
		if not character_filter or raw_character_string.containsn(character_filter):
			filtered_characters.append(character)
	_render_characters()


func _set_character_filter(new_character_filter: String) -> void:
	character_filter = new_character_filter
	_set_characters(characters)
#endregion


#region RENDERERS
func _render() -> void:
	_render_available_character_store_menu()
	_render_dialogue_sequence()
	_render_selected_character_stores()
	_render_add_character_button()
	_update_characters()
	_render_characters()


func _render_available_character_store_menu() -> void:
	if not available_character_store_menu:
		return
	var popup: PopupMenu = available_character_store_menu.get_popup()
	popup.clear()
	var index: int = 0
	for available_character_store: CharacterStore in available_character_stores.values():
		popup.add_check_item(str(available_character_store.id).capitalize())
		var checked: bool = selected_character_stores.filter(func(ref: String) -> bool:
				if not available_character_stores.has(ref):
					return false
				var character_store: CharacterStore = available_character_stores.get(ref)
				return character_store.id == available_character_store.id).size() > 0
		popup.set_item_checked(index, checked)
		index += 1
	ParleyUtils.safe_connect(popup.id_pressed, _on_available_character_store_pressed)
	popup.hide_on_checkable_item_selection = false
	available_character_store_label.text = "Available:"
	available_character_store_menu.text = "%s/%s Selected" % [selected_character_stores.size(), available_character_stores.size()]
	character_store_selector_label.text = "Selected:"


func _render_dialogue_sequence() -> void:
	if dialogue_sequence_container and dialogue_sequence_ast and dialogue_sequence_ast.resource_path:
		dialogue_sequence_container.base_type = DialogueAst.type_name
		dialogue_sequence_container.resource = dialogue_sequence_ast


func _render_available_character_stores() -> void:
	if not character_store_selector:
		return
	character_store_selector.clear()
	if not available_character_stores:
		return
	for available_character_store: CharacterStore in available_character_stores.values():
		character_store_selector.add_item(str(available_character_store.id).capitalize())
	character_store_selector.select(0 if available_character_stores.size() > 0 else -1)


func _render_add_character_button() -> void:
	if add_character_button and character_store_selector:
		add_character_button.tooltip_text = "Add Character to the currently selected store. If no store is explicitly set, this button will not be activated."
		# This is because the first option is always the "All" option
		add_character_button.disabled = [0, -1].has(character_store_selector.selected)


func _render_selected_character_stores() -> void:
	if not character_store_selector:
		return
	var current_text: String = character_store_selector.get_item_text(character_store_selector.selected) if character_store_selector.selected != -1 else ""
	character_store_selector.clear()
	character_store_selector.add_item('All')
	var items: Array[String] = []
	for character_store_ref: String in selected_character_stores:
		var character_store: CharacterStore = load(character_store_ref)
		var text: String = str(character_store.id).capitalize()
		items.append(text)
		character_store_selector.add_item(text)
	var current_index: int = items.find(current_text)
	if current_index == -1:
		current_index = 0
	else:
		current_index += 1
	character_store_selector.select(current_index)


func _render_characters() -> void:
	if characters_container:
		_clear_characters()
		var index: int = 0
		for character: Character in filtered_characters:
			var character_editor: ParleyCharacterEditor = CharacterEditor.instantiate()
			character_editor.character_id = character.id
			character_editor.character_name = character.name
			ParleyUtils.safe_connect(character_editor.character_changed, _on_character_changed.bind(character))
			ParleyUtils.safe_connect(character_editor.character_removed, _on_character_removed.bind(character))
			characters_container.add_child(character_editor)
			if index != filtered_characters.size() - 1:
				var horizontal_separator: HSeparator = HSeparator.new()
				characters_container.add_child(horizontal_separator)
			index += 1
#endregion


#region SIGNALS
func _on_character_changed(new_id: String, new_name: String, character: Character) -> void:
	character.id = new_id
	character.name = new_name
	var store_ref: String = CharacterStore.get_character_store_ref(character)
	if available_character_stores.has(store_ref):
		var store: CharacterStore = available_character_stores.get(store_ref)
		if store.resource_path == store_ref:
			store.emit_changed()


func _on_character_removed(character_id: String, character: Character) -> void:
	var store_ref: String = CharacterStore.get_character_store_ref(character)
	if available_character_stores.has(store_ref):
		var store: CharacterStore = available_character_stores.get(store_ref)
		if store.resource_path == store_ref:
			store.remove_character(character_id)
	_render_selected_character_stores()
	_render_add_character_button()
	_update_characters()
	_render_characters()


func _on_add_character_button_pressed() -> void:
	if character_store_selector and not [-1, 0].has(character_store_selector.selected):
		var character_store_ref: String = selected_character_stores[character_store_selector.selected - 1]
		if available_character_stores.has(character_store_ref):
			var store: CharacterStore = available_character_stores.get(character_store_ref)
			if store.resource_path == character_store_ref:
				var _new_character: Character = store.add_character()
		_render_selected_character_stores()
		_render_add_character_button()
		_update_characters()
		_render_characters()


func _on_available_character_store_pressed(id: int) -> void:
	var popup: PopupMenu = available_character_store_menu.get_popup()
	var index: int = popup.get_item_index(id)
	var selected: bool = not popup.is_item_checked(index)
	popup.set_item_checked(index, selected)
	_set_selected_character_store(index)


func _on_character_store_selector_item_selected(_index: int) -> void:
	_render_add_character_button()
	_update_characters()


func _on_filter_characters_text_changed(new_character_filter: String) -> void:
	character_filter = new_character_filter


func _on_save_character_store_button_pressed() -> void:
	_save()


func _on_new_character_store_button_pressed() -> void:
	register_character_store.show()
	register_character_store.clear()
	register_character_store.file_mode = FileDialog.FileMode.FILE_MODE_SAVE_FILE


func _on_dialogue_sequence_container_resource_changed(new_dialogue_sequence_ast: Resource) -> void:
	if new_dialogue_sequence_ast is DialogueAst:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		dialogue_sequence_ast_changed.emit(dialogue_sequence_ast)


func _on_dialogue_sequence_container_resource_selected(selected_dialogue_sequence_ast: Resource, _inspect: bool) -> void:
	if dialogue_sequence_ast is DialogueAst:
		dialogue_sequence_ast_selected.emit(selected_dialogue_sequence_ast)


func _on_register_character_store_modal_store_registered(store: StoreAst) -> void:
	_register_character_store(store, true)
#endregion


#region ACTIONS
func _register_character_store(store: StoreAst, new: bool) -> void:
	if store is CharacterStore:
		var character_store: CharacterStore = store
		if new:
			ParleyManager.register_character_store(character_store)
		if dialogue_sequence_ast:
			dialogue_sequence_ast.stores.register_character_store(character_store)
			var _ok: int = ResourceSaver.save(dialogue_sequence_ast)
		_reload_dialogue_sequence_ast()
		_setup()
		_render()
		# TODO: Select this as the current character store


func _save() -> void:
	if character_store_selector and character_store_selector.selected != -1:
		if character_store_selector.selected == 0:
			for character_store_ref: String in selected_character_stores:
				var character_store: CharacterStore = available_character_stores.get(character_store_ref)
				var result: int = ResourceSaver.save(character_store)
				if result != OK:
					ParleyUtils.log.error("Error saving character store [ID: %s]. Code: %d" % [character_store.id, result])
					return
		else:
			var character_store_ref: String = selected_character_stores[character_store_selector.selected - 1]
			var character_store: CharacterStore = load(character_store_ref)
			var result: int = ResourceSaver.save(character_store)
			if result != OK:
				ParleyUtils.log.error("Error saving character store [ID: %s]. Code: %d" % [character_store.id, result])
				return
#endregion


#region UTILS
func _get_available_character_store_paths() -> Array[String]:
	return ParleyManager.character_stores
#endregion
