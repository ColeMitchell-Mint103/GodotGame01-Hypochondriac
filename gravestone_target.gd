extends StaticBody2D

var pristine = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hit(damage):
	if pristine:
		$AnimatedSprite2D.play()
		pristine = false
		set_collision_layer_value(2, false)
	#play sound
