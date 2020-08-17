extends Object
class_name Controller

var __type:int = 0
var __device_id:int = 0
var __connected:bool = false

const CONTROLLER_TYPE_KEYBOARD = 1
const CONTROLLER_TYPE_JOYPAD = 2

func init_from_device(device_id:int)->void:
	__device_id = device_id
	__type = CONTROLLER_TYPE_JOYPAD
	__connected = true
	
func init_from_keyboard()->void:
	__device_id = -1
	__type = CONTROLLER_TYPE_KEYBOARD
	__connected = true
	
func get_name()->String:
	match __type:
		CONTROLLER_TYPE_JOYPAD:
			return Input.get_joy_name(__device_id)
		CONTROLLER_TYPE_KEYBOARD:
			return "Keyboard"
		_:
			return "INVALID CONTROLLER TYPE"

func is_controller_connected()->bool:
	return __connected
	
func set_controller_connected(connected:bool):
	__connected = connected
