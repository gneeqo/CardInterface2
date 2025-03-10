class_name Referee extends Node
##manages the game logic


@export var players : Array[CardPlayer]
@export var deck : Deck

static var hand_size:int = 13


@export var deal_delay : float = 0.3
@export var trick : Trick

@export var deck_anchor : Node2D

@export var trick_win_text : RichTextLabel
@export var game_win_text : RichTextLabel

var starting_player_index = 0

var turn_index : int = -1

var tricks_taken : int = 0

var auto_start = true

#take turns based on turn_index-
var active_player:CardPlayer:
	get:
		return players[(starting_player_index + turn_index) % (players.size())]


func _ready():
	add_to_group("referee",true)
	deck.spawn_cards()

#debug button (removed)
func _on_button_pressed() -> void:
	deal_hand_to_players()
	var delay_time = deal_delay*players.size()*hand_size +  deal_delay*hand_size
	add_child(BehaviorFactory.delayed_callback(Callable(self,"start_play"),delay_time),true)

#if auto_start is set from outside, begin the game
func _process(_dt:float)->void:
	if auto_start:
		var loader : LevelLoader = get_node("/root/Root/LevelLoader")
		if loader.level_done_loading:
			#don't start before level is done moving onscreen
			shuffle_animation()
			
			add_child(BehaviorFactory.delayed_callback(Callable(self,"deal_hand_to_players"),3),true)
			auto_start = false

func shuffle_animation():
	var distance = 250
	var rng = RandomNumberGenerator.new()
	for card in deck.cards_in_group:
		var original_pos = card.global_position
		var original_rot = card.global_rotation
		var shuffle_pos = card.global_position + Vector2(rng.randf_range(-distance,distance),rng.randf_range(-distance,distance))
		var shuffle_rot = card.global_rotation + rng.randf_range(-1,1)
		
		var shuffle_in_out = BehaviorFactory.rotate(shuffle_rot,1,0.1)
		
		var translate_out = ActionFactory.translate_to(shuffle_pos,1,true,Action.EaseType.easeInOutSine,1,true)
		var translate_in = ActionFactory.translate_to(original_pos,1)
		var rotate_in = ActionFactory.rotate_to(original_rot,1)
		
		BehaviorFactory.add_action_to_behavior(translate_out,shuffle_in_out)
		BehaviorFactory.add_action_to_behavior(translate_in,shuffle_in_out)
		BehaviorFactory.add_action_to_behavior(rotate_in,shuffle_in_out)

		card.add_child(shuffle_in_out)
		
		

func restart_trick(winning_card:Card):
	TelemetryCollector.add_event("Referee","Called",get_stack()[0]["function"])
	print("restart_trick")
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
	TelemetryCollector.add_event("Referee","Called",get_stack()[0]["function"])
	print("evaluate_trick")
	#don't trigger this again until reconnected
	for connection:Dictionary in receiving_signal.get_connections():
		if connection["callable"].get_method() == "evaluate_trick":
			connection["signal"].disconnect(connection["callable"])
	
	#find winning card
	var total_value = 0
	var winning_card:Card = trick.cards_in_group.front()
	for card in trick.cards_in_group:
		total_value += card.value
		if card.value > winning_card.value:
			winning_card = card
	
	#highlight winning card
	#scale up (blocking)
	var highlight = BehaviorFactory.scale(Vector2(1.5,1.5),0.2,0,true)
	#scale down (blocking)
	BehaviorFactory.add_action_to_behavior \
	(ActionFactory.scale_to(Vector2(1,1),0.2,true,Action.EaseType.easeInOutSine,0,true),highlight)
	
	#show how many points were won
	trick_win_text.text = winning_card.owning_player.name + " wins\n"+ str(total_value)+" points"
	
	var original_text_pos = trick_win_text.global_position
	
	#translate up for 1 second
	var popup = BehaviorFactory.translate(original_text_pos + Vector2(0,-30),1)
	
	#fade in for 1/2 second, blocking
	BehaviorFactory.add_action_to_behavior(ActionFactory.fade(\
	1,0.5,true,Action.EaseType.easeInOutSine,true),popup)
	
	#fade out for 1/2 second, blocking
	BehaviorFactory.add_action_to_behavior(ActionFactory.fade(\
	0,0.5,true,Action.EaseType.easeInOutSine,true),popup)
	
	#move back to original position
	BehaviorFactory.add_action_to_behavior(ActionFactory.translate_to(\
	original_text_pos,1,true,Action.EaseType.easeInOutSine,true),popup)
	
	#add this behavior to the trick win text
	trick_win_text.add_child(popup)
	
	#then restart trick
	var restart = Callable(self,"restart_trick").bind(winning_card)
	
	#restart trick after scale up and down
	BehaviorFactory.add_callback_to_behavior(restart,highlight)
	
	#make sure card knows to do all that
	winning_card.add_child(highlight,true)
	TelemetryCollector.add_event(winning_card.owning_player.name,"Won","Trick # " + str(tricks_taken))

