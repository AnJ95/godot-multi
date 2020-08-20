tool
extends Control

export var player_id = 0 setget _set_player_id

export var icon_player_connected = preload("res://addons/multi/assets/icons/player.png") setget _set_icon_player_connected
export var icon_player_disconnected = preload("res://addons/multi/assets/icons/player_inactive.png") setget _set_icon_player_disconnected
export var icon_assign_controller = preload("res://addons/multi/assets/icons/bubble.png") setget _set_icon_assign_controller

var player:Player
var texture_rect:TextureRect
var add_icon:TextureRect

func _ready():
	rect_min_size.x = 40
	rect_min_size.y = 40
	check_texture_rect()
	recreate()
	Multi.connect("new_controller_connected", self, "_on_player_state_changed")
	
func check_texture_rect():
	if !texture_rect:
		texture_rect = TextureRect.new()
		texture_rect.expand = true
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.anchor_bottom = 1
		texture_rect.anchor_right = 1
		add_child(texture_rect)
		
func check_add_icon():
	if !add_icon:
		add_icon = TextureRect.new()
		add_icon.expand = true
		add_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_icon.anchor_top = -1
		add_icon.anchor_right = 0.8
		add_icon.anchor_left = 0.2
		add_icon.texture = icon_assign_controller
		add_child(add_icon)
		
		var tween:Tween = Tween.new()
		add_child(tween)
		tween.repeat = true
		tween.interpolate_property(add_icon, "modulate:a", 1, 0.5, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0)
		tween.interpolate_property(add_icon, "modulate:a", 0.5, 1, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.5)
		tween.call_deferred("start")
		

func recreate():
	# disconnect signal if there was a prev Player
	if player:
		player.disconnect("controller_connection_changed", self, "_on_player_state_changed")
	
	# get new player
	player = Multi.player(player_id)
	
	# connect handler to new player (only if player valid)
	if player:
		player.connect("controller_connection_changed", self, "_on_player_state_changed")
	_on_player_state_changed()
	
func _on_player_state_changed(_x=null):
	# Change icon
	var icon = icon_player_disconnected
	
	if player and player.is_controller_connected():
		icon = icon_player_connected
	
	check_texture_rect()
	texture_rect.texture = icon
	
	# Indicate if controller can be assigned
	var num_controllers = Multi.get_num_known_controllers()
	check_add_icon()
	add_icon.visible = (!player or !player.is_controller_connected()) and player_id < num_controllers
	
	
#############################################################
# SETTERS
func _set_player_id(v):
	player_id = v
	recreate()
	
func _set_icon_player_connected(v):
	icon_player_connected = v
	recreate()
	
func _set_icon_player_disconnected(v):
	icon_player_disconnected = v
	recreate()
	
func _set_icon_assign_controller(v):
	icon_assign_controller = v
	recreate()

