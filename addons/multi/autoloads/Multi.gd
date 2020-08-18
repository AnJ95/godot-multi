tool
extends Node

const ALLOW_ONE_KEYBOARD_PLAYER = true
const AUTO_ASSIGN_KEYBOARD_TO_PLAYER_ONE = false

const EXCLUDE_ACTIONS:String = "^ui_"

const MAX_PLAYERS = 4

var __controllers = {}
var __players = []

var __input_map = {}

# when an input device first enters the stage
signal new_controller_connected(controller)

# when the number of Players with a valid input device changes
signal num_assigned_players_changed(num)


func _ready():
	# Create Player objects
	for i in range(MAX_PLAYERS):
		var player = Player.new(i)
		__players.append(player)
		
	# Saves and removes InputMap
	__preprocess_input_map()
	
	# Add Keyboard as first player
	if ALLOW_ONE_KEYBOARD_PLAYER:
		var controller = Controller.new()
		controller.init_from_keyboard()
		__add_new_controller(controller)
		
		if AUTO_ASSIGN_KEYBOARD_TO_PLAYER_ONE:
			player(0).set_controller(controller, __input_map)
	
	# Add all already connected joypads...
	for device_id in Input.get_connected_joypads():
		_on_joy_connection_changed(device_id, true)
	
	# ...and await future changes
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

func _process(_delta):
	# Find first unassigned player or return if already at max
	var player = __find_first_unassigned_player()
	if !player: return
	
	# check if any of the non-assigned controllers want to assign
	for controller in __controllers.values():
		if Input.is_action_just_pressed(controller.get_join_action()):
			__assign_controller_to_player(controller, player)

func __assign_controller_to_player(controller, player):
	player.set_controller(controller, __input_map)
	controller.remove_join_action()
	emit_signal("num_assigned_players_changed", get_num_assigned_players())

func __add_new_controller(controller:Controller):
	__controllers[controller.__device_id] = controller
	emit_signal("new_controller_connected", controller)

func __preprocess_input_map():
	InputMap.load_from_globals()
	
	var regex = RegEx.new()
	regex.compile(EXCLUDE_ACTIONS)
	
	for action in InputMap.get_actions():
		if regex.search(action):
			continue
		__input_map[action] = []
		for event in InputMap.get_action_list(action):
			__input_map[action].append(event)
		InputMap.erase_action(action)

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
	
	# Update connection status
	var controller = __controllers[device_id]
	controller.set_controller_connected(connected)

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
