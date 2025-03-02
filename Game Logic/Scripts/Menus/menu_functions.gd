class_name MenuFunctions extends Control

var level_loader : LevelLoader
var initial_play_speed_index : int
var initial_player_number_index : int
var new_player_number_index: int
var initial_hand_size_index:int

var reload_level: bool = false

var reload_due_to_player_num = false
var reload_due_to_hand_size = false


func _ready():
	level_loader = get_node("/root/Root/LevelLoader")
	initial_play_speed_index = InputProcessor.current_time_scale_index
	initial_player_number_index = level_loader.current_level_index
	




func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_resume_self_pressed() -> void:
	if level_loader.menu_done_moving:
		if reload_due_to_hand_size or reload_due_to_player_num:
			level_loader.load_scene_at_index(new_player_number_index)
		level_loader.dispose_main_menu()
	


func _on_player_number_self_pressed() -> void:
	pass # Replace with function body.


func _on_player_number_self_selected_item(index: int) -> void:
	new_player_number_index = index
	if index != initial_player_number_index:
		reload_due_to_player_num = true
		var fade_in = BehaviorFactory.fade(1,0.2)
		fade_in.globalList = 1
		$ReloadWarning.add_child(fade_in)
	else:
		reload_due_to_player_num = false
		if not reload_due_to_hand_size:
			var fade_out = BehaviorFactory.fade(0,0.2)
			fade_out.globalList = 1
			$ReloadWarning.add_child(fade_out)


func _on_play_speed_self_pressed() -> void:
	pass # Replace with function body.


func _on_play_speed_self_selected_item(index: int) -> void:
	InputProcessor.current_time_scale_index = index


func _on_card_num_self_selected_item(index: int) -> void:
	match index:
		0:
			Referee.hand_size = 13
		1:
			Referee.hand_size = 6
	if index != initial_player_number_index:
		reload_due_to_hand_size = true
		var fade_in = BehaviorFactory.fade(1,0.2)
		fade_in.globalList = 1
		$ReloadWarning.add_child(fade_in)
	else:
		reload_due_to_hand_size = false
		if not reload_due_to_player_num:
			var fade_out = BehaviorFactory.fade(0,0.2)
			fade_out.globalList = 1
			$ReloadWarning.add_child(fade_out)
