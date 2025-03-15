@tool
extends Window

@onready var path_edit: LineEdit = %PathEdit
@onready var choose_path_modal: FileDialog = %ChoosePathModal

signal dialogue_ast_created(dialogue_ast: DialogueAst)


func _on_file_dialog_file_selected(path: String) -> void:
	path_edit.text = path


func _on_choose_path_button_pressed() -> void:
	choose_path_modal.show()
	# TODO: get this from config (note, see the Node inspector as well)
	choose_path_modal.current_dir = "res://dialogue"
	choose_path_modal.current_file = "new_dialogue.dlog"


func _on_cancel_button_pressed() -> void:
	hide()


func _on_create_button_pressed() -> void:
	var dialogue_ast = DialogueAst.new()
	var dialogue_ast_path = path_edit.text
	ResourceSaver.save(dialogue_ast, dialogue_ast_path)
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().reimport_files([dialogue_ast_path])
	dialogue_ast_created.emit(load(dialogue_ast_path))
	hide()
