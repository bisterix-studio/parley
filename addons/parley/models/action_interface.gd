class_name ParleyActionInterface extends Node

# We want these parameters to render correctly in the docs for this interface so explicitly ignoring for now
func execute(ctx: Dictionary, values: Array) -> int:
	push_error('PARLEY_ERR: Action not implemented (ctx:%s, values:%s)' % [ctx, values])
	return FAILED
