extends KinematicBody2D

export(int) var player_id:int = 0
onready var player = Multi.player(player_id)

const SPEED = 80
var velocity = Vector2()

func _physics_process(delta):
	var x = player.get_action_strength("ui_right") - player.get_action_strength("ui_left")
	var y = player.get_action_strength("ui_down") - player.get_action_strength("ui_up")
	
	velocity.x = x * SPEED
	velocity.y = y * SPEED
	
	velocity = move_and_slide(velocity, Vector2.UP)
