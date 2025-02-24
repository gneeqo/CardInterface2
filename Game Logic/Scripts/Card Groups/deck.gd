class_name Deck extends CardGroup


func spawn_cards():
	for i in range(0,13):
		for j in range (0,4):
			var new_card = Card.create(i,j)
			_add_card(new_card)
			num_cards +=1
			new_card.global_position = _new_card_offset()
			new_card.global_rotation = _new_card_rotation()
	shuffle()

func _new_card_offset() -> Vector2:
	return Vector2(global_position.x + (0.15*num_cards),global_position.y-(0.1*num_cards))
	
func _new_card_rotation() -> float:
	return global_rotation + randf_range(-0.05,0.05)
