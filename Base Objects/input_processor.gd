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
static var menuing_allowed = false
static var requrire_level_reload = false

static var card_finished_playing_signal


static var time_scale : float :
	get:
		if automating:
			return 15
		return time_scales[current_time_scale_index]


func _process(_dt:float):
	
	if(Input.is_action_just_pressed("Automate")):
		automating = !automating
		menu_automating = automating
		
	if automating:
		mouse_just_pressed = false
		mouse_down = false
		mouse_pos = Vector2(0,0)
		escape_just_pressed = false
		
		if(playing_allowed):
			play_card()
			playing_allowed = false
		if(menuing_allowed):
			take_turn()
		
	else:
		time_scale = 1
		mouse_just_pressed =  Input.is_action_just_pressed("mouse_click")
		mouse_down = Input.is_action_pressed("mouse_click")
		mouse_pos = get_viewport().get_mouse_position()
		
		escape_just_pressed = Input.is_action_just_pressed("escape")
		
	


func play_card():
	var rng = RandomNumberGenerator.new()
	var card_played:bool = false
	var times_looped = 0
	
	while not card_played:
		var auto_clickable = get_tree().get_nodes_in_group("auto_clickable")
		if(auto_clickable.size() ==0):
			break
		for node in auto_clickable:
				if(rng.randf_range(0,10) >5):
					if(node.auto_press()):
						card_played = true
						break
					else:
						times_looped +=1
						if times_looped > 100:
							menuing_allowed = true
							requrire_level_reload = true
							print("automation got stuck trying to play a card.")
							return

func take_turn():
	menuing_allowed = false
	open_menu()
	var use_menu = BehaviorFactory.delayed_callback(Callable(self,"select_menu_option"),2)
	use_menu.globalList = 1
	add_child(use_menu)
	
func open_menu():
	escape_just_pressed = true

func select_menu_option():
	var rng = RandomNumberGenerator.new()
	var option_selected = false
	var times_looped = 0
	while not option_selected:
		var auto_selectable =  get_tree().get_nodes_in_group("auto_selectable")
		if(auto_selectable.size() == 0):
			break
		for node in auto_selectable:
				if(rng.randf_range(0,10) >5):
					node.auto_select(rng.randi_range(0,node.item_count-1))
					option_selected = true
					break
		times_looped +=1
		if times_looped > 100:
			menuing_allowed = true
			requrire_level_reload = true
			print("automation got stuck trying to select a menu item.")
			return
	var callback_close_menu = BehaviorFactory.delayed_callback(Callable(self,"close_menu"),4)
	callback_close_menu.globalList = 1
	add_child(callback_close_menu)

func close_menu():
	for node in get_tree().get_nodes_in_group("resume_button"):
			node.auto_press()
	var callback_play_card = BehaviorFactory.delayed_callback(Callable(self,"play_card"),4)
	callback_play_card.globalList = 1
	
