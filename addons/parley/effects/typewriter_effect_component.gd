extends Node
class_name TypewriterEffectComponent


signal typed
signal finished


@export var rich_text_label_for_typewriter_effect : RichTextLabel
@export var time_between_characters_in_seconds : float = 0.05


var _character_timer : float = 0.0
var enabled : bool = false


func _ready() -> void:
	add_to_group("parley_typewriter_effect")
	
	
	enabled = ParleyUtils.Settings.get_setting(ParleyUtils.Constants.TYPEWRITER_EFFECT)
	
	if not enabled:
		return
	
	
	var typewriters = get_tree().get_nodes_in_group("parley_typewriter_effect")
	print(typewriters)
	#only worry about other typewriters if we are not the first added to the scene tree
	if enabled and typewriters.size() > 1:
		#we werent the first in the scene tree, disable ourselves for now.
		enabled = false
		#figure out which typewriter came before us.
		var my_index = typewriters.find(self)
		#ask that typewriter to let us know when they are finshed
		typewriters[my_index - 1].finished.connect(_on_previous_typewriter_finished)
		
	
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
		else:
			remove_from_group("parley_typewriter_effect")
			finished.emit()


#checked by default_balloon
func is_finished() -> bool:
	if rich_text_label_for_typewriter_effect.visible_ratio == 1.0:
		return true
	return false


#called by default_balloon when trying to advance dialogue
func force_finished() -> void:
	rich_text_label_for_typewriter_effect.visible_ratio = 1.0
	#since this typewriter is no longer revelant, prevent other typewriters from finding it
	remove_from_group("parley_typewriter_effect")
	finished.emit()


#connected to another typewriter's signal. Should never end up being called if typewriters are disabled
func _on_previous_typewriter_finished() -> void:
	#now that the typewriter before us is finished, enable self and typewrite
	enabled = true


func _exit_tree() -> void:
	#since this typewriter is no longer revelant, prevent other typewriters from finding it
	remove_from_group("parley_typewriter_effect")
