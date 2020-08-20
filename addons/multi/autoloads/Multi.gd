tool
extends Node

const ALLOW_ONE_KEYBOARD_PLAYER = true
const AUTO_ASSIGN_KEYBOARD_TO_PLAYER_ONE = false

# Internally, every action like "jump" is duplicated to "p_0_jump", "p_1_jump", ...
# and the original "jump" is deleted.
# Add any action to the regex if you don't want it do be deleted.
const EXCLUDE_ACTIONS_FROM_DELETION:String = "^(ui_)"

const MAX_PLAYERS = 4

const PRETTY_ACTION_NAMES = {
	"ui_accept" : "Accept",
	"ui_cancel" : "Cancel",
	"ui_left" : "Left",
	"ui_right" : "Right",
	"ui_up" : "Up",
	"ui_down" : "Down"
}

const PREFFERED_ACTION_ORDER = [
	"ui_accept",
	"ui_cancel",
	"ui_left",
	"ui_right",
	"ui_up",
	"ui_down"
]

const MOUSE_BUTTON_STRINGS = {
	BUTTON_LEFT : "Mouse Left",
	BUTTON_RIGHT : "Mouse Right",
	BUTTON_MIDDLE : "Mouse Middle",
	BUTTON_XBUTTON1 : "Mouse X1",
	BUTTON_XBUTTON2 : "Mouse X2",
	BUTTON_WHEEL_UP : "Mouse Wheel Up",
	BUTTON_WHEEL_DOWN : "Mouse Wheel Down",
	BUTTON_WHEEL_LEFT : "Mouse Wheel Left",
	BUTTON_WHEEL_RIGHT : "Mouse Wheel Right"
}

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
	
	# Don't add controllers in editor
	if Engine.editor_hint:
		return
		
	# Saves and removes InputMap
	__preprocess_input_map()
	
	# Add Keyboard as first player
	if ALLOW_ONE_KEYBOARD_PLAYER:
		var controller = Controller.new()
		controller.init_from_keyboard()
		__add_new_controller(controller)
		controller.set_controller_connected(true)
		
		if AUTO_ASSIGN_KEYBOARD_TO_PLAYER_ONE:
			player(0).set_controller(controller, __input_map)
	
	# Add all already connected joypads...
	for device_id in Input.get_connected_joypads():
		_on_joy_connection_changed(device_id, true)
	
	# ...and await future changes
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

func _input(event:InputEvent):
	# Don't join in editor
	if Engine.editor_hint:
		return
	
#	debug print buttons
#	if __controllers.has(0):
#		var c = __controllers[0]
#		for i in range(20):
#			if Input.is_joy_button_pressed(0, i):
#				print(Input.get_joy_button_string(i), " ", i)
	
	# Find first unassigned player or return if already at max
	var player = __find_first_unassigned_player()
	if !player: return
	
	# check if any of the non-assigned controllers want to assign
	for controller in __controllers.values():
		controller.is_event_from_this_controller(event)
		var join_action = controller.get_join_action()
		if InputMap.has_action(join_action) and event.is_action(join_action):
			get_viewport().set_input_as_handled()
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
	regex.compile(EXCLUDE_ACTIONS_FROM_DELETION)
	
	for action in InputMap.get_actions():
		__input_map[action] = []
		for event in InputMap.get_action_list(action):
			__input_map[action].append(event)
			
		if !regex.search(action):
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


func get_pretty_string(event:InputEvent)->String:
	if event is InputEventJoypadButton:
		return Input.get_joy_button_string(event.button_index)
	elif event is InputEventKey:
		return OS.get_scancode_string(event.scancode)
	elif event is InputEventJoypadMotion:
		var pretty:String = Input.get_joy_axis_string(event.axis)
		pretty = pretty.replace("X", "Right" if event.axis_value > 0 else "Left")
		pretty = pretty.replace("Y", "Down" if event.axis_value > 0 else "Up")
		return pretty
	elif event is InputEventMouseButton:
		return MOUSE_BUTTON_STRINGS[int(event.button_index)] if MOUSE_BUTTON_STRINGS.has(int(event.button_index)) else ""
	return "Invalid"
	
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
