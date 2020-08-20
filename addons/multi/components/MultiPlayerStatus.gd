tool
extends HBoxContainer

export var icon_player_connected = preload("res://addons/multi/assets/icons/player.png") setget _set_icon_player_connected
export var icon_player_disconnected = preload("res://addons/multi/assets/icons/player_inactive.png") setget _set_icon_player_disconnected
export var icon_assign_controller = preload("res://addons/multi/assets/icons/bubble.png") setget _set_icon_assign_controller

const PlayerStatus = preload("PlayerStatus.gd")

func _ready():
	for p in range(Multi.MAX_PLAYERS):
		var player_status = PlayerStatus.new()
		player_status.player_id = p
		add_child(player_status)
	recreate()
		
func recreate():
	for child in get_children():
		child.icon_player_connected = icon_player_connected
		child.icon_player_disconnected = icon_player_disconnected

#############################################################
# SETTERS
func _set_icon_player_connected(v):
	icon_player_connected = v
	recreate()
	
func _set_icon_player_disconnected(v):
	icon_player_disconnected = v
	recreate()
	
func _set_icon_assign_controller(v):
	icon_assign_controller = v
	recreate()
