class_name Hand extends CardGroup

var owning_player:CardPlayer

func _ready():
	owning_player = get_parent()
	

func receive_card(payload:Card):
	payload.owning_player = owning_player
	super.receive_card(payload)
	
