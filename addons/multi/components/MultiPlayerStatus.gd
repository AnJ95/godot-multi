tool
extends Button

export var show_controller_status = false setget _set_show_controller_status

export var open_bind_popup_on_click = true

export var icon_player_connected = preload("res://addons/multi/assets/icons/player.png") setget _set_icon_player_connected
export var icon_player_disconnected = preload("res://addons/multi/assets/icons/player_inactive.png") setget _set_icon_player_disconnected

export var icon_assign_controller = preload("res://addons/multi/assets/icons/bubble.png") setget _set_icon_assign_controller

export var icon_joypad = preload("res://addons/multi/assets/icons/joypad.png") setget _set_icon_joypad
export var icon_keyboard = preload("res://addons/multi/assets/icons/keyboard.png") setget _set_icon_keyboard


const PlayerStatus = preload("PlayerStatus.gd")

var hbox

func _ready():
	# set button props
	var style:StyleBox = StyleBoxEmpty.new()
	add_stylebox_override("hover", style)
	add_stylebox_override("pressed", style)
	add_stylebox_override("focus", style)
	add_stylebox_override("disabled", style)
	add_stylebox_override("normal", style)
	focus_mode = Control.FOCUS_NONE
	if open_bind_popup_on_click:
		connect("pressed", self, "_on_pressed")
	recreate()
	
	rect_min_size = hbox.rect_size
	
func recreate():
	if !hbox:
		# add hbox
		hbox = HBoxContainer.new()
		hbox.mouse_filter = MOUSE_FILTER_IGNORE
		
		for p in range(Multi.MAX_PLAYERS):
			var player_status = PlayerStatus.new()
			player_status.player_id = p
			player_status.show_controller_status = show_controller_status
			hbox.add_child(player_status)
		
		add_child(hbox)
		
	for child in hbox.get_children():
		child.icon_player_connected = icon_player_connected
		child.icon_player_disconnected = icon_player_disconnected
		child.icon_assign_controller = icon_assign_controller
		child.icon_joypad = icon_joypad
		child.icon_keyboard = icon_keyboard
		child.show_controller_status = show_controller_status

#############################################################
# OPENING POPUP
	
func _on_pressed():
	Multi.get_bind_popup_singleton().popup_centered()
	
#############################################################
# SETTERS
func _set_icon_player_connected(v):
	icon_player_connected = v
	recreate()
	
func _set_show_controller_status(v):
	show_controller_status = v
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
