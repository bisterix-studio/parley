@tool
extends HBoxContainer

#region DEFS
@export var key: String = "": set = _set_key
@export var base_type: String = "": set = _set_base_type
@export var resource: Resource: set = _set_resource

@onready var _label: Label = %Label
var _resource_picker

signal resource_changed(resource: Resource)
signal resource_selected(resource: Resource, inspect: bool)
#endregion

#region LIFECYCLE
func _ready() -> void:
	if Engine.is_editor_hint():
		_resource_picker = EditorResourcePicker.new()
		_resource_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_resource_picker.base_type = base_type
		_resource_picker.resource_selected.connect(_on_resource_picker_resource_selected)
		_resource_picker.resource_changed.connect(_on_resource_picker_resource_changed)
		add_child(_resource_picker)
	_render_key()
	_render_base_type()
	_render_resource()
#endregion

#region SETTERS
func _set_key(new_key: String) -> void:
	key = new_key
	_render_key()

func _set_base_type(new_base_type: String) -> void:
	base_type = new_base_type
	_render_base_type()

func _set_resource(new_resource: Resource) -> void:
	resource = new_resource
	_render_resource()
#endregion

#region RENDERERS
func _render_key() -> void:
	if _label:
		_label.text = "%s:" % [key.capitalize()]

func _render_base_type() -> void:
	if Engine.is_editor_hint() and _resource_picker:
		_resource_picker.base_type = base_type

func _render_resource() -> void:
	if Engine.is_editor_hint() and _resource_picker and resource:
		if not _resource_picker.edited_resource or _resource_picker.edited_resource != resource:
			_resource_picker.edited_resource = resource
#endregion

#region SIGNALS
func _on_resource_picker_resource_changed(new_resource: Resource) -> void:
	resource = new_resource
	resource_changed.emit(resource)

func _on_resource_picker_resource_selected(resource: Resource, inspect: bool) -> void:
	resource_selected.emit(resource, inspect)
#endregion
