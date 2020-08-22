tool
extends Node

const ALLOW_ONE_KEYBOARD_PLAYER = true
const AUTO_ASSIGN_KEYBOARD_TO_PLAYER_ONE = false

const GIVE_UI_ACCESS_ONLY_TO_PLAYER_ONE = true

const MAX_PLAYERS = 4

const PRETTY_ACTION_NAMES = {
	"dash" : "Dash",
	"ui_left" : "Left",
	"ui_right" : "Right",
	"ui_up" : "Up",
	"ui_down" : "Down",
	"ui_accept" : "Accept",
	"ui_cancel" : "Cancel"
}

const PREFFERED_ACTION_ORDER = [
	"dash",
	"ui_left",
	"ui_right",
	"ui_up",
	"ui_down",
	"ui_accept",
	"ui_cancel"
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

const BindPopup = preload("res://addons/multi/components/MultiPlayerBindPopup.gd")

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
	connect("num_assigned_players_changed", self, "_on_num_assigned_players_changed")
	
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
	
	for action in InputMap.get_actions():
		__input_map[action] = []
		for event in InputMap.get_action_list(action):
			__input_map[action].append(event)
			
		if action.begins_with("ui_"):
			for event in InputMap.get_action_list(action):
				InputMap.action_erase_event(action, event)
		else:
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

func _on_num_assigned_players_changed(_num):
	# Check enforcement condition
	__check_enforce()
	
func get_bind_popup_singleton()->WindowDialog:
	var popup = get_tree().get_nodes_in_group("MultiPlayerBindPopup")
	if popup.size() > 0:
		popup = popup[0]
	else:
		popup = WindowDialog.new()
		popup.set_script(BindPopup)
		
		var canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 100
		
		canvas_layer.add_child(popup)
		get_tree().root.add_child(canvas_layer)
	
	return popup

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

func get_num_known_controllers()->int:
	return __controllers.size()


var __enforcing:bool = false
var __enforce_min:int
func start_enforcing_player_num(num_min=-1, num_max=-1)->void:
	__enforcing = true
	__enforce_min = get_num_assigned_players() if num_min == -1 else num_min
	
	__check_enforce()
	
func stop_enforcing_player_num()->void:
	__enforcing = false

func is_enforcing_player_num()->bool:
	return __enforcing

func is_enforcement_satisfied()->bool:
	var n = get_num_assigned_players()
	return n >= __enforce_min
	
func __check_enforce():
	if __enforcing:
		if !is_enforcement_satisfied():
			get_bind_popup_singleton().popup_centered()
	
func player(player_id)->Player:
	if player_id >= 0 and player_id < __players.size():
		return __players[player_id]
	else:
		printerr("Tried getting player with invalid player_id ", player_id)
		return null
