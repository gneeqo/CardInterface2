class_name ActionFactory extends Node



static func translate_to(location:Vector2,duration:float,\
eased:bool = true, ease_type:Action.EaseType = Action.EaseType.easeInOutSine,\
 drift:float = 0 ,blocking:bool = false,looping:bool = false, oscillating:bool = false)->Translate:
	var newAction = Translate.new()
	
	newAction.target = location
	newAction.drift = drift
	newAction.duration = duration
	newAction.eased = eased
	newAction.ease_type = ease_type
	newAction.blocking = blocking
	newAction.looping = looping
	newAction.oscillating = oscillating
	
	
	return newAction

static func callback(function:Callable,duration:float = 0.01,\
eased:bool = false, ease_type:Action.EaseType = Action.EaseType.easeInOutSine,\
 blocking:bool = false,looping:bool = false, oscillating:bool = false)->Callback:
	var newAction = Callback.new()
	
	newAction.function = function

	newAction.duration = duration
	newAction.eased = eased
	newAction.ease_type = ease_type
	newAction.blocking = blocking
	newAction.looping = looping
	newAction.oscillating = oscillating
	
	
	return newAction
