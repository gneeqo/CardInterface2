class_name Hand extends CardGroup

var owning_player:CardPlayer

func _ready():
	owning_player = get_parent()
	

func receive_card(payload:Card):
	payload.owning_player = owning_player
	if owning_player.is_human:
		payload.isClickable = true
	
	super.receive_card(payload)
	
func _new_card_offset()->Vector2:
	
	var horiz_offset = (Card.clubs_tex.front().get_width()*0.7) * num_cards
	var angled_vec = Vector2.from_angle(global_rotation) * horiz_offset
	
	return global_position + angled_vec

func _new_card_rotation()->float:
	return global_rotation
	
func send_card(payload:Card,target:CardGroup):
	if owning_player.is_human:
		payload.isClickable = true
	super.send_card(payload,target)
