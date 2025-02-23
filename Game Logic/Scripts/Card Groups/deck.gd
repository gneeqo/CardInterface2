class_name Deck extends CardGroup


func spawn_cards():
	for i in range(0,13):
		for j in range (0,4):
			_add_card(Card.create(i,j))
