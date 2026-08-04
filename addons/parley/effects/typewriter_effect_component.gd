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
	
	#set visible characters to 0 so the typewriter effect can begin
	rich_text_label_for_typewriter_effect.visible_characters = 0


func _process(delta: float) -> void:
	if not enabled:
		return
	
	_character_timer += delta
	#when the interval has elapsed, increase visible characters
	if _character_timer >= time_between_characters_in_seconds:
		_character_timer -= time_between_characters_in_seconds
		#if the visible ratio is 1.0, then all characters have been revealed and the process should stop
		if rich_text_label_for_typewriter_effect.visible_ratio < 1.0:
			rich_text_label_for_typewriter_effect.visible_characters += 1 
			typed.emit()


#checked by default_balloon
func is_finished() -> bool:
	if rich_text_label_for_typewriter_effect.visible_ratio == 1.0:
		return true
	return false


#called by default_balloon when trying to advance dialogue
func force_finished() -> void:
	rich_text_label_for_typewriter_effect.visible_ratio = 1.0
