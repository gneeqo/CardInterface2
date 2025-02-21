class_name CallbackAfter extends Action


@export var function : Callable
@export var params : Array


func _end_action():
	if params.size() > 0:
		function.callv(params)	
	else:
		function.call()
