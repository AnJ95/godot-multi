tool
extends Control

export var player_id = 0 setget _set_player_id

export var icon_player_connected = preload("res://addons/multi/assets/icons/player.png") setget _set_icon_player_connected
export var icon_player_disconnected = preload("res://addons/multi/assets/icons/player_semiactive.png") setget _set_icon_player_disconnected
export var icon_player_inactive = preload("res://addons/multi/assets/icons/player_inactive.png") setget _set_icon_player_inactive

var player:Player
var texture_rect:TextureRect

func _ready():
	rect_min_size.x = 40
	rect_min_size.y = 40
	check_texture_rect()
	recreate()
	
func check_texture_rect():
	if !texture_rect:
		texture_rect = TextureRect.new()
		texture_rect.expand = true
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.anchor_bottom = 1
		texture_rect.anchor_right = 1
		texture_rect.size_flags_horizontal = SIZE_EXPAND_FILL
		texture_rect.size_flags_vertical = SIZE_EXPAND_FILL
		add_child(texture_rect)

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

func _on_player_state_changed():
	var icon = icon_player_inactive
	
	if player:
		if player.has_controller_assigned():
			icon = icon_player_disconnected
		if player.is_controller_connected():
			icon = icon_player_connected
	
	
	check_texture_rect()
	texture_rect.texture = icon
	
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

func _set_icon_player_inactive(v):
	icon_player_inactive = v
	recreate()

