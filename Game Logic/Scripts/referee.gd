class_name referee extends Node

@export var players : Array[CardPlayer]
@export var deck : Deck
@export var hand_size : int = 1

var trick : Array[Card]

func _ready():
	deck.spawn_cards()
func _on_button_pressed() -> void:
	deck.send_card(deck.random_card(),players[1].hand)
