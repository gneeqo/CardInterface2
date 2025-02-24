class_name Rotate extends Action

@export_range(0, 360, 0.1, "radians_as_degrees") var target_angle: float
@export_range(0,359,0.001,"radians_as_degrees") var drift : float = 0.0

var initial_angle : float = 0.0

var final_angle : float 
		


func _begin_action():
	initial_angle = affected_node.global_rotation
	
	if drift != 0:
		var rng = RandomNumberGenerator.new()
		final_angle =  target_angle + rng.randf_range(-drift,drift)
	else:
		final_angle = target_angle
	

func _lerp_value(alpha:float):
	affected_node.global_rotation = lerp(initial_angle,final_angle,alpha)

func _clone():
	var new_action = super._clone()
	new_action.target_angle = target_angle
	new_action.drift = drift
	return new_action
