class_name InputProcessor extends Node


static var automating = false
static var mouse_just_pressed = false
static var mouse_down = false

static var mouse_pos:Vector2

func _process(dt:float):
	if automating:
		automate_input()
	else:
		mouse_just_pressed =  Input.is_action_just_pressed("mouse_click")
		mouse_down = Input.is_action_pressed("mouse_click")
		
		mouse_pos = get_viewport().get_mouse_position()
	
	
func automate_input():
	pass
