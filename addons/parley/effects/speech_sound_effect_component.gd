extends Node
class_name BeepSpeechEffectComponent


#If you are using speech sounds without the typewriter effect, do not assign anything to this export var
@export var typewriter_effect : TypewriterEffectComponent
@export var audio_stream_player : Node


#if the typewriter is going very fast, the signals could come quickly enough to try to play multiple sounds at
#the same time. This setting can be tweaked to control that.
var _minimum_delay_between_speech_sounds_in_seconds : float = 0.1
#When not using a typewriter effect, this will set how long the sound effects will be played for
var _maximum_speech_sounds_effect_time_in_seconds : float = 5.0
var _beep_interval_timer : float = 0.0
var _total_beep_timer : float = 0.0
var enabled : bool = false
var typewriter_enabled : bool = false


func _ready() -> void:
	enabled = ParleyUtils.Settings.get_setting(ParleyUtils.Constants.SPEECH_SOUND_EFFECT_ACTIVE)
	typewriter_enabled = ParleyUtils.Settings.get_setting(ParleyUtils.Constants.TYPEWRITER_EFFECT_ACTIVE)
	_minimum_delay_between_speech_sounds_in_seconds = ParleyUtils.Settings.get_setting(ParleyUtils.Constants.MINIMUM_DELAY_BETWEEN_SPEECH_SOUNDS_IN_SECONDS)
	_maximum_speech_sounds_effect_time_in_seconds = ParleyUtils.Settings.get_setting(ParleyUtils.Constants.MAXIMUM_SPEECH_SOUNDS_EFFECT_TIME_IN_SECONDS)
	audio_stream_player.stream = load(ParleyUtils.Settings.get_setting(ParleyUtils.Constants.SPEECH_SOUND_AUDIO_STREAM_PATH))
	
	
	if not enabled:
		return
	
	#if the typewriter effect is enabled, we should link up with it
	if typewriter_enabled: 
		if typewriter_effect:
			var _error_code : int = typewriter_effect.typed.connect(beep)
		else:
			push_warning(ParleyUtils.log.warn_msg("Typewriter Effect is enabled in Parley Settings but BeepSpeechEffectComponent does not have a reference to the TypewriterEffect Node"))
	
	#Sanity check on the assigned audio stream player. The AudioStreamPlayer2D and AudioStreamPlayer3D do not inherit from a shared node.
	#The script supports AudioStreamPlayer3D to be used if a dev wants positional audio for dialogues.
	if audio_stream_player and audio_stream_player is AudioStreamPlayer2D or audio_stream_player is AudioStreamPlayer3D:
		return
	push_warning(ParleyUtils.log.warn_msg("BeepSpeechEffectComponent does not have an AudioStreamPlayer2D or AudioStreamPlayer3D assigned"))


#called via signals to beep in timing with Typewriter Effect
func beep() -> void:
	if not enabled:
		return
	
	#if we have waited longer than the interval, make a beep
	if _beep_interval_timer >= _minimum_delay_between_speech_sounds_in_seconds:
		_beep_interval_timer -= _minimum_delay_between_speech_sounds_in_seconds
		
		#sanity check assigned audio stream player
		if audio_stream_player is AudioStreamPlayer2D or audio_stream_player is AudioStreamPlayer3D:
			@warning_ignore("unsafe_method_access")
			audio_stream_player.play()


func _process(delta: float) -> void:
	if not enabled:
		return
	
	_beep_interval_timer += delta
	_total_beep_timer += delta
	
	#if typewriter is not enabled, or a typewriter effect is not assigned, manage beeps manually
	if not typewriter_enabled or not typewriter_effect:
		if _total_beep_timer < _maximum_speech_sounds_effect_time_in_seconds:
			if _beep_interval_timer > _minimum_delay_between_speech_sounds_in_seconds:
				beep()
