class_name MenuFunctions extends Control

var level_loader : LevelLoader

func _ready():
	level_loader = get_node("/root/Root/LevelLoader")




func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_resume_self_pressed() -> void:
	if level_loader.menu_done_moving:
		level_loader.dispose_main_menu()


func _on_player_number_self_pressed() -> void:
	pass # Replace with function body.


func _on_player_number_self_selected_item(index: int) -> void:
	pass # Replace with function body.


func _on_play_speed_self_pressed() -> void:
	pass # Replace with function body.


func _on_play_speed_self_selected_item(index: int) -> void:
	pass # Replace with function body.
