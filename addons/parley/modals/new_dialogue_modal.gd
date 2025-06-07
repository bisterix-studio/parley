@tool
extends Window

@onready var path_edit: LineEdit = %PathEdit
@onready var choose_path_modal: FileDialog = %ChoosePathModal

signal dialogue_ast_created(dialogue_ast: ParleyDialogueSequenceAst)


# TODO: is this needed?
func _exit_tree() -> void:
	path_edit.text = ""


func _on_file_dialog_file_selected(path: String) -> void:
	path_edit.text = path


func _on_choose_path_button_pressed() -> void:
	choose_path_modal.show()
	# TODO: get this from config (note, see the Node inspector as well)
	choose_path_modal.current_dir = "res://dialogue_sequences"
	choose_path_modal.current_file = "new_dialogue.ds"


func _on_cancel_button_pressed() -> void:
	hide()


func _on_create_button_pressed() -> void:
	var dialogue_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new()
	var dialogue_ast_path: String = path_edit.text
	var result: int = ResourceSaver.save(dialogue_ast, dialogue_ast_path)
	if result != OK:
		ParleyUtils.log.error("Unable to save Dialogue Sequence at path %" % dialogue_ast_path)
		return
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().reimport_files([dialogue_ast_path])
	dialogue_ast_created.emit(load(dialogue_ast_path))
	hide()
