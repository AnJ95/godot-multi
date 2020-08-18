extends KinematicBody2D

export(int) var player_id:int = 0
onready var player:Player = Multi.player(player_id)

const SPEED = 80
var velocity = Vector2()

func _ready():
	$Label.text = str(player_id + 1)
	player.connect("controller_connection_changed", self, "_on_controller_connection_changed")
	_on_controller_connection_changed()

func _physics_process(_delta):
	velocity.x = SPEED * (player.get_action_strength("right") - player.get_action_strength("left"))
	velocity.y = SPEED * (player.get_action_strength("down") - player.get_action_strength("up"))
	
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_controller_connection_changed():
	if player.is_controller_connected():
		$AnimationPlayer.stop()
		$player.modulate.a = 1
	else:
		$AnimationPlayer.play("controller_disconnected")
