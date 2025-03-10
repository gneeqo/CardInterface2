class_name InputProcessor extends Node
##input middleman to do automation

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

static var debug_menu_open:bool = false

#manage time scales here, so automation can override
static var time_scale : float :
	get:
		if automating:
			return 5
		return time_scales[current_time_scale_index]


func _process(_dt:float):
	
	if(Input.is_action_just_pressed("Automate")):
		#automating and menu automating were originally different
		#I worry that removing menu_automating will break something else
		automating = !automating
		menu_automating = automating
		#commented out for submission build
		#if(automating):
			#TelemetryCollector.start_collecting()
		#else:
			#TelemetryCollector.finish_collecting()
		
	if(Input.is_action_just_pressed("toggle_debug")):
		debug_menu_open = !debug_menu_open
		if debug_menu_open:
			TelemetryCollector.add_event("InputProcessor","Opened","DebugMenu")
		else:
			TelemetryCollector.add_event("InputProcessor","Closed","DebugMenu")
	
	if automating:
		#don't do any normal input
		mouse_just_pressed = false
		mouse_down = false
		mouse_pos = Vector2(0,0)
		escape_just_pressed = false
		
		# play cards or use menu via automation
		if(playing_allowed):
			play_card()
			playing_allowed = false
		if(menuing_allowed):
			take_turn()
		
	else:
		
		#regular input
		mouse_just_pressed =  Input.is_action_just_pressed("mouse_click")
		mouse_down = Input.is_action_pressed("mouse_click")
		mouse_pos = get_viewport().get_mouse_position()
		
		escape_just_pressed = Input.is_action_just_pressed("escape")
		
	


func play_card():
	var rng = RandomNumberGenerator.new()
	var card_played:bool = false
	var times_looped = 0
	
	while not card_played:
		#find the things automation is allowed to click
		var auto_clickable = get_tree().get_nodes_in_group("auto_clickable")
		if(auto_clickable.size() ==0):
			break
			#not allowed to click anything
		for node in auto_clickable:
				if(rng.randf_range(0,10) >5):
					if(node.auto_press()):
						card_played = true
						#we successfully clicked something
						var event_message:String
						if node is Card:
							var card = node as Card
							event_message = str(card.value) + " of " + Card.Suits.keys()[card.suit]
						else:
							event_message = "something other than a card"
						
						TelemetryCollector.add_event("InputProcessor","Clicked",event_message)
						
						break
					else:
						#we tried to click something, but it didn't work.
						#don't want to get stuck here.
						times_looped +=1
						if times_looped > 100:
							menuing_allowed = true
							requrire_level_reload = true
							print("automation got stuck trying to play a card.")
							return

func take_turn():
	menuing_allowed = false
	#open the menu and select something.
	open_menu()
	var use_menu = BehaviorFactory.delayed_callback(Callable(self,"select_menu_option"),2)
	#make sure this action is marked as UI space
	use_menu.globalList = 1
	add_child(use_menu,true)
	
func open_menu():
	escape_just_pressed = true
	TelemetryCollector.add_event("InputProcessor","Opened","Menu")

func select_menu_option():
	var rng = RandomNumberGenerator.new()
	var option_selected = false
	var times_looped = 0
	while not option_selected:
		#find the things we are allowed to select
		var auto_selectable =  get_tree().get_nodes_in_group("auto_selectable")
		if(auto_selectable.size() == 0):
			break
			#not allowed to select anything
		for node in auto_selectable:
				if(rng.randf_range(0,10) >5):
					var option_to_select:int = rng.randi_range(0,node.item_count-1)
					node.auto_select(option_to_select)
					option_selected = true
					#we selected something
					var event_message:String
					if node is AutomatedOptionButton:
						var option = node as AutomatedOptionButton
						event_message = option.get_item_text(option_to_select)
						
						
					else:
						event_message = "unselectable item (somehow)"
					
					TelemetryCollector.add_event("InputProcessor","Selected",event_message)
					
					
					
					break
		times_looped +=1
		if times_looped > 100:
			#wasn't able to select something after 100 tries (wasn't due to randomness).
			menuing_allowed = true
			requrire_level_reload = true
			print("automation got stuck trying to select a menu item.")
			return
	#close the menu after 4 seconds
	var callback_close_menu = BehaviorFactory.delayed_callback(Callable(self,"close_menu"),4)
	#make sure this is marked as UI space
	callback_close_menu.globalList = 1
	add_child(callback_close_menu,true)

func close_menu():
	#press resume
	for node in get_tree().get_nodes_in_group("resume_button"):
			node.auto_press()
	#play a card in 4 seconds
	var callback_play_card = BehaviorFactory.delayed_callback(Callable(self,"play_card"),4)
	#make sure this is marked as UI space
	callback_play_card.globalList = 1
	TelemetryCollector.add_event("InputProcessor","Closed","Menu")
	
