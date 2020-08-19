extends KinematicBody2D

# get Player object from customizable player_id
export(int) var player_id:int = 0
onready var player:Player = Multi.player(player_id)

# some character vars
const SPEED = 80
var velocity = Vector2()

func _ready():
	$Label.text = str(player_id + 1)
	player.connect("controller_connection_changed", self, "_on_controller_connection_changed")
	_on_controller_connection_changed()

func _physics_process(_delta):
	# use functions you are familiar with
	velocity.x = SPEED * (player.get_action_strength("ui_right") - player.get_action_strength("ui_left"))
	velocity.y = SPEED * (player.get_action_strength("ui_down") - player.get_action_strength("ui_up"))
	
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_controller_connection_changed():
	# if controller disconnected: show animation
	if player.is_controller_connected():
		$AnimationPlayer.stop()
		$player.modulate.a = 1
	else:
		$AnimationPlayer.play("controller_disconnected")
