class_name CallbackDuring extends Action

@export var function : Callable
@export var params : Array


func _lerp_value(alpha:float):
	if params.size() >0:
		function.callv(params)
	else:
		function.call()



func _clone():
	var new_action = super._clone()
	return new_action
