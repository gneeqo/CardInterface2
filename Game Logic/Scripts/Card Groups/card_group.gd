class_name CardGroup extends Node2D

@export var face_up : bool = false

var cards_in_group : Array[Card]

##includes cards which are being sent
var num_cards : int = 0

func _add_card(target:Card):
	cards_in_group.push_back(target)

func receive_card(target:Card):
	num_cards +=1
	
func send_card(target:Card):
	num_cards -=1
	_update_card_positions()

func _update_card_positions():
	pass

func _new_card_offset()->Vector2:
	return position

func _new_card_rotation()->float:
	return 0
