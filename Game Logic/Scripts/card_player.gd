class_name CardPlayer extends Node2D

@export var is_human : bool = false

var winnings_pile : Pile
var hand : Hand

var referee : Referee

func _ready():
	referee = get_node_or_null("../referee")
	if referee == null:
		print("Game cannot start without referee!")
	for child in get_children():
		if child is Pile:
			winnings_pile = child
		if child is Hand:
			hand = child


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
