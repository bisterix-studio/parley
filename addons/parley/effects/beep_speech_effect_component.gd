extends Node
class_name BeepSpeechEffectComponent


#If you are using beep speech without the typewriter effect, do not assign anything to this export var
@export var typewriter_effect : TypewriterEffectComponent
@export var audio_stream_player : Node
@export var minimum_delay_between_beeps_in_seconds : float = 0.1
#When not using a typewriter effect, this will set how long the beeps will be played for
@export var maximum_beep_time_in_seconds : float = 5.0


var _beep_interval_timer : float = 0.0
var _total_beep_timer : float = 0.0
var enabled : bool = false


func _ready() -> void:
	enabled = ParleyUtils.Settings.get_setting(ParleyUtils.Constants.BEEP_SPEECH_EFFECT)
	if not enabled:
		return
	if typewriter_effect:
		var _error_code : int = typewriter_effect.typed.connect(beep)
	if audio_stream_player and audio_stream_player is AudioStreamPlayer2D or audio_stream_player is AudioStreamPlayer3D:
		return
	push_warning("BeepSpeechEffectComponent does not have an AudioStreamPlayer2D or AudioStreamPlayer3D assigned")


func beep() -> void:
	if not enabled:
		return
	if _beep_interval_timer >= minimum_delay_between_beeps_in_seconds:
		_beep_interval_timer -= minimum_delay_between_beeps_in_seconds
		if audio_stream_player is AudioStreamPlayer2D or audio_stream_player is AudioStreamPlayer3D:
			@warning_ignore("unsafe_method_access")
			audio_stream_player.play()


func _process(delta: float) -> void:
	if not enabled:
		return
	if not typewriter_effect:
		if _total_beep_timer < maximum_beep_time_in_seconds:
			if _beep_interval_timer > minimum_delay_between_beeps_in_seconds:
				beep()
	_beep_interval_timer += delta
	_total_beep_timer += delta
