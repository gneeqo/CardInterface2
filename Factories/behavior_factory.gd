class_name BehaviorFactory extends Node

static func translate_then_callback(function:Callable,location:Vector2, duration:float , drift:float = 0 ,\
 eased:bool = true, ease_type:Action.EaseType = Action.EaseType.easeInOutSine) -> Executor:
	var new_executor = ExecAutoActivate.new()
	new_executor.add_child(ActionFactory.translate_to(location,duration,eased,ease_type,drift,true))
	new_executor.add_child(ActionFactory.callback(function))

	return new_executor

static func delayed_callback(function:Callable,duration:float = 0.01 ) -> Executor:
	var new_executor = ExecAutoActivate.new()
	new_executor.add_child(ActionFactory.callback(function,duration))

	return new_executor

static func rotate(angle:float, duration:float , drift:float = 0 ,\
 eased:bool = true, ease_type:Action.EaseType = Action.EaseType.easeInOutSine) -> Executor:
	var new_executor = ExecAutoActivate.new()
	new_executor.add_child(ActionFactory.rotate_to(angle,duration,eased,ease_type,drift))
	return new_executor

static func scale(new_scale:Vector2, duration:float , drift:float = 0 ,\
 eased:bool = true, ease_type:Action.EaseType = Action.EaseType.easeInOutSine) -> Executor:
	var new_executor = ExecAutoActivate.new()
	new_executor.add_child(ActionFactory.scale_to(new_scale,duration,eased,ease_type,drift))
	return new_executor
