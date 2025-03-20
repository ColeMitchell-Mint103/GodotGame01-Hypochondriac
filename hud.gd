extends CanvasLayer
class_name Player_HUD

@export var Player_Link:Player_Char
var bull_sprite = preload("res://bullet_sprite.tscn")
var magazine_sprite = preload("res://magazine_sprite.tscn")
var magazine_collection = []
var slot_display = [null,null,null]
var slot_display_waiting = []
var active_mag
var BULLET = {'NORMAL': [5000, 1, "res://art assets/Heavy_Bullet.png"],
'DAM': [6000, 3, "res://art assets/Bullet_DAM.png"]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player_mags = Player_Link.magazine_array.duplicate()#Real mag class, not sprite
	for magazine in player_mags:
		var new_mag_sprite = magazine_sprite.instantiate() #Sprite magazine
		magazine_collection.append(new_mag_sprite)
		new_mag_sprite.rounds_array = magazine.rounds.duplicate()
		#ADD CHILD BEFORE MODIFYING
		$Magazine_Display_New/HBoxContainer.add_child(new_mag_sprite)
		update_mag(new_mag_sprite)
	#Setup initial magazines
	active_mag = magazine_collection[0]
	active_mag.reparent($"Firearm_Display/Insertion Point", false)
	magazine_collection[0].set_position($"Firearm_Display/Insertion Point".get_position())
	#magazine_collection[1].set_position($"Magazine_Display_New/HBoxContainer/Slot 1".get_position())
	#magazine_collection[2].set_position($"Magazine_Display_New/HBoxContainer/Slot 2".get_position())
	#Slot handing - experimental
	slot_display[0] = active_mag
	slot_display[1] = magazine_collection[1]
	slot_display[2] = magazine_collection[2]
	move_mags()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Sprite update for ammo display:
func update_mag(select):
	#delete old bullets
	for child in select.get_children():
		if child.is_in_group('bullet_sprite'):
			child.queue_free()
	#add bullets:
	var first_bullet = true
	var last_bullet = null
	var rounds_array = select.rounds_array.duplicate()
	#bullets need to be presented in opposite order as insertion
	rounds_array.reverse()
	for bullet in rounds_array:
		var new_bullet = bull_sprite.instantiate()
		#ADD CHILD BEFORE MODIFYING
		select.add_child(new_bullet)
		new_bullet.texture = load(BULLET[bullet][2])
		if first_bullet:
			first_bullet = false
			#Sends to Top_Slot on magazine_sprite:
			new_bullet.set_global_position(select.get_child(0).get_global_position())
		else:
			new_bullet.set_position(last_bullet.get_position())
			#Offset:
			new_bullet.global_translate(Vector2(-10,40))
			
		last_bullet = new_bullet

#General ammo display update
func _on_player_ammo_update() -> void:
	#Update chambered round
	if Player_Link.chamb_round:
		var loaded_round = bull_sprite.instantiate()
		$Firearm_Display/Chambered_Point.add_child(loaded_round)
		#loaded_round.set_name('ROUND')
		loaded_round.texture = load(BULLET[Player_Link.chamb_round][2])
		#loaded_round.set_position($Firearm_Display/Chambered_Point.get_position())
	#else:
		#$Firearm_Display.get_children().pop_back().queue_free() #<- UNSAFE PLEASE FIX
		#$Firearm_Display.find_child('ROUND').queue_free()
	
	#Update magazine if not empty
	if active_mag and active_mag.rounds_array.size() > 0:
		active_mag.get_children().pop_front().queue_free()
		active_mag.rounds_array.pop_back()
		update_mag(active_mag)
	pass
	

#Specific signal for weapon firing
func _on_player_fired() -> void:
	#Clear old round
	print(Player_Link.chamb_round)
	if $Firearm_Display/Chambered_Point.get_child_count() > 0:
		$Firearm_Display/Chambered_Point.get_children().pop_back().queue_free()
	#$Firearm_Display.find_child('ROUND').queue_free()

#Pull out magazine, exposing magazine selection HUD
func _on_player_magazine_out() -> void:
	$Magazine_Display_New.set_modulate(Color(1,1,1,1)) # Use instead of visible to allow canvas to change!
	active_mag.reparent($Magazine_Display_New/HBoxContainer, false)
	active_mag = null
	move_mags()

#Slap that puppy back in, removing magazine HUD
func _on_player_magazine_in() -> void:
	active_mag = slot_display[0]
	active_mag.set_position($"Firearm_Display/Insertion Point".get_position())
	active_mag.reparent($"Firearm_Display/Insertion Point", false) # move to firearm display so it is visible
	$Magazine_Display_New.set_modulate(Color(1,1,1,0))#make selection invisible to not cover screen


#Scroll left <--
func _on_player_magazine_left() -> void:
	#slot display is 3 slots rn
	for index in slot_display.size():
		if index == 0:
			#slot -1 goes into reserve, slot 0 goes to slot -1, etc.
			#check for null, avoid bloating reserve array
			if slot_display[index] != null:
				slot_display[index].set_visible(0)
				slot_display_waiting.push_front(slot_display[index])
			slot_display[index] = slot_display[index + 1]
		elif index == slot_display.size() - 1:
			#slot +1 goes to 0, pulls from reserve to fill slot +1
			#slot_display[index].set_visible(0)
			slot_display[slot_display.size() - 1] = slot_display_waiting.pop_back()
			slot_display[index].set_visible(1)
		else: 
			slot_display[index] = slot_display[index + 1]
	move_mags()

#Scroll right -->
func _on_player_magazine_right() -> void:
	#slot display is 3 slots rn
	for index in range(slot_display.size() - 1, -1, -1): #reverse order for stability, REMINDER:end value is non-inclusive
		if index == slot_display.size() - 1:
			#slot +1 goes into reserve, slot 0 goes to slot +1, etc.
			#check for null, avoid bloating reserve array
			if slot_display[index] != null:
				slot_display[index].set_visible(0)
				slot_display_waiting.push_back(slot_display[index])
			slot_display[index] = slot_display[index - 1]
		elif index == 0:
			#slot -1 goes to 0, pulls from reserve to fill slot -1
			#slot_display[index].set_visible(0)
			slot_display[0] = slot_display_waiting.pop_front()
			slot_display[index].set_visible(1)
		else: slot_display[index] = slot_display[index - 1]
	move_mags()

#Shift magazines for visual selection HUD
func move_mags():
	if slot_display[0] != null: slot_display[0].set_position($"Magazine_Display_New/HBoxContainer/Slot 0".get_position())#slot 0
	if slot_display[1] != null: slot_display[1].set_position($"Magazine_Display_New/HBoxContainer/Slot 1".get_position())#slot 1
	if slot_display[2] != null: slot_display[2].set_position($"Magazine_Display_New/HBoxContainer/Slot 2".get_position())#slot 2

#Rudimentary methods for call-ability.
func set_anim(string):
	$Firearm_Display.set_animation(string)

func play_anim():
	$Firearm_Display.play()


func _on_player_2_ammo_update() -> void:
	pass # Replace with function body.


func _on_player_2_fired() -> void:
	pass # Replace with function body.


func _on_player_2_magazine_in() -> void:
	pass # Replace with function body.


func _on_player_2_magazine_left() -> void:
	pass # Replace with function body.


func _on_player_2_magazine_out() -> void:
	pass # Replace with function body.
