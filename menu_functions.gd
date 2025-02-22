class_name MenuFunctions extends Control

var level_loader : LevelLoader

func _ready():
	level_loader = get_node("/root/Root/LevelLoader")





func _on_level_0_self_activated() -> void:
	if level_loader.menu_done_moving:
		level_loader.load_scene_at_index(0)
		level_loader.dispose_main_menu()




func _on_level_1_self_activated() -> void:
	if level_loader.menu_done_moving:
		level_loader.load_scene_at_index(1)
		level_loader.dispose_main_menu()
