extends KinematicBody2D

export(int) var player_id:int = 0
onready var player = Multi.player(player_id)

const SPEED = 80
var velocity = Vector2()

func _ready():
	$Label.text = str(player_id + 1)

func _physics_process(_delta):
	velocity.x = SPEED * (player.get_action_strength("ui_right") - player.get_action_strength("ui_left"))
	velocity.y = SPEED * (player.get_action_strength("ui_down") - player.get_action_strength("ui_up"))
	
	velocity = move_and_slide(velocity, Vector2.UP)
