tool
extends KinematicBody2D

# get Player object from customizable player_id
export(int) var player_id:int = 0
export(Color) var color = Color(0.8, 0.2, 0.2, 0.9) setget _on_set_color

onready var player:Player = Multi.player(player_id)

onready var sprite:Sprite = $Sprite

# some character vars
const dash_power = 500
const bounce_factor = 0.5
const gravity = 300

var velocity = Vector2.ZERO

var has_dashed = false

func _ready():
	$Label.text = str(player_id + 1)
	player.connect("controller_connection_changed", self, "_on_controller_connection_changed")
	_on_controller_connection_changed()
	_on_set_color(color)

func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	if !has_dashed and player.is_action_just_pressed("dash"):
		var x = player.get_action_strength("ui_right") - player.get_action_strength("ui_left")
		var y = player.get_action_strength("ui_down") - player.get_action_strength("ui_up")
		if abs(x) > 0 or abs(y) > 0:
			dash(Vector2(x, y))
	
	velocity.y += gravity * delta
	
	var prev_vel = Vector2(velocity.x, velocity.y)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	for slide_idx in range(get_slide_count()):
		bounce_off(get_slide_collision(slide_idx), prev_vel)
		prev_vel = Vector2(velocity.x, velocity.y)

func bounce_off(slide:KinematicCollision2D, prev_vel:Vector2):
	has_dashed = false
	velocity += slide.normal * bounce_factor * prev_vel.length()
	
	var collider = slide.collider
	if collider is KinematicBody2D:
		collider.velocity -= slide.normal * bounce_factor * prev_vel.length()

func dash(direction:Vector2):
	velocity = direction.normalized() * dash_power
	has_dashed = true
		
func _on_controller_connection_changed():
	# if controller disconnected: show animation
	if player.is_controller_connected():
		$AnimationPlayer.stop()
		$Sprite.modulate.a = 1
	else:
		$AnimationPlayer.play("controller_disconnected")

func _on_set_color(v):
	color = v
	$Sprite.modulate = color
