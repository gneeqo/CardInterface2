class_name BehaviorFactory extends Node

static func translate_then_callback(function:Callable,location:Vector2, duration:float , drift:float = 0 ,\
 eased:bool = true, ease_type:Action.EaseType = Action.EaseType.easeInOutSine) -> Executor:
	var new_executor = ExecAutoActivate.new()
	new_executor.add_child(ActionFactory.translate_to(location,duration,true,ease_type,drift,true))
	new_executor.add_child(ActionFactory.callback(function))
	
	
	return new_executor
