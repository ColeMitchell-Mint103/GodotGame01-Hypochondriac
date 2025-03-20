extends RigidBody2D

@export var health = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hit(damage):
	health -= damage
	if health > 0:
		$Hit_SFX.play()
		$Hit_SFX.pitch_scale += .1
	else:
		$Hit_SFX.pitch_scale = 0.9
		$Hit_SFX.play()
		$Die_SFX.play()
		await(get_tree().create_timer(1)).timeout
		queue_free()
	
