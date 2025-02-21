class_name Destroy extends Action

func _end_action():
	affected_node.queue_free()
