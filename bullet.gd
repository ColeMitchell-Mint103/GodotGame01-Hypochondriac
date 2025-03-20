extends RigidBody2D
class_name Bullet

var speed
var damage
var BULLET = {'NORMAL': [5000, 1, "res://art assets/Heavy_Bullet.png"],
'DAM': [6000, 3, "res://art assets/Bullet_DAM.png"]
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#IMPORTANT:
	contact_monitor = true
	max_contacts_reported = 10
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#position += direction * speed * delta
	#position += transform.x * speed * delta
	pass

#Pull data from bullet type
#func _init(arg):
	#if arg:
		#speed = bullet_type[arg][0]
		#damage = bullet_type[arg][1]

#func fly(aim_pos, gun_pos):
	#global_position = gun_pos
	#direction = (aim_pos - gun_pos).normalized()
	#rotation = direction.angle()

#func _integrate_forces(state):
	#state.apply_force(Vector2(speed,0).rotated(rotation))

func fire(give_type):
	speed = BULLET[give_type][0]
	damage = BULLET[give_type][1]
	$Sprite2D.texture = load(BULLET[give_type][2])
	apply_impulse(Vector2(speed,0).rotated(rotation), position)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group('ReceiveDamage'):
		body.hit(damage)
		queue_free()




func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
