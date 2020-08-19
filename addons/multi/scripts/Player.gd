extends Object
class_name Player

signal controller_connection_changed()

const ASSIGN_VIBRATE_DURATION = 1
const ASSIGN_VIBRATE_WEAK = 1
const ASSIGN_VIBRATE_STRONG = 1

var __controller:Controller = null
var __player_id:int = -1

func _init(player_id:int):
	__player_id = player_id
	connect("controller_connection_changed", self, "_on_controller_connection_changed")
	
func _on_controller_connection_changed():
	if is_controller_disconnected():
		Multi.emit_signal("num_assigned_players_changed", Multi.get_num_assigned_players())
	vibrate(ASSIGN_VIBRATE_WEAK, ASSIGN_VIBRATE_STRONG, ASSIGN_VIBRATE_DURATION)
	
func __convert_action(action:String)->String:
	return "p_%d_%s" % [__player_id, action]
	
func set_controller(controller:Controller, input_map)->void:
	# Debug print
	print("[CONTROLLER ASSIGNED] Player %d to Controller %d: %s" % [__player_id + 1, controller.__device_id, controller.get_name()])
	__controller = controller
	controller.rebind_to_player(self, input_map)
	emit_signal("controller_connection_changed")
	
func has_controller_assigned():
	return __controller != null

func is_controller_connected()->bool:
	return has_controller_assigned() and __controller.is_controller_connected()

func is_controller_disconnected()->bool:
	return has_controller_assigned() and !__controller.is_controller_connected()

func vibrate(weak_magnitude, strong_magnitude, duration):
	if is_controller_connected():
		__controller.vibrate(weak_magnitude, strong_magnitude, duration)

func is_event_from_this_player(event:InputEvent)->bool:
	return is_controller_connected() and __controller.is_event_from_this_controller(event)

func is_event_action(event:InputEvent, action:String)->bool:
	return is_controller_connected() and event.is_action(__convert_action(action))

func is_event_action_just_pressed(event:InputEvent, action:String)->bool:
	return is_controller_connected() and event.is_action_pressed(__convert_action(action))

func is_event_action_just_released(event:InputEvent, action:String)->bool:
	return is_controller_connected() and event.is_action_released(__convert_action(action))
	
func get_action_list(action:String)->Array:
	return InputMap.get_action_list(__convert_action(action))
	
func is_action_pressed(action:String)->bool:			return Input.is_action_pressed(__convert_action(action))
func is_action_just_pressed(action:String)->bool:	return Input.is_action_just_pressed(__convert_action(action))
func is_action_just_released(action:String)->bool:	return Input.is_action_just_released(__convert_action(action))
func get_action_strength(action:String)->float:		return Input.get_action_strength(__convert_action(action))
