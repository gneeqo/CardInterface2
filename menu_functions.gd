class_name MenuFunctions extends Control

var level_loader : LevelLoader

func _ready():
	level_loader = get_node("/root/Root/LevelLoader")


func _on_level_0_pressed() -> void:
	level_loader.load_scene_at_index(0)


func _on_level_2_pressed() -> void:
	level_loader.load_scene_at_index(1)
