# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyEditorUtils


## When a file is created (especially one that has a new directory), the file system is not
## immediately updated. Therefore, we must wait for this to be updated before loading
## the saved resource into memory for use within the Parley Graph view.
static func refresh_filesystem_and_wait(timeout: Signal) -> void:
	var fs := EditorInterface.get_resource_filesystem()
	fs.scan()
	ParleyUtils.signals.safe_connect(timeout, _emit_filesystem_changed.bind(timeout))
	while fs.get_scanning_progress() < 1.0:
		await fs.filesystem_changed
	ParleyUtils.signals.safe_disconnect(timeout, _emit_filesystem_changed)


static func _emit_filesystem_changed(timeout: Signal) -> void:
	EditorInterface.get_resource_filesystem().filesystem_changed.emit()
	ParleyUtils.signals.safe_disconnect(timeout, _emit_filesystem_changed)
