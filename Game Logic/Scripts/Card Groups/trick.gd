class_name Trick extends CardGroup

var anchors:Array[Node2D]
var referee : Referee

func _ready():
	referee = get_node_or_null("../referee")
	if referee == null:
		print("Game cannot start without referee!")
	for child in get_children():
		anchors.push_back(child)
		
func _new_card_offset():
	return anchors[referee.players.find(referee.active_player)].global_position

func _new_card_rotation():
	return anchors[referee.players.find(referee.active_player)].global_rotation
