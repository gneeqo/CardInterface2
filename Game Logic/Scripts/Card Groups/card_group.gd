class_name CardGroup extends Node2D

@export var face_up : bool = false

var cards_in_group : Array[Card]

##includes cards which are being sent
var num_cards : int = 0

func _add_card(payload:Card):
	cards_in_group.push_back(payload)
	payload.owning_group = self
	
	if !payload.get_parent():
		add_child(payload)
	else:
		reparent(payload)
		
		
func receive_card(payload:Card):
	num_cards +=1
	_add_card(payload)
	
	
func send_card(payload:Card,target:CardGroup):
	num_cards -=1
	cards_in_group.erase(payload)
	_update_card_positions()
	payload.send_to(target)

func _update_card_positions():
	pass

func _new_card_offset()->Vector2:
	return global_position

func _new_card_rotation()->float:
	return global_rotation
	
func random_card()->Card:
	var rng = RandomNumberGenerator.new()
	return cards_in_group[rng.randi_range(0,cards_in_group.size()-1)]
	
