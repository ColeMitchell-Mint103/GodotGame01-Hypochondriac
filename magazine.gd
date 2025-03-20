extends Node2D
class_name Magazine

var bullet: PackedScene = preload("res://bullet.tscn")
var rounds = []
enum {NORMAL}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _init(arg):
	if arg:
		for bullet_type in arg:
			rounds.append(bullet_type)

func feed():
	if rounds.size() > 0:
		return rounds.pop_back()

func loaded():
	return rounds.size()
