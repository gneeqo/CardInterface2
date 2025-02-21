class_name Callback extends Action

var function : Callable

func _end_action():
	if function.is_valid():
		function.call()

func _clone():
	var new_action = super._clone()
	new_action.function = function
	return new_action
