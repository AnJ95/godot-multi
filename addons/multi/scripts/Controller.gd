extends Object
class_name Controller

signal connection_changed()

var __type:int = 0
var __device_id:int = 0
var __connected:bool = false

const CONTROLLER_TYPE_KEYBOARD = 1
const CONTROLLER_TYPE_JOYPAD = 2

func init_from_device(device_id:int)->void:
	__device_id = device_id
	__type = CONTROLLER_TYPE_JOYPAD
	__connected = true
	create_join_action()
	
func init_from_keyboard()->void:
	__device_id = -1
	__type = CONTROLLER_TYPE_KEYBOARD
	__connected = true
	create_join_action()

func get_join_action()->String:
	return "join_%d_%d" % [__type, __device_id]
	
func create_join_action():
	var action = get_join_action()
	InputMap.add_action(action)
	match __type:
		CONTROLLER_TYPE_KEYBOARD:
			var ev = InputEventKey.new()
			ev.scancode = OS.find_scancode_from_string("Space")
			InputMap.action_add_event(action, ev)
		CONTROLLER_TYPE_JOYPAD:
			for button_index in [JOY_XBOX_A, JOY_XBOX_B, JOY_XBOX_X, JOY_XBOX_Y, JOY_START, JOY_SELECT]:
				var ev = InputEventJoypadButton.new()
				ev.button_index = button_index
				ev.pressed = true
				ev.pressure = 1
				ev.device = __device_id
				InputMap.action_add_event(action, ev)
		_:
			printerr("Invalid controller type. Was the controller initialized?")

func remove_join_action():
	InputMap.erase_action(get_join_action())

func rebind_to_player(player, input_map):
	for action in input_map:
		var converted_action = player.__convert_action(action)
		
		# Create new player-specific action
		if InputMap.has_action(converted_action):
			InputMap.erase_action(converted_action)
		InputMap.add_action(converted_action)
		
		for event in input_map[action]:
			var is_joypad = __type == CONTROLLER_TYPE_JOYPAD
			var ev_is_joypad = (event is InputEventJoypadButton or event is InputEventJoypadMotion)
			
			# Copy joypad events only if joypad, otherwise all the rest
			if (is_joypad and ev_is_joypad) or (!is_joypad and !ev_is_joypad):
				# Create new copy of the event
				var new_event:InputEvent = event.duplicate(true)
				
				new_event.device = __device_id if is_joypad else 0
				
				InputMap.action_add_event(converted_action, new_event)
	
func get_name()->String:
	match __type:
		CONTROLLER_TYPE_JOYPAD:
			return Input.get_joy_name(__device_id)
		CONTROLLER_TYPE_KEYBOARD:
			return "Keyboard"
		_:
			return "INVALID CONTROLLER TYPE"

func vibrate(weak_magnitude, strong_magnitude, duration):
	if is_controller_connected():
		Input.start_joy_vibration(__device_id, weak_magnitude, strong_magnitude, duration)
		
func is_controller_connected()->bool:
	return __connected
	
func set_controller_connected(connected:bool):
	__connected = connected
	
	emit_signal("connection_changed")
	
	# Debug print
	print("[CONTROLLER %s] %d: %s, known: %s" % [
		"CONNECTED" if connected else "DISCONNECTED",
		__device_id, get_name(),
		"yes" if __type == CONTROLLER_TYPE_KEYBOARD or Input.is_joy_known(__device_id) else "no"
	])
