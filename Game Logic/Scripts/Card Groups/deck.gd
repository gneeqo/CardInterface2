class_name Deck extends CardGroup


func spawn_cards():
	for i in range(0,13):
		for j in range (0,4):
			var new_card = Card.create(i,j)
			_add_card(new_card)
			new_card.global_position = _new_card_offset()
	shuffle()
