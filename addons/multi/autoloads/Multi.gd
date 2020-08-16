tool
extends Node

const MAKE_KEYBOARD_PLAYER_ONE = true
const MAX_PLAYERS = 4

const Player = preload("res://addons/multi/scripts/Player.gd")
const Controller = preload("res://addons/multi/scripts/Controller.gd")

var __controllers = {}
var __players = []

signal num_connected_players_changed()

func _ready():
	if Engine.editor_hint:
		return
		
	# Create Player objects
	for i in range(MAX_PLAYERS):
		var player = Player.new(i)
		__players.append(player)
		
	# Multiplex all actions
	#    For an action "action" and for every player, a new action "player_0_action"
	#    will be created, and every InputEventJoypadButton and InputEventJoypadMotion
	#    will be copied.
	#    Must be done before the Controllers are added
	InputMap.load_from_globals()
	__multiplex_actions()
	
	# Add Keyboard as first player
	if MAKE_KEYBOARD_PLAYER_ONE:
		var controller = Controller.new()
		controller.init_from_keyboard()
		__controllers[-1] = controller
		player(0).set_controller(controller)
	
	# Add all already connected joypads...
	for device_id in Input.get_connected_joypads():
		_on_joy_connection_changed(device_id, true)
	
	# ...and await future changes
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")


func __multiplex_actions():
	for action in InputMap.get_actions():
		#print("###### " + action)
		
		for player_id in range(MAX_PLAYERS):
			#print("####   " + str(player_id))
			
			var player = __players[player_id]
			var converted_action = player.__convert_action(action)
			
			# Create new player-specific action
			if InputMap.has_action(converted_action):
				InputMap.erase_action(converted_action)
			InputMap.add_action(converted_action)
			
			for event in InputMap.get_action_list(action):
				var is_keyboard = (MAKE_KEYBOARD_PLAYER_ONE and player_id == 0)
				var ev_is_joypad = (event is InputEventJoypadButton or event is InputEventJoypadMotion)
				
				# Only copy JoypadEvents, unless player 1 is keyboard
				if (is_keyboard and !ev_is_joypad) or (!is_keyboard and ev_is_joypad):
					# Create new copy of the event
					var new_event:InputEvent = event.duplicate(true)
					
					# will be set on Player.set_controller
					# set to something invalid to prevent false actions
					new_event.device = 100
					
					#print("##     " , new_event)
					InputMap.action_add_event(converted_action, new_event)
	
func _on_joy_connection_changed(device_id:int, connected:bool):
	# Add new Controller object if this is the first time connecting
	if !__controllers.has(device_id):
		var controller = Controller.new()
		controller.init_from_device(device_id)
		__controllers[device_id] = controller
		
		# Attach to first Player without controller
		for player_id in range(MAX_PLAYERS):
			var player = __players[player_id]
			if !player.has_controller_assigned():
				player.set_controller(controller)
				break
	
	# Update connection status
	var controller = __controllers[device_id]
	controller.set_controller_connected(connected)
	
	emit_signal("num_connected_players_changed")
	
	# Debug print
	if connected:
		print("[CONTROLLER CONNECTED] ", device_id, " ", controller.get_name())
	else:
		print("[CONTROLLER DISCONNECTED] ", device_id, " ", controller.get_name())

func get_num_connected_players()->int:
	var num = 0
	for player in __players:
		if player.is_controller_connected():
			num += 1
	return num
	
func player(player_id):
	if player_id >= 0 and player_id < __players.size():
		return __players[player_id]
	else:
		printerr("Tried getting player with invalid player_id ", player_id)
		return null
