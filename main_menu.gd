extends Control

var ready_start = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ready and Input.is_action_just_pressed("Insert"):
		get_tree().change_scene_to_file("res://Main.tscn")


func _on_start_b_pressed() -> void:
	$Intro_Panel.set_visible(1)
	ready_start = true


func _on_quit_b_pressed() -> void:
	get_tree().quit()
