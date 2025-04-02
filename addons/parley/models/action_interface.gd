# TODO: prefix with Parley
class_name ActionInterface extends Node

func execute(ctx: Dictionary, values: Array) -> void:
	push_error('PARLEY_ERR: Action not implemented')
