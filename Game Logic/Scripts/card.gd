class_name Card extends Node2D


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
var in_transit : bool = false



static func create(new_value:int,new_suit:Suits) ->Card:
	var this_script : PackedScene = load("res://Game Logic/Scenes/card.tscn")
	var new_card:Card = this_script.instantiate()
	new_card.suit = new_suit
	new_card.value = new_value
	return new_card
	

func send_to(target:CardGroup):
	var receiving_function = Callable(target,"receive_card").bind(self)
	add_child(BehaviorFactory.translate_then_callback(receiving_function,target._new_card_offset(),1))
	in_transit = true



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
func _process(delta: float) -> void:
	var scale = transform.get_scale()
	if(scale.x <0 ||scale.y < 0):
		$BackSprite.visible = true
		$FrontSprite.visible = false
	else:
		$BackSprite.visible = false
		$FrontSprite.visible = true


func change_FrontSprite(newTex:Texture2D):
	$FrontSprite.texture = newTex

func update_image():
	change_FrontSprite(textures[suit][value])
