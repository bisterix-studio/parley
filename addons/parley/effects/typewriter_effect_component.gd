extends Node
class_name TypewriterEffectComponent


signal typed


@export var rich_text_label_for_typewriter_effect : RichTextLabel
@export var time_between_characters_in_seconds : float = 0.05


var _character_timer : float = 0.0
var enabled : bool = false


func _ready() -> void:
	enabled = ParleyUtils.Settings.get_setting(ParleyUtils.Constants.TYPEWRITER_EFFECT)
	if not enabled:
		return
	rich_text_label_for_typewriter_effect.visible_characters = 0


func _process(delta: float) -> void:
	if not enabled:
		return
	_character_timer += delta
	if _character_timer >= time_between_characters_in_seconds:
		_character_timer -= time_between_characters_in_seconds
		if rich_text_label_for_typewriter_effect.visible_ratio < 1.0:
			rich_text_label_for_typewriter_effect.visible_characters += 1 
			typed.emit()
