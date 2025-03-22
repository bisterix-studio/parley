@tool
extends PanelContainer

var available_character_store_paths: Array[String]: get = _get_available_character_store_paths
var available_character_stores: Array[CharacterStore] = []
var selected_character_stores: Array[CharacterStore] = []: set = _set_selected_character_stores

@onready var available_character_store_menu: MenuButton = %AvailableCharacterStores
@onready var character_store_selector: OptionButton = %CharacterStoreSelector

func _ready() -> void:
	_setup()
	_render_available_character_store_menu()
	_render_selected_character_stores()

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

func _on_available_character_store_pressed(id: int) -> void:
	var popup: PopupMenu = available_character_store_menu.get_popup()
	var index: int = popup.get_item_index(id)
	popup.set_item_checked(index, not popup.is_item_checked(index))
	_set_selected_character_store(index)

func _set_selected_character_store(index: int) -> void:
	var new_character_stores = selected_character_stores
	var selected_character_store = available_character_stores[index]
	var selected_character_store_index = selected_character_stores.find(selected_character_store)
	if selected_character_store_index == -1:
		new_character_stores.append(selected_character_store)
	else:
		new_character_stores.remove_at(selected_character_store_index)
	selected_character_stores = new_character_stores

func _set_selected_character_stores(new_selected_character_stores: Array[CharacterStore]) -> void:
	selected_character_stores = new_selected_character_stores
	_render_available_character_store_menu()
	_render_selected_character_stores()

func _render_selected_character_stores() -> void:
	if not character_store_selector:
		return
	character_store_selector.clear()
	if not selected_character_stores:
		return
	for character_store: CharacterStore in selected_character_stores:
		character_store_selector.add_item(str(character_store.id).capitalize())
	# TODO: account for current selected to make for better UX rather than
	# just taking the first item all the time
	character_store_selector.select(0 if selected_character_stores.size() > 0 else -1)

func _setup() -> void:
	for character_store_path in available_character_store_paths:
		available_character_stores.append(load(character_store_path))

func _get_available_character_store_paths() -> Array[String]:
	return ParleyManager.character_stores

func _render_available_character_stores() -> void:
	if not character_store_selector:
		return
	character_store_selector.clear()
	if not available_character_stores:
		return
	for available_character_store: CharacterStore in available_character_stores:
		character_store_selector.add_item(str(available_character_store.id).capitalize())
	character_store_selector.select(0 if available_character_stores.size() > 0 else -1)
