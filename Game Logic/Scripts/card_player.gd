class_name CardPlayer extends Node2D

@export var is_human : bool = false

@export var winnings_pile : Pile
@export var hand : Hand

var referee : Referee

func _ready():
	referee = get_node_or_null("../referee")
	if referee == null:
		print("Game cannot start without referee!")


func take_turn():
	if is_human:
		take_turn_human()
	else:
		take_turn_AI()

#humans take their turn by clicking on cards
func take_turn_human():
	pass
	
#this is where enemy AI would go.
func take_turn_AI():
	referee.attempt_play(hand.random_card(),self)
