class_name Referee extends Node

@export var players : Array[CardPlayer]
@export var deck : Deck
@export var hand_size : int = 1
@export var deal_delay : float = 0.3
@export var trick : Trick

var starting_player_index = 0

var turn_index : int = -1

var tricks_taken : int = 0

var active_player:CardPlayer:
	get:
		return players[(starting_player_index + turn_index) % (players.size())]


func _ready():
	add_to_group("referee",true)
	deck.spawn_cards()

func _on_button_pressed() -> void:
	deal_hand_to_players()
	var delay_time = deal_delay*players.size()*hand_size +  deal_delay*hand_size
	add_child(BehaviorFactory.delayed_callback(Callable(self,"start_play"),delay_time))


func _process(_dt:float)->void:
	pass
	#doing this in process so it will start when the final card arrives
	#if trick.cards_in_group.size() == players.size():
		#if turn_index == -1:
			#evaluate_trick()
		#else:
			#print("trick is full but the turn cycle isn't over!")
			#breakpoint




func restart_trick(winning_card:Card):
	var destination_group = winning_card.owning_player.winnings_pile
	#send winning cards to winner
	while(!trick.cards_in_group.is_empty()):
		trick.send_card(trick.cards_in_group.front(),destination_group)
	
	if tricks_taken < hand_size:
		#start playing the next trick
		destination_group.received_card.connect\
		(Callable(self,"next_trick").bind(destination_group.received_card))
	else:
		#reset
		tricks_taken = 0
		#deal another hand, or take score
		destination_group.received_card.connect\
		(Callable(self,"end_round").bind(destination_group.received_card))

func evaluate_trick(receiving_signal:Signal):
	#don't trigger this again until reconnected
	for connection:Dictionary in receiving_signal.get_connections():
		if connection["callable"].get_method() == "evaluate_trick":
			connection["signal"].disconnect(connection["callable"])
	
	#find winning card
	var winning_card:Card = trick.cards_in_group.front()
	for card in trick.cards_in_group:
		if card.value > winning_card.value:
			winning_card = card
	
	#highlight winning card
	#scale up (blocking)
	var highlight = BehaviorFactory.scale(Vector2(1.5,1.5),0.2,0,true)
	#scale down (blocking)
	BehaviorFactory.add_action_to_behavior \
	(ActionFactory.scale_to(Vector2(1,1),0.2,true,Action.EaseType.easeInOutSine,0,true),highlight)
	
	
	#then restart trick
	var restart = Callable(self,"restart_trick").bind(winning_card)
	
	#restart trick after scale up and down
	BehaviorFactory.add_callback_to_behavior(restart,highlight)
	
	#make sure card knows to do all that
	winning_card.add_child(highlight)
		

func attempt_play(card:Card, player:CardPlayer)->void:
	if turn_index == -1:
		print("playing not allowed right now.")
		return
	#if the player is allowed to play, send their card to the trick
	if player == active_player: 
		player.hand.send_card(card,trick)
		turn_index +=1
		
		if turn_index == players.size():
			#the trick is over.
			turn_index = -1
			tricks_taken += 1
			trick.received_card.connect\
			(Callable(self,"evaluate_trick").bind(trick.received_card))
		else:
			#continue the trick when the card arrives.
			trick.received_card.connect\
			(Callable(self,"advance_trick").bind(trick.received_card))
		
	else:
		print("it's not this player's turn.")
		
	
	
func next_trick(receiving_signal : Signal):
	#don't trigger this again until reconnected
	for connection:Dictionary in receiving_signal.get_connections():
		if connection["callable"].get_method() == "next_trick":
			connection["signal"].disconnect(connection["callable"])
	
	turn_index = 0
	starting_player_index = (starting_player_index+1)%(players.size())
	
	active_player.take_turn()
	

func advance_trick(receiving_signal:Signal):
	#don't trigger this again until reconnected
	for connection:Dictionary in receiving_signal.get_connections():
		if connection["callable"].get_method() == "advance_trick":
			connection["signal"].disconnect(connection["callable"])
	if turn_index != -1:
		active_player.take_turn()
	
func end_round(receiving_signal:Signal):
	#don't trigger this again until reconnected
	for connection:Dictionary in receiving_signal.get_connections():
		if connection["callable"].get_method() == "end_round":
			connection["signal"].disconnect(connection["callable"])
	if deck.cards_in_group.size() >0:
		deal_hand_to_players()
		var delay_time = deal_delay*players.size()*hand_size + deal_delay*hand_size
		add_child(BehaviorFactory.delayed_callback(Callable(self,"start_play"),delay_time))
	else:
		end_game()
		
func end_game():
	pass


func deal_hand_to_players():
	#do this once for each hand size
	for index in hand_size:
		var function = Callable(self,"deal_one_to_players")
		#delay * index = delay longer for which card in the hand are we on
		#delay * index * player num = delay longer for how many players
		#so that the cards are dealt sequentially
		add_child(BehaviorFactory.delayed_callback(function,0.01 + (deal_delay*index*players.size())))

func deal_one_to_players():
	#deal one card to each player
	for index in players.size():
		var function = Callable(self,"deal_one_card").bind(players[index])
		#delay*index = each player gets their cards in order
		add_child(BehaviorFactory.delayed_callback(function,0.01 + (deal_delay*index)))

func deal_one_card(player:CardPlayer):
	if deck.cards_in_group.size() > 0:
		deck.send_card(deck.top_card(),player.hand)
	else:
		print("not enough cards in the deck!")


func start_play() -> void:
	turn_index = 0
	active_player.take_turn()
