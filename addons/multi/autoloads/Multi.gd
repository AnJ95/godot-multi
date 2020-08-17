tool
extends Node

const MAKE_KEYBOARD_PLAYER_ONE = true
const MAX_PLAYERS = 4

var __controllers = {}
var __players = []

# when an input device first enters the stage
signal new_controller_connected(controller)

# when the number of Players with a valid input device changes
signal num_assigned_players_changed(num)


func _ready():
	if Engine.editor_hint:
		return
		
	# Create Player objects
	for i in range(MAX_PLAYERS):
		var player = Player.new(i)
		__players.append(player)
		
	# Multiplex all actions
	#    For an action "action" and for every player, a new action "player_0_action"
	#    will be created.
	#    Must be done before the Controllers are added
	InputMap.load_from_globals()
	__multiplex_actions()
	
	# Add Keyboard as first player
	if MAKE_KEYBOARD_PLAYER_ONE:
		var controller = Controller.new()
		controller.init_from_keyboard()
		__add_new_controller(controller)
		
		player(0).set_controller(controller)
	
	# Add all already connected joypads...
	for device_id in Input.get_connected_joypads():
		_on_joy_connection_changed(device_id, true)
	
	# ...and await future changes
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

func __add_new_controller(controller:Controller):
	__controllers[controller.__device_id] = controller
	emit_signal("new_controller_connected", controller)

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

func __find_first_unassigned_player()->Player:
	for player_id in range(MAX_PLAYERS):
		var player = __players[player_id]
		if !player.has_controller_assigned():
			return player
	return null

func _on_joy_connection_changed(device_id:int, connected:bool):
	# Add new Controller object if this is the first time connecting
	if !__controllers.has(device_id):
		# Create, init and add
		var controller = Controller.new()
		controller.init_from_device(device_id)
		__add_new_controller(controller)
		
		# Attach to first Player without controller
		var player = __find_first_unassigned_player()
		if player: player.set_controller(controller)
	
	# Update connection status
	var controller = __controllers[device_id]
	controller.set_controller_connected(connected)
	
	emit_signal("num_assigned_players_changed", get_num_assigned_players())
	
	# Debug print
	if connected:
		print("[CONTROLLER CONNECTED] ", device_id, " ", controller.get_name())
	else:
		print("[CONTROLLER DISCONNECTED] ", device_id, " ", controller.get_name())

func get_num_assigned_players()->int:
	var num = 0
	for player in __players:
		if player.is_controller_connected():
			num += 1
	return num
	
func player(player_id)->Player:
	if player_id >= 0 and player_id < __players.size():
		return __players[player_id]
	else:
		printerr("Tried getting player with invalid player_id ", player_id)
		return null
