tool
extends Control

export var player_id = 0 setget _set_player_id

export var show_controller_status = false setget _set_show_controller_status

export var icon_player_connected = preload("res://addons/multi/assets/icons/player.png") setget _set_icon_player_connected
export var icon_player_disconnected = preload("res://addons/multi/assets/icons/player_inactive.png") setget _set_icon_player_disconnected

export var icon_assign_controller = preload("res://addons/multi/assets/icons/bubble.png") setget _set_icon_assign_controller

export var icon_joypad = preload("res://addons/multi/assets/icons/joypad.png") setget _set_icon_joypad
export var icon_keyboard = preload("res://addons/multi/assets/icons/keyboard.png") setget _set_icon_keyboard

var player:Player
var player_status:TextureRect
var controller_status:TextureRect
var add_icon:TextureRect

func _ready():
	check_player_status_icon()
	recreate()
	Multi.connect("new_controller_connected", self, "_on_player_state_changed")
	
func check_player_status_icon():
	if !player_status:
		player_status = TextureRect.new()
		player_status.expand = true
		player_status.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		player_status.anchor_top = 0
		player_status.rect_size = Vector2(40, 40)
		add_child(player_status)
		
	if show_controller_status and !controller_status:
		controller_status = TextureRect.new()
		controller_status.expand = true
		controller_status.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		controller_status.anchor_top = 0
		controller_status.margin_top = 40
		controller_status.rect_size = Vector2(40, 40)
		add_child(controller_status)
		
func check_add_icon():
	if !add_icon:
		add_icon = TextureRect.new()
		add_icon.expand = true
		add_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_icon.anchor_top = 0
		add_icon.margin_top = -40
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
	rect_min_size.x = 40
	rect_min_size.y = 80 if show_controller_status else 40
	
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
	# Show player status
	var icon_player = icon_player_disconnected
	
	if player and player.is_controller_connected():
		icon_player = icon_player_connected
	
	check_player_status_icon()
	player_status.texture = icon_player
	
	# Show controller status
	if show_controller_status:
		var icon_controller = null
		
		if player and player.is_controller_connected():
			match player.get_controller().__type:
				Controller.CONTROLLER_TYPE_JOYPAD:
					icon_controller = icon_joypad
				Controller.CONTROLLER_TYPE_KEYBOARD:
					icon_controller = icon_keyboard
		
		controller_status.texture = icon_controller
	
	# Indicate if controller can be assigned
	var num_controllers = Multi.get_num_known_controllers()
	check_add_icon()
	add_icon.visible = (!player or !player.is_controller_connected()) and player_id < num_controllers
	
	
#############################################################
# SETTERS
func _set_player_id(v):
	player_id = v
	recreate()

func _set_show_controller_status(v):
	show_controller_status = v
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
	
func _set_icon_joypad(v):
	icon_joypad = v
	recreate()
	
func _set_icon_keyboard(v):
	icon_keyboard = v
	recreate()

