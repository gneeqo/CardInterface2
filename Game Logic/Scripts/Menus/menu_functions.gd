class_name MenuFunctions extends Control
#manages the buttons on the menu
#sets data in other files based on menu buttons


var level_loader : LevelLoader
var initial_play_speed_index : int
var initial_player_number_index : int
var new_player_number_index: int
var initial_hand_size_index:int


var reload_due_to_player_num = false
var reload_due_to_hand_size = false


func _ready():
	level_loader = get_node("/root/Root/LevelLoader")
	
	#"initial"  refers to when the menu was spawned.
	#each time the menu is pulled up it is a new scene which is instantiated
	initial_play_speed_index = InputProcessor.current_time_scale_index
	initial_player_number_index = level_loader.current_level_index

	
	if Referee.hand_size == 13:
		initial_hand_size_index = 0
	else:
		initial_hand_size_index = 1
	
	$VBoxContainer/PlayerNumber.selected = initial_player_number_index
	$VBoxContainer/CardNum.selected = initial_hand_size_index
	$VBoxContainer/PlaySpeed.selected = InputProcessor.current_time_scale_index
	$VBoxContainer/TransitionType.selected = level_loader.curr_transition



#quit the game
func _on_quit_pressed() -> void:
	get_tree().quit()

#unpause the game
func _on_resume_self_pressed() -> void:
	if level_loader.menu_done_moving:
		if reload_due_to_hand_size or reload_due_to_player_num or InputProcessor.requrire_level_reload:
			level_loader.load_scene_at_index(new_player_number_index)
			InputProcessor.requrire_level_reload = false
		
		level_loader.dispose_main_menu()

#change the player number
func _on_player_number_self_selected_item(index: int) -> void:
	new_player_number_index = index
	if index != initial_player_number_index:
		#changing player number in the middle of a game will mess things up
		#so reload the level and warn the player of this
		reload_due_to_player_num = true
		var fade_in = BehaviorFactory.fade(1,0.2)
		fade_in.globalList = 1
		$ReloadWarning.add_child(fade_in,true)
	else:
		reload_due_to_player_num = false
		if not reload_due_to_hand_size:
			#changed back to initial value, so reload not necessary
			var fade_out = BehaviorFactory.fade(0,0.2)
			fade_out.globalList = 1
			$ReloadWarning.add_child(fade_out,true)


func _on_play_speed_self_selected_item(index: int) -> void:
	InputProcessor.current_time_scale_index = index


func _on_card_num_self_selected_item(index: int) -> void:
	match index:
		0:
			Referee.hand_size = 13
		1:
			Referee.hand_size = 6
	if index != initial_hand_size_index:
		#changing player number in the middle of a game will mess things up
		#so reload the level and warn the player of this
		reload_due_to_hand_size = true
		var fade_in = BehaviorFactory.fade(1,0.2)
		fade_in.globalList = 1
		$ReloadWarning.add_child(fade_in,true)
	else:
		reload_due_to_hand_size = false
		if not reload_due_to_player_num:
			#changed back to initial value, so reload not necessary
			var fade_out = BehaviorFactory.fade(0,0.2)
			fade_out.globalList = 1
			$ReloadWarning.add_child(fade_out,true)


func _on_transition_type_self_selected_item(index: int) -> void:
	level_loader.curr_transition = index as LevelLoader.TransitionType


func _on_transition_type_self_pressed() -> void:
	pass # Replace with function body.
