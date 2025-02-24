class_name Pile extends CardGroup

func _new_card_offset()->Vector2:
	return Vector2(global_position.x + randf_range(-10,10)\
	,global_position.y + randf_range(-10,10))

func _new_card_rotation()->float:
	return global_rotation + randf_range(-0.2,0.2)
