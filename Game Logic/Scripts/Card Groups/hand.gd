class_name Hand extends CardGroup
## group of cards set up like a hand

var offset_curve: Curve
var angle_curve:Curve

var owning_player:CardPlayer

func _ready():
	owning_player = get_parent()
	offset_curve = load("res://Game Logic/hand_offset.tres")	
	angle_curve = load("res://Game Logic/hand_angle.tres")

func receive_card(payload:Card):
	payload.owning_player = owning_player
	if owning_player.is_human:
		payload.isClickable = true
		#when the card gets to the player's hand, set isClickable
	
	super.receive_card(payload)
	reposition_cards()
	
#send the card to the right place in the hand
func _new_card_offset()->Vector2:
	
	var total_width = (Card.clubs_tex.front().get_width()*0.5) * num_cards
	var total_height = (Card.clubs_tex.front().get_height())
	var facing = Vector2.from_angle(global_rotation)
	
	var sample_value = 1
	
	var percent_total_width = offset_curve.sample(sample_value)
	
	var vertOffset = Vector2(0,abs(percent_total_width)*total_height).rotated(global_rotation)
	
	var newPos = global_position + vertOffset+ (facing * (percent_total_width*total_width))
	
	
	return newPos



	
#move all the cards relative to how many cards are in the hand
func reposition_cards():
	var total_width = (Card.clubs_tex.front().get_width()*0.5) * num_cards
	var total_height = (Card.clubs_tex.front().get_height())
	var facing = Vector2.from_angle(global_rotation)
	
	var i:float = 0
	for card in cards_in_group:
		
		var sample_value : float = i / num_cards
		
		var percent_total_width = offset_curve.sample(sample_value)
		
		var vertOffset = Vector2(0,abs(percent_total_width)*total_height).rotated(global_rotation)
	
		var newPos = global_position + vertOffset+ (facing * (percent_total_width*total_width))
		var  rotOffset = angle_curve.sample(sample_value)
		
		var newAngle =  global_rotation + rotOffset
		
			
			
		
		var behavior = BehaviorFactory.rotate(newAngle,0.2,0.02)
		var shift = ActionFactory.translate_to(newPos,0.2,true,Action.EaseType.easeInOutSine,0.5)
		BehaviorFactory.add_action_to_behavior(shift,behavior)
			
		card.add_child(behavior,true)
		i = i+1

#rotate it however this object is rotated
func _new_card_rotation()->float:
	var sample_value = 1
	var new_rot = global_rotation + angle_curve.sample(sample_value)
	
	print(global_rotation)
	print(new_rot)
	
	if new_rot < 0:
		new_rot = 2*PI +new_rot
	
	return new_rot
	 
	
func send_card(payload:Card,target:CardGroup):
	if owning_player.is_human:
		#why do I do this?  might be bug
		#TODO: test removing this line or changing to false
		payload.isClickable = true
	super.send_card(payload,target)
	reposition_cards()
