class_name MenuFunctions extends Control

var level_loader : LevelLoader
var initial_play_speed_index : int
var initial_player_number_index : int
var new_player_number_index: int

var reload_level: bool = false


func _ready():
	level_loader = get_node("/root/Root/LevelLoader")
	initial_play_speed_index = InputProcessor.current_time_scale_index
	initial_player_number_index = level_loader.current_level_index




func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_resume_self_pressed() -> void:
	if level_loader.menu_done_moving:
		if reload_level:
			level_loader.load_scene_at_index(new_player_number_index)
		level_loader.dispose_main_menu()
	


func _on_player_number_self_pressed() -> void:
	pass # Replace with function body.


func _on_player_number_self_selected_item(index: int) -> void:
	new_player_number_index = index
	if index != initial_player_number_index:
		reload_level = true
	else:
		reload_level = false


func _on_play_speed_self_pressed() -> void:
	pass # Replace with function body.


func _on_play_speed_self_selected_item(index: int) -> void:
	InputProcessor.current_time_scale_index = index
