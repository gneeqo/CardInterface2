class_name referee extends Node

@export var players : Array[CardPlayer]
@export var deck : Deck
@export var hand_size : int = 1
@export var deal_delay : float = 0.3


var trick : Array[Card]

func _ready():
	deck.spawn_cards()
func _on_button_pressed() -> void:
	deal_hand_to_players()

func deal_hand_to_players():
	for index in hand_size:
		var function = Callable(self,"deal_one_to_players")
		add_child(BehaviorFactory.delayed_callback(function,0.01 + (deal_delay*index)))

func deal_one_to_players():
	for index in players.size():
		var function = Callable(self,"deal_one_card").bind(players[index])
		add_child(BehaviorFactory.delayed_callback(function,0.01 + (deal_delay*index)))

func deal_one_card(player:CardPlayer):
	deck.send_card(deck.top_card(),player.hand)
