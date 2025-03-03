class_name Hand extends CardGroup
## group of cards set up like a hand

var owning_player:CardPlayer

func _ready():
	owning_player = get_parent()
	

func receive_card(payload:Card):
	payload.owning_player = owning_player
	if owning_player.is_human:
		payload.isClickable = true
		#when the card gets to the player's hand, set isClickable
	
	super.receive_card(payload)
	
#supposed to be set up like a fan of cards, but I didn't do that yet.
func _new_card_offset()->Vector2:
	
	var horiz_offset = (Card.clubs_tex.front().get_width()*0.7) * num_cards
	var angled_vec = Vector2.from_angle(global_rotation) * horiz_offset
	
	return global_position + angled_vec

#rotate it however this object is rotated
func _new_card_rotation()->float:
	return global_rotation
	
func send_card(payload:Card,target:CardGroup):
	if owning_player.is_human:
		#why do I do this?  might be bug
		#TODO: test removing this line or changing to false
		payload.isClickable = true
	super.send_card(payload,target)
