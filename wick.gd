extends CharacterBody2D
class_name Player_Char

@export var HUD_Link:Player_HUD
#enum {NORMAL}
var speed = 100
var screen_size
var curr_magazine
var chamb_round
var bull_scene = preload("res://bullet.tscn")
var casing_scene = preload("res://casing.tscn")
var magazine_array = []
var magazine_chosen = 0
var slide_locked = false

signal ammo_update
signal fired
signal magazine_out
signal magazine_in
signal magazine_left
signal magazine_right

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size  = get_viewport_rect().size
	magazine_array.append(temp_magazine())
	magazine_array.append(temp_magazine())
	magazine_array.append(temp_magazine())
	curr_magazine = magazine_array[0]
	chamb_round = curr_magazine.feed()
	ammo_update.emit()

#TEMP Replace when magazine mechanics are coded.
func temp_magazine():
	return Magazine.new(['DAM', 'DAM', 'NORMAL', 'NORMAL', 'NORMAL'])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity  = Vector2.ZERO
	if Input.is_action_pressed('left'):
		velocity.x += speed * -1
	if Input.is_action_pressed('right'):
		velocity.x += speed
	if Input.is_action_pressed('up'):
		velocity.y += -800
	#if Input.is_action_pressed('down'):
		#velocity.y += speed
	velocity.y += 9800 * delta
	#if velocity.length() > 0:
		#velocity = velocity.normalized() * speed
	#position += velocity * delta
	#position = position.clamp(Vector2.ZERO, screen_size)
	move_and_slide()
	
	#Shooting:
	if Input.is_action_just_pressed('Shoot'):
		if slide_locked:
			print('Out of Battery!')
			pass
		elif chamb_round:
			HUD_Link.set_anim('Fire_full')
			_shoot()
		else:
			HUD_Link.set_anim('Fire_drytriggerpull')
			HUD_Link.play_anim()
			$Dryfire_sound.play()
	
	#Aiming:
	look_at(get_global_mouse_position())
	
	#Slide pull:
	if Input.is_action_just_pressed("RACK"):
		#todo: eject(chamb_round)
		if chamb_round:
			print('Ejected: ' + chamb_round)
		if curr_magazine:
			chamb_round = curr_magazine.feed()
		else: chamb_round = null
		fired.emit()
		ammo_update.emit()
		$RackSlide_sound.play()
		HUD_Link.set_anim('Fire_rack')
		HUD_Link.play_anim()
		slide_locked = false
	
	#Press slide lock lever:
	if Input.is_action_just_pressed("Slide_Lever"):
		if slide_locked:
			if curr_magazine:
				chamb_round = curr_magazine.feed()
			slide_locked = false
			ammo_update.emit()
			$SlideClose_sound.play()
			HUD_Link.set_anim('Fire_toBattery')
			HUD_Link.play_anim()
	
	#Eject mag:
	if Input.is_action_just_pressed("Eject"):
		if curr_magazine:
			curr_magazine = null
			#ammo_update.emit()
			magazine_out.emit()
			$Eject_sound.play()
		
	# Insert mag:
	if Input.is_action_just_pressed("Insert"):
		if not curr_magazine:
			curr_magazine = magazine_array[magazine_chosen]
			#ammo_update.emit()
			magazine_in.emit()
			$Insert_sound.play()
		else:
			print('Tap')
	
	#Go left selecting magazine:
	if Input.is_action_just_pressed("Magazine_Down"):
		if not curr_magazine:
			magazine_chosen = (magazine_chosen - 1) % (magazine_array.size()) # size starts at 1, array starts at 0 
			#ammo_update.emit()
			magazine_left.emit()
		
	#Go right selecting magazine:
	if Input.is_action_just_pressed("Magazine_Up"):
		if not curr_magazine:
			magazine_chosen = abs((magazine_chosen + 1) % (magazine_array.size()))
			#ammo_update.emit()
			magazine_right.emit()
	

func _shoot():
	fired.emit()
	#var bullet_inst = curr_magazine.feed()
	var projectile = bull_scene.instantiate()
	#var projectile = Bullet.new(NORMAL)
	#projectile.set_script("res://bullet.gd")
	projectile.position = $Barrel.get_global_position()
	projectile.rotation = rotation
	#projectile.apply_impulse(Vector2(1000,0).rotated(rotation), position)
	projectile.fire(chamb_round)
	get_tree().get_root().call_deferred('add_child', projectile)
	
	var casing = casing_scene.instantiate()
	casing.position = $Barrel.get_global_position()
	casing.rotation = rotation
	#casing.apply_impulse(Vector2(-1000,0), position)
	casing.apply_impulse(Vector2(projectile.speed / -3, 0).rotated(rotation), position)
	get_tree().get_root().call_deferred('add_child', casing)
	#chamb_round = Bullet.new(NORMAL)
	#chamb_round.show()
	#var valley = bull_scene.instantiate(chamb_round)
	#chamb_round.position = $Barrel.get_global_position()
	#chamb_round.rotation = rotation
	#get_tree().get_root().call_deferred('add_child', chamb_round)
	#chamb_round.fire()
	#add_child(bullet_inst)
	#bullet_inst.apply_impulse(Vector2(), Vector2(bullet_speed,0).rotated(rotation))
	#get_tree().get_root().call_deferred('add_child', chamb_round)
	#print('BANG')
	if curr_magazine and curr_magazine.loaded() >= 1:
		chamb_round = curr_magazine.feed()
		slide_locked = false
		HUD_Link.play_anim()
	else:
		chamb_round = null
		slide_locked = true
		HUD_Link.set_anim('Fire_empty')
	HUD_Link.play_anim()
	$Firing_sound.play()
	ammo_update.emit()

#func _input(event):
	#if event is InputEventMouseButton:
		#_shoot()
	#if event is InputEventMouseMotion:
		#look_at(get_global_mouse_position())
