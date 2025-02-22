class_name AutomatedButton extends Button

signal self_activated

func _ready():
	add_to_group("auto_clickable",true)

func _on_pressed() -> void:
	self_activated.emit()
	
func automated_activation():
	self_activated.emit()
