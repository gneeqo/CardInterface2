class_name LevelLoader extends Node

@export var level_scenes : Array[PackedScene]
@export var main_menu : PackedScene


var prev_level_root : Node
var active_level_root : Node
var menu_node : Node
var menu_done_moving:bool = true
var menu_active : bool = false
var level_done_loading : bool = true

var current_level_index : int = 0


func _ready():
	var start_level = level_scenes[0].instantiate()
	get_tree().root.add_child.call_deferred(start_level)
	active_level_root = start_level
	
func _process(_dt:float)->void:
	if InputProcessor.escape_just_pressed:
		if menu_done_moving and not menu_active and level_done_loading:
			load_main_menu()
		elif menu_done_moving and menu_active and not InputProcessor.automating:
			dispose_main_menu()
	

func load_scene_at_index(index:int):
	if level_done_loading and menu_done_moving:
		prev_level_root = active_level_root
		active_level_root = level_scenes[index].instantiate()
		get_tree().root.add_child(active_level_root)
		
		level_done_loading = false
		
		current_level_index = index
		
		intro_scene(active_level_root)
		dispose_scene(prev_level_root)

func set_menu_done_moving():
	menu_done_moving = true
	
func set_menu_done_moving_and_unpause():
	menu_done_moving = true
	GlobalExecutorList.unpause_world_executors()

func set_level_done_loading():
	level_done_loading = true


func load_main_menu():
	var behavior = load("res://Behaviors/translate_in_UI.tscn").instantiate()
	
	behavior.provide_callback(Callable(self,"set_menu_done_moving"))
	
	
	menu_node = main_menu.instantiate()
	get_tree().root.add_child(menu_node)

	menu_node.position = Vector2(2000,100)
	menu_node.add_child(behavior)
	menu_active = true
	menu_done_moving = false
	
	GlobalExecutorList.pause_world_executors()

func dispose_main_menu():
	var behavior = load("res://Behaviors/translate_out_UI.tscn").instantiate()
	behavior.provide_callback(Callable(self,"set_menu_done_moving_and_unpause"))
	menu_active = false
	menu_done_moving = false
	menu_node.add_child(behavior)



func intro_scene(scene:Node2D):
	var behavior = load("res://Behaviors/translate_in_UI.tscn").instantiate()
	behavior.provide_callback(Callable(self,"set_level_done_loading"))
	
	scene.position = Vector2(2000,100)
	scene.add_child(behavior)

func dispose_scene(scene:Node2D):
	var behavior = load("res://Behaviors/translate_out_UI.tscn").instantiate()
	scene.add_child(behavior)
