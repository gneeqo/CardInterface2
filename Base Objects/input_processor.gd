class_name InputProcessor extends Node

static var time_scales : Array[float] =[0.5,1,2,4]

static var automating = false
static var menu_automating = false

static var mouse_just_pressed = false
static var mouse_down = false
static var escape_just_pressed = false



static var mouse_pos:Vector2

static var current_time_scale_index : int = 1

static var time_scale : float :
	get:
		if automating:
			return 5.0
		return time_scales[current_time_scale_index]


func _process(dt:float):
	
	if(Input.is_action_just_pressed("Automate")):
		if automating:
			if not menu_automating:
				menu_automating = true
			else:
				menu_automating = false
				automating = false
		else:
			automating = true
		
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
	
	var rng = RandomNumberGenerator.new()
	for node in get_tree().get_nodes_in_group("auto_selectable"):
			if(rng.randf_range(0,10) >5):
				node.auto_select(rng.randi_range(0,node.item_count-1))
	for node in get_tree().get_nodes_in_group("auto_clickable"):
			if(rng.randf_range(0,10) >5):
				node.auto_press()
	
	
	if menu_automating:
		if(rng.randf_range(0,10) >5):
			escape_just_pressed = true
