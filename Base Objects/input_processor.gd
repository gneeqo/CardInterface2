class_name InputProcessor extends Node

static var time_scales : Array[float] =[0.5,1,2,4]

static var automating = false
static var menu_automating = false

static var mouse_just_pressed = false
static var mouse_down = false
static var escape_just_pressed = false

static var mouse_pos:Vector2

static var current_time_scale_index : int = 1

static var playing_allowed = false

static var card_finished_playing_signal


static var time_scale : float :
	get:
		if automating:
			return 5.0
		return time_scales[current_time_scale_index]


func _process(_dt:float):
	
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
		
		if(playing_allowed):
			if menu_automating:
				take_turn()
			else:
				play_card()
				playing_allowed = false
		
		
	else:
		time_scale = 1
		mouse_just_pressed =  Input.is_action_just_pressed("mouse_click")
		mouse_down = Input.is_action_pressed("mouse_click")
		mouse_pos = get_viewport().get_mouse_position()
		
		escape_just_pressed = Input.is_action_just_pressed("escape")
		
	


func play_card():
	var rng = RandomNumberGenerator.new()
	var card_played:bool = false
	while not card_played:
		for node in get_tree().get_nodes_in_group("auto_clickable"):
				if(rng.randf_range(0,10) >5):
					if(node.auto_press()):
						card_played = true
						break

func take_turn():
	playing_allowed = false
	open_menu()
	var use_menu = BehaviorFactory.delayed_callback(Callable(self,"select_menu_option"),2)
	use_menu.globalList = 1
	add_child(use_menu)
	
func open_menu():
	escape_just_pressed = true

func select_menu_option():
	var rng = RandomNumberGenerator.new()
	for node in get_tree().get_nodes_in_group("auto_selectable"):
			if(rng.randf_range(0,10) >5):
				node.auto_select(rng.randi_range(0,node.item_count-1))
				break
	var callback_close_menu = BehaviorFactory.delayed_callback(Callable(self,"close_menu"),2)
	callback_close_menu.globalList = 1
	add_child(callback_close_menu)

func close_menu():
	for node in get_tree().get_nodes_in_group("resume_button"):
			node.auto_press()
	var callback_play_card = BehaviorFactory.delayed_callback(Callable(self,"play_card"),2)
	callback_play_card.globalList = 1
	add_child(callback_play_card)
	
