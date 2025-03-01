class_name Card extends Node2D


var isClickable:bool = false
var moused_over: bool = false

enum Suits {spades, clubs, hearts, diamonds}


var suit:Suits:
	set(newSuit):
		suit = newSuit
		update_image()
		
var value:int:
	set(newValue):
		value = newValue
		update_image()
		

static var spade_tex:Array[Texture2D]
static var clubs_tex:Array[Texture2D]
static var hearts_tex:Array[Texture2D]
static var diamonds_tex:Array[Texture2D]

static var textures:Array[Array]

var owning_group : CardGroup
var owning_player : CardPlayer

var in_transit : bool = false
var travel_duration : float = 1.0

var face_up : bool :
	get:
		if (scale.x <0 ||scale.y < 0):
			return false
		return true


static func create(new_value:int,new_suit:Suits) ->Card:
	var this_script : PackedScene = load("res://Game Logic/Scenes/card.tscn")
	var new_card:Card = this_script.instantiate()
	new_card.suit = new_suit
	new_card.value = new_value
	new_card.scale = Vector2(-1,1)
	
	return new_card
	
func _ready():
	add_to_group("auto_clickable",true)
	
func send_to(target:CardGroup):
	target.prep_for_card()
	var receiving_function = Callable(target,"receive_card").bind(self)
	
	
	#translate to new location, then call receiving function on card group
	#slight drift
	add_child(BehaviorFactory.translate_then_callback(receiving_function,target._new_card_offset(),travel_duration,1.5))
	#rotate to new rotation along the way
	#very slight drift
	add_child(BehaviorFactory.rotate(target._new_card_rotation(),travel_duration))
	
	#change z index halfway through the journey
	#it should be equal to the order in which it was added to the group
	var set_z = func(index):
		set_z_index(index)
	var midway_function = set_z.bind(target.num_cards)
	add_child(BehaviorFactory.delayed_callback(midway_function, travel_duration / 2))
	
	if face_up and not target.face_up:
		add_child(BehaviorFactory.scale(Vector2(-1,1),travel_duration))
	elif not face_up and target.face_up:
		add_child(BehaviorFactory.scale(Vector2(1,1),travel_duration))
	
	#not using this for anything right now
	#may need eventually
	in_transit = true
	
	#stop the hover animation from triggering
	#reset to normal scale
	if isClickable:
		_on_area_2d_mouse_exited()
		isClickable = false
	



# Called when the node enters the scene tree for the first time.
func _init():
	textures.push_back(spade_tex)
	textures.push_back(clubs_tex)
	textures.push_back(hearts_tex)
	textures.push_back(diamonds_tex)
	
	for i in range(0,4):
		for j in range(1,14):
			match i:
				0:
					textures[i].push_back(load("res://Assets/Sprites/Spades "+str(j)+".png"))
				1:
					textures[i].push_back(load("res://Assets/Sprites/Clubs "+str(j)+".png"))
				2:
					textures[i].push_back(load("res://Assets/Sprites/Hearts "+str(j)+".png"))
				3:
					textures[i].push_back(load("res://Assets/Sprites/Diamonds "+str(j)+".png"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if(face_up):
		$BackSprite.visible = false
		$FrontSprite.visible = true
	else:
		$BackSprite.visible = true
		$FrontSprite.visible = false
		
	if moused_over:
		if(InputProcessor.mouse_just_pressed and not InputProcessor.automating):
			on_pressed()



func change_FrontSprite(newTex:Texture2D):
	$FrontSprite.texture = newTex

func update_image():
	change_FrontSprite(textures[suit][value])


func _on_area_2d_mouse_entered() -> void:
	if isClickable:
		add_child(BehaviorFactory.scale(Vector2(1.2,1.2),0.2))
		moused_over = true


func _on_area_2d_mouse_exited() -> void:
	if isClickable:
		add_child(BehaviorFactory.scale(Vector2(1,1),0.3))
		moused_over = false


func auto_press():
	if isClickable:
		on_pressed()

func on_pressed() -> void:
	var referee = get_tree().get_nodes_in_group("referee")
	
	if referee.size() >1:
		print("multiple referees.  Selecting card during scene switch?")
	elif referee.size() == 1:
		referee[0].attempt_play(self,referee[0].players[0])
