extends Node

const MAX_PLAYERS = 4

const Player = preload("res://addons/multi/scripts/Player.gd")
const Controller = preload("res://addons/multi/scripts/Controller.gd")

var __controllers = {}
var __players = []

func _ready():
	# Add all already connected joypads...
	for device_id in Input.get_connected_joypads():
		_on_joy_connection_changed(device_id, true)
	
	# ...and await future changes
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	
	# Create Player objects
	for i in range(MAX_PLAYERS):
		var player = Player.new(i)
		__players.append(player)
	
	# TODO multiplex actions
	
	for action in InputMap.get_actions():
		#print("###### " + action)
		
		for player_id in range(MAX_PLAYERS):
			#print("#### " + str(player_id))
			
			var player = __players[player_id]
			var converted_action = player.__convert_action(action)
			
			# Create new player-specific action
			if InputMap.has_action(converted_action):
				InputMap.erase_action(converted_action)
			InputMap.add_action(converted_action)
			
			for event in InputMap.get_action_list(action):
				var new_event:InputEvent = null
				if event is InputEventJoypadButton:
					new_event = InputEventJoypadButton.new()
					new_event.button_index = event.button_index
				if event is InputEventJoypadMotion:
					new_event = InputEventJoypadMotion.new()
					new_event.axis = event.axis
					new_event.axis_value = event.axis_value
				
				# TODO this needs to be updated when a Player<->Controller connection is made
				new_event.device = 0
				
				if new_event:
					#print("## " , new_event)
					InputMap.action_add_event(converted_action, new_event)
	
	
	
func _on_joy_connection_changed(device_id:int, connected:bool):
	# Add new Controller object if this is the first time connecting
	if !__controllers.has(device_id):
		var controller = Controller.new()
		controller.init_from_device(device_id)
		__controllers[device_id] = controller
	
	# Update connection status
	var controller = __controllers[device_id]
	controller.set_controller_connected(connected)
	
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
	if player_id >= 0 and __players.size() < player_id:
		return __players[player_id]
	else:
		printerr("Tried getting player with invalid player_id ", player_id)
		return null
