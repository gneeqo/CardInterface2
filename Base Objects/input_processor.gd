class_name InputProcessor extends Node

static var automating = false
static var mouse_just_pressed = false
static var mouse_down = false
static var escape_just_pressed = false


static var mouse_pos:Vector2

static var time_scale : float = 1.0


func _process(dt:float):
	
	if(Input.is_action_just_pressed("Automate")):
		automating = ! automating
		
	if automating:
		mouse_just_pressed = false
		mouse_down = false
		mouse_pos = Vector2(0,0)
		escape_just_pressed = false
		
		automate_input()
	else:
		time_scale = 1
		mouse_just_pressed =  Input.is_action_just_pressed("mouse_click")
		mouse_down = Input.is_action_pressed("mouse_click")
		mouse_pos = get_viewport().get_mouse_position()
		
		escape_just_pressed = Input.is_action_just_pressed("escape")
		
	
	
func automate_input():
	var clickable_nodes:Array[Node]
	time_scale = 5
	for node in get_tree().get_nodes_in_group("auto_clickable"):
			clickable_nodes.push_back(node)
	
	
	
	var rng = RandomNumberGenerator.new()
	for node in clickable_nodes:
		if(rng.randf_range(0,10) >5):
			node.auto_press()
	
	if(rng.randf_range(0,10) >5):
		escape_just_pressed = true
