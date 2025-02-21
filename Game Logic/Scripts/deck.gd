class_name Deck extends CardStack


@export var front_images :Array[Texture2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_deck(52)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_deck(numCards:int):
	for i in numCards:
		var card_scene: PackedScene = load("res://Scenes/card.tscn")
		var newCard:Card = card_scene.instantiate()
		
		newCard.change_FrontSprite(front_images[i])
		
		var card_width = newCard.get_node("FrontSprite").texture.get_width()
		var card_height = newCard.get_node("FrontSprite").texture.get_height()
		newCard.position = Vector2(card_width + (i%13)*card_width,(i%4)*card_height)
		
		newCard.value = i
		
		
		cards.push_back(newCard)
		add_child(newCard)
