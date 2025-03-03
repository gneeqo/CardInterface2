class_name CardGroup extends Node2D
## places to send cards to

#should cards here be face up?
@export var face_up : bool = false

var cards_in_group : Array[Card]

signal received_card

##includes cards which are being sent
var num_cards : int = 0

func _add_card(payload:Card):
	cards_in_group.push_back(payload)
	payload.owning_group = self

	#adopt or reparent
	if !payload.get_parent():
		add_child(payload)
	else:
		payload.reparent(self)
		
#we have to do this so that new_card_offset is accurate
func prep_for_card():
	num_cards +=1

#tell whoever's listening that we got the card
#add it to the array
func receive_card(payload:Card):
	payload.in_transit = false
	_add_card(payload)
	received_card.emit()
	
#remove the card from our array, and have the card travel to another group
func send_card(payload:Card,target:CardGroup):
	num_cards -= 1
	cards_in_group.erase(payload)

	payload.send_to(target)
	
#mostly for Decks.  Make sure the cards are z-ordered from back to front
func update_z_order():
	for index in cards_in_group.size():
		cards_in_group[index].set_z_index(index)

#randomize the array and update z order
func shuffle():
	cards_in_group.shuffle()
	update_z_order()

#where should a new card moving to this group go?
func _new_card_offset()->Vector2:
	return global_position

#where should a new card moving to this group rotate to?
func _new_card_rotation()->float:
	return global_rotation
	
#random card from the array.
func random_card()->Card:
	var rng = RandomNumberGenerator.new()
	return cards_in_group[rng.randi_range(0,cards_in_group.size()-1)]

#top card of the group (back card in the array)
func top_card()->Card:
	return cards_in_group.back()
