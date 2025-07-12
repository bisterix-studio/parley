# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyCharacterStore extends ParleyStore

#region DEFS
@export var characters: Array[ParleyCharacter] = []


signal character_added(character: ParleyCharacter)
signal character_removed(character_id: String)
#endregion


#region LIFECYCLE
func _init(_id: String = "", _characters: Array[ParleyCharacter] = []) -> void:
	id = _id
	characters = _characters
#endregion


#region SETTERS
func _set_characters(new_characters: Array[ParleyCharacter]) -> void:
	characters = new_characters
#endregion


#region CRUD
func add_character(name: String = "") -> ParleyCharacter:
	var character: ParleyCharacter = ParleyCharacter.new(name.to_snake_case().to_lower(), name)
	characters.append(character)
	character_added.emit(character)
	emit_changed()
	return character


func remove_character(character_id: String) -> void:
	var index_to_remove: int = characters.find_custom(func(character: ParleyCharacter) -> bool: return character.id == character_id)
	characters.remove_at(index_to_remove)
	character_removed.emit(character_id)
	emit_changed()


# TODO: docs


func _get_character_by_id(character_id: String) -> ParleyCharacter:
	var filtered_characters: Array = characters.filter(func(character: ParleyCharacter) -> bool: return character.id == character_id)
	if filtered_characters.size() == 0:
		if character_id != "":
			push_warning(ParleyUtils.log.warn_msg("Character not found in store (id:%s, store:%s), returning an empty Character" % [character_id, self]))
		return ParleyCharacter.new()
	return filtered_characters.front()


func get_ref_by_index(index: int) -> String:
	if index == -1 or index >= characters.size():
		return ""
	return "%s::%s" % [ParleyUtils.resource.get_uid(self), characters[index].id]


func get_character_index_by_ref(character_ref: String) -> int:
	var parts: PackedStringArray = character_ref.split('::')
	if parts.size() != 2 or not ResourceLoader.exists(parts[0]):
		if character_ref != "":
			push_warning(ParleyUtils.log.warn_msg("Unable to find Character index, defaulting to -1 (ref:%s)" % character_ref))
		return -1
	var idx: int = 0
	for character: ParleyCharacter in characters:
		if character.id == parts[1]:
			return idx
		idx += 1
	return -1


func get_character_by_ref(character_ref: String) -> ParleyCharacter:
	var parts: PackedStringArray = character_ref.split('::')
	if parts.size() == 0 or not ResourceLoader.exists(parts[0]):
		if character_ref != "":
			push_warning(ParleyUtils.log.warn_msg("Unable to find Character, defaulting to Unknown (ref:%s)" % character_ref))
		return ParleyCharacter.new("", "Unknown")
	if parts.size() > 1:
		return _get_character_by_id(parts[1])
	var resource: Variant = load(parts[0])
	if resource is ParleyCharacter:
		return resource
	return ParleyCharacter.new("", "Unknown")


static func resolve_character_ref(character_ref: String) -> ParleyCharacter:
	var parts: PackedStringArray = character_ref.split('::')
	if parts.size() == 0 or not ResourceLoader.exists(parts[0]):
		push_warning(ParleyUtils.log.warn_msg("Unable to find Character, defaulting to Unknown (ref:%s)" % character_ref))
		return ParleyCharacter.new("", "Unknown")
	var resource: Variant = load(parts[0])
	if resource is ParleyCharacterStore and parts.size() > 1:
		var store: ParleyCharacterStore = resource
		return store._get_character_by_id(parts[1])
	if resource is ParleyCharacter:
		return resource
	return ParleyCharacter.new("", "Unknown")
#endregion


#region HELPERS
func _to_string() -> String:
	return "ParleyCharacterStore<id:%s, characters:%d>" % [id, characters.size()]
#endregion
