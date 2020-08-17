tool
extends HBoxContainer

export var icon_player_connected = preload("res://addons/multi/assets/icons/player.png") setget _set_icon_player_connected
export var icon_player_disconnected = preload("res://addons/multi/assets/icons/player_semiactive.png") setget _set_icon_player_disconnected
export var icon_player_inactive = preload("res://addons/multi/assets/icons/player_inactive.png") setget _set_icon_player_inactive

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
		child.icon_player_inactive = icon_player_inactive

#############################################################
# SETTERS
func _set_icon_player_connected(v):
	icon_player_connected = v
	recreate()
	
func _set_icon_player_disconnected(v):
	icon_player_disconnected = v
	recreate()

func _set_icon_player_inactive(v):
	icon_player_inactive = v
	recreate()

