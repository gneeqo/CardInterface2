class_name AutomatedOptionButton extends OptionButton
##selector that hooks into automation
signal self_selected_item(index:int)
signal self_pressed()

func _ready():
	add_to_group("auto_clickable", true)
	

func _on_item_selected(index: int) -> void:
	self_selected_item.emit(index)


func _on_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		add_to_group("auto_selectable", true)
	else:
		remove_from_group("auto_selectable")
	
	self_pressed.emit()


func auto_press():
	button_pressed = !button_pressed

func auto_select(index:int):
	self_selected_item.emit(index)
	button_pressed = !button_pressed	
