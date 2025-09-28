extends Object
class_name ParleyGraphOperation

# Base class for all Graph operations

func undo() -> void:
	# override in child class
	push_error("undo() not implemented in subclass")

func do() -> void:
	# override in child class
	push_error("redo() not implemented in subclass")