func attempt_play(card:Card, player:CardPlayer)->void:
	print("attempt_play")
	if turn_index == -1:
		print("playing not allowed right now.")
		TelemetryCollector.add_event("player " +str(players.find(player))\
		,"Played","When not allowed")
		return
	#if the player is allowed to play, send their card to the trick
	if player == active_player: 
		player.hand.send_card(card,trick)
		TelemetryCollector.add_event("player " +str(players.find(player))\
		, " played " , str(card.value) + " of " + Card.Suits.keys()[card.suit])
		
		turn_index +=1
		player.nametag.add_child(BehaviorFactory.fade(0,0.2))
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
	print("next_trick")
	#don't trigger this again until reconnected
	for connection:Dictionary in receiving_signal.get_connections():
		if connection["callable"].get_method() == "next_trick":
			connection["signal"].disconnect(connection["callable"])
	
	turn_index = 0
	starting_player_index = (starting_player_index+1)%(players.size())
	
	if active_player.hand.cards_in_group.size() ==0:
		breakpoint
	
	
	active_player.take_turn()
	
	TelemetryCollector.add_event("Referee","Called",get_stack()[0]["function"])
	

func advance_trick(receiving_signal:Signal):
	print("advance_trick")
	#don't trigger this again until reconnected
	for connection:Dictionary in receiving_signal.get_connections():
		if connection["callable"].get_method() == "advance_trick":
			connection["signal"].disconnect(connection["callable"])
	if turn_index != -1:
		active_player.take_turn()
	TelemetryCollector.add_event("Referee","Called",get_stack()[0]["function"])
	
func end_round(receiving_signal:Signal):
	print("end_round")
	#don't trigger this again until reconnected
	for connection:Dictionary in receiving_signal.get_connections():
		if connection["callable"].get_method() == "end_round":
			connection["signal"].disconnect(connection["callable"])
	
	TelemetryCollector.add_event("Referee","Called",get_stack()[0]["function"])
	
	if(deck.cards_in_group.size()< hand_size*players.size()):
		end_game()
		return
	else:
		if InputProcessor.automating:
			InputProcessor.menuing_allowed = true
		deal_hand_to_players()
	
	
		
func end_game():
	print("end_game")
	
	TelemetryCollector.add_event("Referee","Called",get_stack()[0]["function"])
	
	#calculate winner
	var max_score = 0
	var winning_player = null
	for player in players:
		var curr_score = 0
		for card in player.winnings_pile.cards_in_group:
			curr_score += card.value
		if curr_score > max_score:
			max_score = curr_score
			winning_player = player
	
	#show how many points were won
	game_win_text.text = winning_player.name + " wins the game!\n"+ str(max_score)+" points"
	
	#translate up for 1 second
	var popup = BehaviorFactory.translate(game_win_text.global_position + Vector2(0,-30),1)
	
	#fade in for 1/2 second, blocking
	BehaviorFactory.add_action_to_behavior(ActionFactory.fade(\
	1,0.5,true,Action.EaseType.easeInOutSine,true),popup)
	
	
	
	#send winner to telemetry
	if winning_player != null:
		TelemetryCollector.add_event(\
		winning_player.name,"Won","Game (" + str(max_score) + "Points)")
	
	#get ready to restart
	add_child(BehaviorFactory.delayed_callback(Callable(self,"restart_game"),2))
	
	

func restart_game():
	if InputProcessor.automating:
		InputProcessor.menuing_allowed = true
		InputProcessor.requrire_level_reload = true
	else:
		#pull up end screen
		var level_loader : LevelLoader = get_node("/root/Root/LevelLoader")
		level_loader.load_game_over()

func move_deck():
	deck.add_child(BehaviorFactory.translate_then_callback(Callable(self,"start_play"),deck_anchor.global_position,1))

func deal_hand_to_players():
	TelemetryCollector.add_event("Referee","Called",get_stack()[0]["function"])
	if(deck.cards_in_group.size()< hand_size*players.size()):
		end_game()
		return
	else:
		var delay_time = deal_delay*players.size()*hand_size + deal_delay*hand_size
		add_child(BehaviorFactory.delayed_callback(Callable(self,"move_deck"),delay_time),true)
	

	#do this once for each hand size
	for index in hand_size:
		var function = Callable(self,"deal_one_to_players")
		#delay * index = delay longer for which card in the hand are we on
		#delay * index * player num = delay longer for how many players
		#so that the cards are dealt sequentially
		add_child(BehaviorFactory.delayed_callback(function,0.01 + (deal_delay*index*players.size())),true)

func deal_one_to_players():
	#deal one card to each player
	for index in players.size():
		var function = Callable(self,"deal_one_card").bind(players[index])
		#delay*index = each player gets their cards in order
		add_child(BehaviorFactory.delayed_callback(function,0.01 + (deal_delay*index)),true)

func deal_one_card(player:CardPlayer):
	if deck.cards_in_group.size() > 0:
		deck.send_card(deck.top_card(),player.hand)
	else:
		print("not enough cards in the deck!")
		end_game()


func start_play() -> void:
	print("start_play")
	TelemetryCollector.add_event("Referee","Called",get_stack()[0]["function"])
	turn_index = 0
	active_player.take_turn()
