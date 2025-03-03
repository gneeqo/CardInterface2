class_name AutomatedButton extends Button
##button that hooks into automation
signal self_pressed

func _ready():
	add_to_group("auto_clickable",true)

func _on_pressed() -> void:
	self_pressed.emit()
	
func auto_press():
	self_pressed.emit()
