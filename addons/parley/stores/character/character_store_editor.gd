@tool
extends PanelContainer

#region VARIABLES
const CharacterEditor = preload("../../components/character/character_editor.tscn")

var available_character_store_paths: Array[String]: get = _get_available_character_store_paths
var available_character_stores: Array[CharacterStore] = []
var selected_character_stores: Array[CharacterStore] = []: set = _set_selected_character_stores
var characters: Array[Character] = []: set = _set_characters
var filtered_characters: Array[Character] = []
var character_filter: String = "": set = _set_character_filter

@onready var available_character_store_label: Label = %AvailableCharacterStoresLabel
@onready var available_character_store_menu: MenuButton = %AvailableCharacterStores
@onready var character_store_selector_label: Label = %CharacterStoreSelectorLabel
@onready var character_store_selector: OptionButton = %CharacterStoreSelector
@onready var characters_filter: LineEdit = %FilterCharacters
@onready var characters_container: VBoxContainer = %CharactersContainer
#endregion

#region LIFECYCLE
func _ready() -> void:
	_setup()
	_render_available_character_store_menu()
	_render_selected_character_stores()
	_update_characters()
	_render_characters()

func _setup() -> void:
	for character_store_path in available_character_store_paths:
		available_character_stores.append(load(character_store_path))

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
			for character_store: CharacterStore in available_character_stores:
				all_characters.append_array(character_store.characters)
			characters = all_characters
		else:
			var selected_character_store: CharacterStore = selected_character_stores[character_store_selector.selected - 1]
			characters = selected_character_store.characters

func _set_selected_character_stores(new_selected_character_stores: Array[CharacterStore]) -> void:
	selected_character_stores = new_selected_character_stores
	_render_available_character_store_menu()
	_render_selected_character_stores()
	_update_characters()

func _set_selected_character_store(index: int) -> void:
	var new_character_stores = selected_character_stores
	var selected_character_store = available_character_stores[index]
	var selected_character_store_index = selected_character_stores.find(selected_character_store)
	if selected_character_store_index == -1:
		new_character_stores.append(selected_character_store)
	else:
		new_character_stores.remove_at(selected_character_store_index)
	selected_character_stores = new_character_stores

func _set_characters(new_characters: Array[Character]) -> void:
	characters = new_characters
	filtered_characters = []
	for character in characters:
		var raw_character_string = str(inst_to_dict(character))
		if not character_filter or raw_character_string.containsn(character_filter):
			filtered_characters.append(character)
	_render_characters()

func _set_character_filter(new_character_filter: String) -> void:
	character_filter = new_character_filter
	_set_characters(characters)
#endregion

#region RENDERERS
func _render_available_character_store_menu() -> void:
	if not available_character_store_menu:
		return
	var popup: PopupMenu = available_character_store_menu.get_popup()
	popup.clear()
	var index: int = 0
	for available_character_store in available_character_stores:
		popup.add_check_item(str(available_character_store.id).capitalize())
		var checked: bool = selected_character_stores.filter(func(c: CharacterStore) -> bool: return c.id == available_character_store.id).size() > 0
		popup.set_item_checked(index, checked)
		index += 1
	if not popup.id_pressed.is_connected(_on_available_character_store_pressed):
		popup.id_pressed.connect(_on_available_character_store_pressed)
	popup.hide_on_checkable_item_selection = false
	available_character_store_label.text = "Available:"
	available_character_store_menu.text = "%s/%s Selected" % [selected_character_stores.size(), available_character_stores.size()]
	character_store_selector_label.text = "Selected:"

func _render_available_character_stores() -> void:
	if not character_store_selector:
		return
	character_store_selector.clear()
	if not available_character_stores:
		return
	for available_character_store: CharacterStore in available_character_stores:
		character_store_selector.add_item(str(available_character_store.id).capitalize())
	character_store_selector.select(0 if available_character_stores.size() > 0 else -1)

func _render_selected_character_stores() -> void:
	if not character_store_selector:
		return
	character_store_selector.clear()
	character_store_selector.add_item('All')
	for character_store: CharacterStore in selected_character_stores:
		character_store_selector.add_item(str(character_store.id).capitalize())
	# TODO: account for current selected to make for better UX rather than
	# just taking the first item all the time
	character_store_selector.select(0)

func _render_characters() -> void:
	if characters_container:
		_clear_characters()
		var index: int = 0
		for character: Character in filtered_characters:
			var character_editor = CharacterEditor.instantiate()
			character_editor.character = character
			characters_container.add_child(character_editor)
			if index != filtered_characters.size() - 1:
				var horizontal_separator: HSeparator = HSeparator.new()
				characters_container.add_child(horizontal_separator)
			index += 1
#endregion

#region SIGNALS
func _on_available_character_store_pressed(id: int) -> void:
	var popup: PopupMenu = available_character_store_menu.get_popup()
	var index: int = popup.get_item_index(id)
	popup.set_item_checked(index, not popup.is_item_checked(index))
	_set_selected_character_store(index)

func _on_character_store_selector_item_selected(index: int) -> void:
	_update_characters()

func _on_filter_characters_text_changed(new_character_filter: String) -> void:
	character_filter = new_character_filter
#endregion

#region UTILS
func _get_available_character_store_paths() -> Array[String]:
	return ParleyManager.character_stores
#endregion
