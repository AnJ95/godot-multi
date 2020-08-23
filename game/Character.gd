tool
extends KinematicBody2D

signal respawn_character(character)

# get Player object from customizable player_id
export(int) var player_id:int = 0
export(Color) var color = Color(0.8, 0.2, 0.2, 0.9) setget _on_set_color

onready var player:Player = Multi.player(player_id)

onready var sprite = $Sprites
onready var animation_player:AnimationPlayer = $AnimationPlayer

onready var game_bounds = get_viewport_rect().grow(out_of_screen_tolerance)

# some character vars
const out_of_screen_tolerance = 100
const dash_power = 500
const bounce_factor = 0.5
const gravity = 300
const health_initial = 3

var health = health_initial
var velocity = Vector2.ZERO

var has_dashed = true

var squish = 0

func _ready():
	player.connect("controller_connection_changed", self, "_on_controller_connection_changed")
	_on_controller_connection_changed()
	_on_set_color(color)

func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	# Dash
	if !has_dashed and player.is_action_just_pressed("dash"):
		var x = player.get_action_strength("ui_right") - player.get_action_strength("ui_left")
		var y = player.get_action_strength("ui_down") - player.get_action_strength("ui_up")
		if abs(x) > 0 or abs(y) > 0:
			dash(Vector2(x, y))
	
	# Gravity
	velocity.y += gravity * delta
	
	var prev_vel = Vector2(velocity.x, velocity.y)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Bounce off other
	for slide_idx in range(get_slide_count()):
		bounce_off(get_slide_collision(slide_idx), prev_vel)
		break
	
	# Shape
	sprite.rotation = lerp_angle(sprite.rotation, Vector2.UP.angle_to(velocity), min(delta * 5, 1))
	sprite.scale.y = 1 - squish
	sprite.scale.x = 1 + squish
	
	squish -= squish * delta * 5
	
	# Die
	if !game_bounds.has_point(global_position):
		velocity.x = 0
		velocity.y = 0
		health -= 1
		has_dashed = true
		if health > 0:
			emit_signal("respawn_character", self)
		else:
			get_parent().remove_child(self)
			queue_free()

func bounce_off(slide:KinematicCollision2D, prev_vel:Vector2):
	has_dashed = false
	velocity += slide.normal * bounce_factor * prev_vel.length()
	
	var collider = slide.collider
	if collider is KinematicBody2D:
		collider.velocity -= slide.normal * bounce_factor * prev_vel.length()
	
	sprite.rotation = Vector2.UP.angle_to(slide.normal)
	squish = min(squish + prev_vel.length() * 0.001, 1)

func dash(direction:Vector2):
	velocity = direction.normalized() * dash_power
	has_dashed = true
	
	sprite.rotation = Vector2.UP.angle_to(velocity)
	squish = max(squish -0.4, -1)
		
func _on_controller_connection_changed():
	# if controller disconnected: show animation
	if player.is_controller_connected():
		$AnimationPlayer.stop()
		$Sprites.modulate.a = 1
	else:
		$AnimationPlayer.play("controller_disconnected")

func _on_set_color(v):
	color = v
	$Sprites.modulate = color
