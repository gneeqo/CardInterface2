class_name CardPlayer extends Node2D
##basically a container for a card and a pile

@export var is_human : bool = false

var winnings_pile : Pile
var hand : Hand

var nametag : RichTextLabel

var referee : Referee

func _ready():
	referee = get_node_or_null("../referee")
	if referee == null:
		print("Game cannot start without referee!")
	#players should have one Pile child and one Hand child
	for child in get_children():
		if child is Pile:
			winnings_pile = child
		if child is Hand:
			hand = child
		if child is RichTextLabel:
			nametag = child


func take_turn():
	if hand.cards_in_group.size() ==0:
		print("no cards in hand.")
		return
		
	nametag.add_child(BehaviorFactory.fade(1,0.2))
	if is_human:
		
		add_child(BehaviorFactory.delayed_callback(Callable(self,"take_turn_human"),1))
	else:
		add_child(BehaviorFactory.delayed_callback(Callable(self,"take_turn_AI"),1))

#humans take their turn by clicking on cards
func take_turn_human():
	if InputProcessor.automating:
		take_turn_automated()

#let the automation play a card
func take_turn_automated():
	InputProcessor.playing_allowed = true
	

#this is where enemy AI would go.
func take_turn_AI():
	referee.attempt_play(hand.random_card(),self)
