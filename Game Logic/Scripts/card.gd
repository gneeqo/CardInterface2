class_name Card extends Node2D

var value:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var scale = transform.get_scale()
	if(scale.x <0 ||scale.y < 0):
		$BackSprite.visible = true
		$FrontSprite.visible = false
	else:
		$BackSprite.visible = false
		$FrontSprite.visible = true


func change_FrontSprite(newTex:Texture2D):
	$FrontSprite.texture = newTex
