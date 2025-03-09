class_name Card extends Node2D
##game pieces

var isClickable:bool = false
var moused_over: bool = false

enum Suits {spades, clubs, hearts, diamonds}

#update the image when you set the suit
var suit:Suits:
	set(newSuit):
		suit = newSuit
		update_image()

#update the image when you set the v alue
var value:int:
	set(newValue):
		value = newValue
		update_image()
		

#static so they only load once
static var spade_tex:Array[Texture2D]
static var clubs_tex:Array[Texture2D]
static var hearts_tex:Array[Texture2D]
static var diamonds_tex:Array[Texture2D]

#array holding the arrays
static var textures:Array[Array]

var owning_group : CardGroup
var owning_player : CardPlayer

#unused, but I thought it might be helpful
var in_transit : bool = false

#how fast they move
var travel_duration : float = 1.0

#if the scale is negative, it's face down.
var face_up : bool :
	get:
		if (scale.x <0 ||scale.y < 0):
			return false
		return true

#constructor
static func create(new_value:int,new_suit:Suits) ->Card:
	var this_script : PackedScene = load("res://Game Logic/Scenes/card.tscn")
	var new_card:Card = this_script.instantiate()
	new_card.suit = new_suit
	new_card.value = new_value
	#start face down
	new_card.scale = Vector2(-1,1)
	
	return new_card
	
func _ready():
	#auto clickable so automation can play it
	add_to_group("auto_clickable",true)
	
func send_to(target:CardGroup):
	target.prep_for_card()
	var receiving_function = Callable(target,"receive_card").bind(self)
	
	
	#translate to new location, then call receiving function on card group
	#slight drift
	add_child(BehaviorFactory.translate_then_callback(receiving_function,target._new_card_offset(),travel_duration,1.5),true)
	#rotate to new rotation along the way
	#very slight drift
	add_child(BehaviorFactory.rotate(target._new_card_rotation(),travel_duration),true)
	
	#change z index halfway through the journey
	#it should be equal to the order in which it was added to the group
	var set_z = func(index):
		set_z_index(index)
	var midway_function = set_z.bind(target.num_cards)
	add_child(BehaviorFactory.delayed_callback(midway_function, travel_duration / 2),true)
	
	
	#match facing of the destination group
	if face_up and not target.face_up:
		add_child(BehaviorFactory.scale(Vector2(-1,1),travel_duration),true)
	elif not face_up and target.face_up:
		add_child(BehaviorFactory.scale(Vector2(1,1),travel_duration),true)
	
	#not using this for anything right now
	#may need eventually
	in_transit = true
	
	#stop the hover animation from triggering
	#reset to normal scale
	if isClickable:
		_on_area_2d_mouse_exited()
		isClickable = false
	





func _init():
	textures.push_back(spade_tex)
	textures.push_back(clubs_tex)
	textures.push_back(hearts_tex)
	textures.push_back(diamonds_tex)
	#load the textures
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



func _process(_delta: float) -> void:
	#change sprite visibility based on facing
	if(face_up):
		$BackSprite.visible = false
		$FrontSprite.visible = true
	else:
		$BackSprite.visible = true
		$FrontSprite.visible = false
	#if clicked while moused over, attempt to play it
	#unless automating
	if moused_over:
		if(InputProcessor.mouse_just_pressed and not InputProcessor.automating):
			on_pressed()



func change_FrontSprite(newTex:Texture2D):
	$FrontSprite.texture = newTex

func update_image():
	change_FrontSprite(textures[suit][value])


func _on_area_2d_mouse_entered() -> void:
	#isClickable is set if it's the player's cards
	if isClickable:
		#slightly increase in scale
		add_child(BehaviorFactory.scale(Vector2(1.2,1.2),0.2),true)
		moused_over = true


func _on_area_2d_mouse_exited() -> void:
	#isClickable is set if it's the player's cards
	if isClickable:
		#reset scale
		add_child(BehaviorFactory.scale(Vector2(1,1),0.3),true)
		moused_over = false

#automation hookup
func auto_press()->bool:
	if isClickable:
		on_pressed()
		return true
	return false

func on_pressed() -> void:
	
	#try to play the card
	var referee = get_tree().get_nodes_in_group("referee")
	if referee.size() >1:
		print("multiple referees.  Selecting card during scene switch?")
	elif referee.size() == 1:
		referee[0].attempt_play(self,referee[0].players[0])
